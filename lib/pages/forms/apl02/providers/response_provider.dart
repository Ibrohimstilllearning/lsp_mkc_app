import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/document_list.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/response.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/submit.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

/// Wrapper untuk hasil fetch — bawa data ATAU error message
class Apl02FetchResult {
  final ResponseRegistration? data;
  final String? errorMessage;
  Apl02FetchResult({this.data, this.errorMessage});
}

/// Wrapper untuk hasil submit APL-02
class Apl02SubmitResult {
  final bool success;
  final String? message;
  final List<String> missingFiles; // from E2013 response
  final int? totalAnswers;

  Apl02SubmitResult({
    required this.success,
    this.message,
    this.missingFiles = const [],
    this.totalAnswers,
  });
}

class ResponseProvider {
  final String baseUrl = ApiEndpoints.baseUrl;

  // ┌───────────────────────────────────────────────────────────────────┐
  // │  SET false SETELAH BACKEND FIX — supaya pakai API sungguhan      │
  // └───────────────────────────────────────────────────────────────────┘
  static const bool useMockData = false;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Apl02FetchResult> getDatabyId(int registrationId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return Apl02FetchResult(errorMessage: 'Token tidak ditemukan.');
      }
      final headers = ApiEndpoints.authHeaders(token);
      final url = Uri.parse('$baseUrl/registrations/$registrationId/apl02');
      print('[APL02] GET $url');
      final response = await http.get(url, headers: headers);
      print('[APL02] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final dataKey = decoded['response'] ?? decoded['data'] ?? decoded;
        return Apl02FetchResult(data: ResponseRegistration.fromJson(dataKey));
      }

