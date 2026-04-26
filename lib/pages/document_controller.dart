import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

// Model
// Model
class DokumenItem {
  final String key;
  final String label;
  final String? keterangan;

  const DokumenItem({required this.key, required this.label, this.keterangan});
}

// Master document list
// Master document list
const List<DokumenItem> masterDocument = [
  DokumenItem(key: 'ijazah', label: 'Photocopy Ijazah SMA/SMK Sederajat'),
  DokumenItem(key: 'pas_foto', label: 'Pas Foto 3x4'),
  DokumenItem(key: 'ktp/kk', label: 'Photocopy KTP/KK'),
  DokumenItem(key: 'sertifikat_d3', label: 'Sertifikat D3'),
];

class DocumentController extends GetxController {
  final RxMap<String, Map<String, String>> uploadedDocs =
      <String, Map<String, String>>{}.obs;

  final RxSet<String> loadingDocs = <String>{}.obs;

  final RxSet<String> selectedKeys = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    selectedKeys.addAll(masterDocument.map((d) => d.key));
    fetchDokumenFromProfile();
  }

  void toggleSelected(String key) {
    if (selectedKeys.contains(key)) {
      selectedKeys.remove(key);
    } else {
      selectedKeys.add(key);
    }
  }

  bool isUploaded(String key) => uploadedDocs.containsKey(key);
  bool isLoading(String key) => loadingDocs.contains(key);

  // ─── GET /profile/documents ───────────────────────────────────────────────
  // ── Fetch dokumen dari profile ──
  Future<void> fetchDokumenFromProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/documents'), // ✅ endpoint yang benar
        headers: ApiEndpoints.authHeaders(token),
      );

      debugPrint('[DOC] GET /documents status: ${response.statusCode}');
      debugPrint('[DOC] GET /documents body: ${response.body}');

      print('=== FETCH DOCS STATUS: ${response.statusCode}');
      print('=== FETCH DOCS BODY: ${response.body}');

      // Skip kalau response kosong
      if (response.body.isEmpty) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final list = json['response'] as List<dynamic>;

        // ✅ Mapping list_id → profileKey
        const listIdToKey = {
          1: 'ktp/kk',
          2: 'pas_foto',
          3: 'ijazah',
          5: 'sertifikat_pelatihan',
          16: 'surat_pengalaman_kerja',
          605: 'portofolio',
        };

        for (final item in list) {
          final listId = item['list_id'] as int?;
          final key = listIdToKey[listId];
          if (key != null) {
            uploadedDocs[key] = {
              'id': item['id']?.toString() ?? '',
              'file_name': item['document_title']?.toString() ?? '',
              'file_url': item['file_url']?.toString() ?? '',
              'source': 'profile',
            };
          }
        final List data = json['response'] ?? [];

        for (var item in data) {
          final listId = item['list_id']?.toString() ?? '';
          final docList = item['document_list'];
          final title = docList?['title']?.toString() ?? listId;
          final fileUrl = item['upload_document']?.toString() ?? '';

          uploadedDocs[listId] = {
            'file_name': title,
            'file_url': fileUrl,
            'source': 'profile',
          };
        }
      }
    } catch (e) {
      debugPrint('[DOC] fetchDokumenFromProfile error: $e');
    }
  }

  // ─── POST api/document-profiles ──────────────────────────────────────
  // ── Pick file (support web & mobile) ──
  Future<PlatformFile?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      // [KUNCI] withData: true → ambil bytes, support web & mobile
      withData: true,
    );
    return result?.files.single;
  }

  // ── Build MultipartFile (support web & mobile) ──
  // Web: pakai fromBytes karena dart:io tidak tersedia
  // Mobile: bisa pakai fromBytes juga karena withData: true
  Future<http.MultipartFile> _buildMultipartFile(
    String field,
    PlatformFile file,
  ) async {
    if (kIsWeb) {
      // Web: pakai bytes langsung
      return http.MultipartFile.fromBytes(
        field,
        file.bytes!,
        filename: file.name,
      );
    } else {
      // Mobile/Desktop: bisa pakai fromPath atau fromBytes
      // pakai fromBytes supaya konsisten
      return http.MultipartFile.fromBytes(
        field,
        file.bytes!,
        filename: file.name,
      );
    }
  }

  // ── Upload dokumen dari Profile ──
  // POST /api/document-profiles
  Future<void> uploadDokumenFromProfil(String key) async {
    final file = await _pickFile();
    if (file == null) return;

    // ✅ Mapping key → list_id dari tabel document_lists
    const listIdMap = {
      'ktp/kk': 1,
      'pas_foto': 2,
      'ijazah': 3,
      'sertifikat_pelatihan': 5,
      'surat_pengalaman_kerja': 16,
      'portofolio': 605,
    };

    final listId = listIdMap[key];
    if (listId == null) {
      _showError('Jenis dokumen tidak dikenali');
      return;
    }

    // Validasi ukuran file maks 2MB
    if (file.size > 2 * 1024 * 1024) {
      _showError('Ukuran file maksimal 2MB');
      return;
    }

    loadingDocs.add(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${ApiEndpoints.baseUrl}/document-profiles');
      final request = http.MultipartRequest('POST', url);

      final headers = Map<String, String>.from(ApiEndpoints.authHeaders(token));
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // ✅ Format array sesuai Postman
      request.fields['documents[0][list_id]'] = listId.toString();

      final ioFile = File(file.path!);
      final bytes = await ioFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'documents[0][file]',
          bytes,
          filename: file.name,
        ),
      );

      debugPrint('[DOC] POST upload URL: $url');
      debugPrint('[DOC] POST upload list_id: $listId');
      debugPrint('[DOC] POST upload file: ${file.name}');
      final url = Uri.parse('${ApiEndpoints.baseUrl}/document-profiles');

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(ApiEndpoints.authHeaders(token))
        ..fields['documents[0][list_id]'] = key;

      // tambah file
      request.files.add(await _buildMultipartFile(
        'documents[0][file]',
        file,
      ));

      print('=== UPLOAD DOC URL: $url');
      print('=== UPLOAD DOC KEY: $key');

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      debugPrint('[DOC] POST upload status: ${response.statusCode}');
      debugPrint('[DOC] POST upload body: ${response.body}');

      print('=== UPLOAD DOC STATUS: ${response.statusCode}');
      print('=== UPLOAD DOC BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        Map<String, dynamic>? data;
        final raw = json['response'];
        if (raw is Map<String, dynamic>) {
          data = raw;
        } else if (raw is List && raw.isNotEmpty) {
          data = raw.first as Map<String, dynamic>?;
        }
        final List responseList = json['response'] ?? [];
        final data = responseList.isNotEmpty
            ? responseList[0] as Map<String, dynamic>
            : {};

        uploadedDocs[key] = {
          'file_name': file.name,
          'file_url': data['upload_document']?.toString() ?? '',
          'source': 'profile',
        };

        _showSuccess('Dokumen berhasil diupload');
      } else {
        final json = jsonDecode(response.body);
        _showError(
          json['metadata']?['message'] ??
              json['message'] ??
              'Gagal mengupload dokumen (${response.statusCode})',
        );
        _showError(
            json['metadata']?['message'] ?? 'Gagal Mengupload Dokumen');
      }
    } catch (e) {
      debugPrint('[DOC] uploadDokumenFromProfil error: $e');
      _showError('Terjadi kesalahan: ${e.toString()}');
      debugPrint('uploadDokumenFromProfile error: $e');
      _showError('Gagal upload, coba lagi');
    } finally {
      loadingDocs.remove(key);
    }
  }

  // ─── POST /apl01/documents/upload ────────────────────────────────────────
  // ── Upload dokumen dari APL01 ──
  // POST /api/document-profiles (sama, tapi source berbeda)
  Future<void> uploadDokumenFromApl01(String key) async {
    final file = await _pickFile();
    if (file == null) return;

    // Validasi ukuran file maks 2MB
    if (file.size > 2 * 1024 * 1024) {
      _showError('Ukuran file maksimal 2MB');
      return;
    }

    loadingDocs.add(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${ApiEndpoints.baseUrl}/apl01/documents/upload');
      final url = Uri.parse('${ApiEndpoints.baseUrl}/document-profiles');

      final request = http.MultipartRequest('POST', url);

      // ✅ Fix headers sama seperti di atas
      final rawHeaders = ApiEndpoints.authHeaders(token);
      final headers = Map<String, String>.from(rawHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields['document_type'] = key;

      final ioFile = File(file.path!);
      final bytes = await ioFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );

      debugPrint('[DOC] APL01 upload URL: $url');
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(ApiEndpoints.authHeaders(token))
        ..fields['documents[0][list_id]'] = key;

      request.files.add(await _buildMultipartFile(
        'documents[0][file]',
        file,
      ));

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      debugPrint('[DOC] APL01 upload status: ${response.statusCode}');
      debugPrint('[DOC] APL01 upload body: ${response.body}');

      print('=== UPLOAD APL01 DOC STATUS: ${response.statusCode}');
      print('=== UPLOAD APL01 DOC BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final List responseList = json['response'] ?? [];
        final data = responseList.isNotEmpty
            ? responseList[0] as Map<String, dynamic>
            : {};

        // Sync ke uploadedDocs → otomatis tersedia di Profile juga
        // sync ke uploadedDocs supaya keliatan di Profile juga
        uploadedDocs[key] = {
          'file_name': file.name,
          'file_url': data['upload_document']?.toString() ?? '',
          'source': 'apl01',
        };

        _showSuccess('Dokumen berhasil diupload');
      } else {
        final json = jsonDecode(response.body);
        _showError(
          json['metadata']?['message'] ??
              json['message'] ??
              'Gagal upload dokumen (${response.statusCode})',
        );
        _showError(
            json['metadata']?['message'] ?? 'Gagal Upload Dokumen');
      }
    } catch (e) {
      debugPrint('[DOC] uploadDokumenFromApl01 error: $e');
      _showError('Terjadi kesalahan: ${e.toString()}');
      debugPrint('uploadDokumenFromApl01 error: $e');
      _showError('Gagal upload, coba lagi');
    } finally {
      loadingDocs.remove(key);
    }
  }

  // ── Update dokumen ──
  // PUT /api/document-profiles/{{user_id}}
  Future<void> updateDokumen(String key, int userId) async {
    final file = await _pickFile();
    if (file == null) return;

    if (file.size > 2 * 1024 * 1024) {
      _showError('Ukuran file maksimal 2MB');
      return;
    }

    loadingDocs.add(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
          '${ApiEndpoints.baseUrl}/document-profiles/$userId');

      final request = http.MultipartRequest('PUT', url)
        ..headers.addAll(ApiEndpoints.authHeaders(token))
        ..fields['documents[0][list_id]'] = key;

      request.files.add(await _buildMultipartFile(
        'documents[0][file]',
        file,
      ));

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      print('=== UPDATE DOC STATUS: ${response.statusCode}');
      print('=== UPDATE DOC BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        uploadedDocs[key] = {
          'file_name': file.name,
          'file_url': '',
          'source': 'profile',
        };
        _showSuccess('Dokumen Berhasil Diperbarui');
      } else {
        final json = jsonDecode(response.body);
        _showError(
            json['metadata']?['message'] ?? 'Gagal Memperbarui Dokumen');
      }
    } catch (e) {
      debugPrint('updateDokumen error: $e');
      _showError('Gagal update, coba lagi');
    } finally {
      loadingDocs.remove(key);
    }
  }

  // ─── DELETE /profile/documents/{key} ─────────────────────────────────────
  // ── Delete dokumen ──
  Future<void> deleteDokumen(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${ApiEndpoints.baseUrl}/profile/documents/$key');
      final response = await http.delete(
        url,
        headers: ApiEndpoints.authHeaders(token),
      );

      debugPrint('[DOC] DELETE status: ${response.statusCode}');
      debugPrint('[DOC] DELETE body: ${response.body}');

      if (response.statusCode == 200) {
        uploadedDocs.remove(key);
        _showSuccess('Dokumen berhasil dihapus');
      } else {
        // silent remove di UI kalau endpoint belum ada
        uploadedDocs.remove(key);
        debugPrint('deleteDokumen: endpoint mungkin belum ada');
      }
    } catch (e) {
      // silent remove di UI
      uploadedDocs.remove(key);
      debugPrint('[DOC] deleteDokumen error: $e');
    }
  }

  // ── Helper: buka file picker ──
  Future<PlatformFile?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
      withReadStream: false,
    );
    return result?.files.single;
  }

  void _showSuccess(String msg) {
    Get.snackbar(
      'Berhasil',
      msg,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  void _showError(String msg) {
    Get.snackbar(
      'Gagal',
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }
}