      String serverMsg = 'Server error ${response.statusCode}';
      try {
        final errJson = jsonDecode(response.body);
        serverMsg = errJson['message'] ??
            errJson['metadata']?['message'] ??
            serverMsg;
      } catch (_) {}
      return Apl02FetchResult(errorMessage: serverMsg);
    } catch (e) {
      print('[APL02] Exception: $e');
      return Apl02FetchResult(errorMessage: 'Koneksi gagal: $e');
    }
  }

  /// Submit APL-02 — returns detailed result including missing files
  Future<Apl02SubmitResult> postDatabyId(
      int registrationId, SubmitApl02Request payload) async {
    try {
      final token = await _getToken();
      final headers = token != null
          ? ApiEndpoints.authHeaders(token)
          : ApiEndpoints.headers;
      final url =
          Uri.parse('$baseUrl/registrations/$registrationId/apl02');
      print('[APL02] POST $url');
      print('[APL02] POST Body: ${jsonEncode(payload.toJson())}');

      final response = await http.post(url,
          headers: headers, body: jsonEncode(payload.toJson()));
      print('[APL02] POST Status: ${response.statusCode}');
      print('[APL02] POST Response: ${response.body}');

      final decoded = jsonDecode(response.body);
      final metadata = decoded['metadata'];
      final responseData = decoded['response'];

      // Handle E2013 — missing required documents
      if (metadata != null && metadata['code'] == 'E2013') {
        final missingList = responseData?['missing_files'] as List? ?? [];
        return Apl02SubmitResult(
          success: false,
          message:
              metadata['message'] ?? 'Dokumen wajib belum diunggah.',
          missingFiles:
              missingList.map((e) => e.toString()).toList(),
        );
      }

      // Success
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Apl02SubmitResult(
          success: true,
          message: metadata?['message'] ?? 'APL.02 berhasil disubmit.',
          totalAnswers: responseData?['total_answers'] as int?,
        );
      }

      // Other errors
      return Apl02SubmitResult(
        success: false,
        message: metadata?['message'] ??
            'Server error ${response.statusCode}',
      );
    } catch (e) {
      print('[APL02] POST Error: $e');
      return Apl02SubmitResult(
        success: false,
        message: 'Koneksi gagal: $e',
      );
    }
  }

  /// ── SUMBER UTAMA ────────────────────────────────────────────────────────
  /// Fetch portfolio + status upload per skema.
  /// Endpoint: GET /schemes/{schemeId}/portfolios
  ///
  /// Response berisi daftar dokumen yang dibutuhkan skema beserta
  /// info apakah user sudah upload atau belum.
  Future<List<SchemePortfolio>> fetchSchemePortfolios(int schemeId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('[APL02] fetchSchemePortfolios: token null, skip');
        return [];
      }

      final url = Uri.parse('$baseUrl/schemes/$schemeId/portfolios');
      print('[APL02] GET $url');
      final response =
          await http.get(url, headers: ApiEndpoints.authHeaders(token));
      print('[APL02] scheme-portfolios status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // ── Log raw response untuk debugging ──────────────────────────
        print('[APL02] scheme-portfolios raw: ${response.body.substring(0, response.body.length.clamp(0, 500))}');

        // Backend bisa kirim: List langsung, atau { response: [...] },
        // atau { data: [...] }, atau { portfolios: [...] }
        List<dynamic> raw;
        if (decoded is List) {
          raw = decoded;
        } else if (decoded is Map) {
          raw = (decoded['response'] ??
                  decoded['data'] ??
                  decoded['portfolios'] ??
                  decoded['document_lists'] ??
                  []) as List<dynamic>;
        } else {
          raw = [];
        }

        print('[APL02] scheme-portfolios parsed ${raw.length} items');
        if (raw.isEmpty) {
          print('[APL02] ⚠ scheme-portfolios kosong — cek format response backend');
        }

        return raw.map((e) {
          try {
            return SchemePortfolio.fromJson(e as Map<String, dynamic>);
          } catch (parseErr) {
            print('[APL02] SchemePortfolio.fromJson error on item $e : $parseErr');
            rethrow;
          }
        }).toList();
      }

      print('[APL02] scheme-portfolios failed: ${response.statusCode} — ${response.body}');
    } catch (e) {
      print('[APL02] fetchSchemePortfolios error: $e');
    }
    return [];
  }

  /// ── FALLBACK: master list dokumen per skema ─────────────────────────────
  /// Endpoint: GET /document-lists?scheme_id={id}
  ///
  /// CATATAN: Backend saat ini (2026-04) belum memfilter dengan benar —
  /// mengembalikan semua dokumen meski diberi ?scheme_id=.
  /// Karena itu kita selalu terapkan client-side filter agar data yang
  /// ditampilkan benar-benar hanya milik skema user.
  Future<List<DocumentList>> fetchAllDocumentLists({int? schemeId}) async {
    try {
      final token = await _getToken();
      if (token == null) return [];
      final headers = ApiEndpoints.authHeaders(token);

      List<dynamic> raw = [];
      bool fetched = false;

      // ── Coba dengan query param scheme_id dulu ─────────────────────────
      if (schemeId != null) {
        final filteredUrl =
            Uri.parse('$baseUrl/documents?scheme_id=$schemeId');
        print('[APL02] GET $filteredUrl');
        final res = await http.get(filteredUrl, headers: headers);
        print('[APL02] documents?scheme_id=$schemeId status: ${res.statusCode}');

        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          raw = decoded is List
              ? decoded
              : (decoded['response'] ?? decoded['data'] ?? []) as List<dynamic>;
          fetched = true;
        }
      }

      // ── Jika belum berhasil, ambil semua tanpa filter ──────────────────
      if (!fetched) {
        final url = Uri.parse('$baseUrl/documents');
        print('[APL02] GET $url (no scheme filter)');
        final response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          raw = decoded is List
              ? decoded
              : (decoded['response'] ?? decoded['data'] ?? []) as List<dynamic>;
        }
      }

      if (raw.isEmpty) return [];

      final all = raw
          .map((e) => DocumentList.fromJson(e as Map<String, dynamic>))
          .toList();

      // ── SELALU terapkan client-side filter per scheme_id ──────────────
      // Bahkan jika backend sudah memfilter via query param, kita filter
      // lagi di sini untuk memastikan konsistensi data.
      if (schemeId != null) {
        final filtered = all
            .where((d) => d.schemeId == schemeId || d.schemeId == null)
            .toList();
        print('[APL02] document-lists: ${all.length} total → '
            '${filtered.length} setelah filter scheme_id=$schemeId');
        return filtered;
      }

      return all;
    } catch (e) {
      print('[APL02] fetchAllDocumentLists error: $e');
    }
    return [];
  }

  /// ── FALLBACK: dokumen yang sudah diupload user ───────────────────────────
  /// Endpoint: GET /document-profiles
  Future<List<DocumentProfile>> fetchUserDocumentProfiles() async {
    try {
      final token = await _getToken();
      if (token == null) return [];
      final url = Uri.parse('$baseUrl/documents');
      print('[APL02] GET $url');
      final response =
          await http.get(url, headers: ApiEndpoints.authHeaders(token));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> raw = decoded is List
            ? decoded
            : (decoded['response'] ?? decoded['data'] ?? []);
        return raw
            .map((e) => DocumentProfile.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('[APL02] fetchUserDocumentProfiles error: $e');
    }
    return [];
  }

  /// Upload dokumen (update file yang sudah ada — punya document_profile_id)
  Future<bool> uploadPortfolioDocument({
    required int registrationId,
    required int portfolioId,
    required int listId,
    required PlatformFile file,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = Uri.parse('$baseUrl/documents/$portfolioId');
      print('[APL02] Upload update (profile_id=$portfolioId) → POST(PUT) $url');

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(ApiEndpoints.authHeaders(token))
        ..fields['_method'] = 'PUT'
        ..fields['documents[0][list_id]'] = listId.toString()
        ..files.add(await http.MultipartFile.fromPath('documents[0][file]', file.path!));
      
      if (registrationId > 0) {
        request.fields['registration_id'] = registrationId.toString();
      }

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);
      print('[APL02] Upload Status: ${response.statusCode}');
      print('[APL02] Upload Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[APL02] Upload Error: $e');
      return false;
    }
  }

  /// Upload dokumen BARU (belum pernah diupload — pakai document_list_id)
  /// Endpoint: POST /document-profiles
  Future<bool> uploadNewDocument({
    required int registrationId,
    required int listId,
    required PlatformFile file,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = Uri.parse('$baseUrl/documents');
      print('[APL02] Upload NEW (list_id=$listId) → $url');

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(ApiEndpoints.authHeaders(token))
        ..fields['documents[0][list_id]'] = listId.toString()
        ..files.add(await http.MultipartFile.fromPath('documents[0][file]', file.path!));
      
      if (registrationId > 0) {
        request.fields['registration_id'] = registrationId.toString();
      }

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);
      print('[APL02] Upload New Status: ${response.statusCode}');
      print('[APL02] Upload New Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[APL02] Upload New Error: $e');
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: satu item dari GET /schemes/{id}/portfolios
// ─────────────────────────────────────────────────────────────────────────────
class SchemePortfolio {
  final int id;                  // portfolio entry id (atau document_list id)
  final DocumentList documentList;
  final String? fileUrl;         // null → belum diupload
  final String? fileName;
  final int? portfolioEntryId;   // id record portfolio user jika sudah ada
  final String status;

  SchemePortfolio({
    required this.id,
    required this.documentList,
    this.fileUrl,
    this.fileName,
    this.portfolioEntryId,
    this.status = 'pending',
  });

  bool get isUploaded => fileUrl != null && fileUrl!.isNotEmpty;

  factory SchemePortfolio.fromJson(Map<String, dynamic> json) {
    // ── Bangun DocumentList dari nested atau flat fields ────────────────
    // Backend bisa kirim: { document_list: {id, title, ...} }
    // atau flat: { document_list_id, title, description }
    // atau nested via: { document_list: { id, title, scheme_id } }
    Map<String, dynamic> docListJson;

    if (json['document_list'] is Map) {
      docListJson = json['document_list'] as Map<String, dynamic>;
    } else {
      // Flat — rakit dari field-field yang tersedia
      docListJson = {
        'id': json['document_list_id'] ?? json['list_id'] ?? json['id'],
        'title': json['title'] ?? json['name'] ?? '',
        'description': json['description'] ?? '',
        'scheme_id': json['scheme_id'],
      };
    }

    // ── Upload info ─────────────────────────────────────────────────────
    final fileUrl =
        json['file_url'] as String? ?? json['upload_document'] as String?;
    final fileName = json['file_name'] as String?;

    // ── Portfolio entry id (untuk update file jika sudah ada) ───────────
    final portfolioEntryId =
        json['portfolio_id'] as int? ??
        json['user_portfolio_id'] as int? ??
        json['pivot']?['portfolio_id'] as int?;

    // ── Status ──────────────────────────────────────────────────────────
    final status = json['status'] as String? ?? 'pending';

    return SchemePortfolio(
      id: json['id'] as int,
      documentList: DocumentList.fromJson(docListJson),
      fileUrl: fileUrl,
      fileName: fileName,
      portfolioEntryId: portfolioEntryId,
      status: status,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: hasil dari GET /document-profiles  (fallback)
// ─────────────────────────────────────────────────────────────────────────────
class DocumentProfile {
  final int id;
  final int documentListId;
  final String? fileUrl;
  final String? fileName;
  final String status;

  DocumentProfile({
    required this.id,
    required this.documentListId,
    this.fileUrl,
    this.fileName,
    this.status = 'pending',
  });

  bool get isUploaded => fileUrl != null && fileUrl!.isNotEmpty;

  factory DocumentProfile.fromJson(Map<String, dynamic> json) {
    return DocumentProfile(
      id: json['id'] as int,
      documentListId: int.tryParse(json['document_list_id']?.toString() ?? '') ??
          int.tryParse(json['list_id']?.toString() ?? '') ??
          int.tryParse(json['document_list']?['id']?.toString() ?? '') ??
          0,
      fileUrl: json['file_url'] as String? ??
          json['upload_document'] as String?,
      fileName: json['file_name'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }
}