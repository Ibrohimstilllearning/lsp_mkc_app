import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class DokumenItem {
  final String key;
  final String label;
  final String? keterangan;

  const DokumenItem({required this.key, required this.label, this.keterangan});
}

// ─── Master document list ─────────────────────────────────────────────────────
const List<DokumenItem> masterDocument = [
  DokumenItem(key: 'ijazah', label: 'Photocopy Ijazah Min. SMA/SMK Sederajat'),
  DokumenItem(
    key: 'sertifikat_pelatihan',
    label: 'Photocopy Sertifikat Pelatihan Kompetensi Tenaga Administrasi Kewirausahaan',
    keterangan: 'Tergantung pada jenis skema',
  ),
  DokumenItem(
    key: 'surat_pengalaman_kerja',
    label: 'Surat Pengalaman Kerja Minimal 2 Tahun',
    keterangan: 'Di bidang tenaga Administrasi',
  ),
  DokumenItem(key: 'pas_foto', label: 'Pas Foto 3x4'),
  DokumenItem(key: 'portofolio', label: 'Portofolio'),
  DokumenItem(key: 'ktp/kk', label: 'Photocopy KTP / Kartu Keluarga (KK)'),
];

// ─── Mapping ──────────────────────────────────────────────────────────────────
const listIdToKey = {
  1: 'ktp/kk',
  2: 'pas_foto',
  3: 'ijazah',
  5: 'sertifikat_pelatihan',
  16: 'surat_pengalaman_kerja',
  605: 'portofolio',
};

const keyToListId = {
  'ktp/kk': 1,
  'pas_foto': 2,
  'ijazah': 3,
  'sertifikat_pelatihan': 5,
  'surat_pengalaman_kerja': 16,
  'portofolio': 605,
};

// ─── Controller ───────────────────────────────────────────────────────────────
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

  // ─── GET /documents ───────────────────────────────────────────────────────
  Future<void> fetchDokumenFromProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/documents'),
        headers: ApiEndpoints.authHeaders(token),
      );

      debugPrint('[DOC] GET /documents status: ${response.statusCode}');
      debugPrint('[DOC] GET /documents body: ${response.body}');

      if (response.body.isEmpty) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final list = json['response'] as List<dynamic>;

        for (final item in list) {
          final listId = item['list_id'] as int?;
          final key = listIdToKey[listId];
          if (key != null) {
            uploadedDocs[key] = {
              'id':        item['id']?.toString() ?? '',
              'file_name': item['document_title']?.toString() ?? '',
              'file_url':  item['file_url']?.toString() ?? '',
              'source':    'profile',
            };
          }
        }
      }
    } catch (e) {
      debugPrint('[DOC] fetchDokumenFromProfile error: $e');
    }
  }

  // ─── POST /document-profiles ──────────────────────────────────────────────
  Future<void> uploadDokumenFromProfil(String key) async {
    final file = await _pickFile();
    if (file == null) return;

    final listId = keyToListId[key];
    if (listId == null) {
      _showError('Jenis dokumen tidak dikenali');
      return;
    }

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

      final rawHeaders = ApiEndpoints.authHeaders(token);
      final headers = Map<String, String>.from(rawHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields['documents[0][list_id]'] = listId.toString();

      final ioFile = File(file.path!);
      final bytes = await ioFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'documents[0][file]',
        bytes,
        filename: file.name,
      ));

      debugPrint('[DOC] POST upload URL: $url');
      debugPrint('[DOC] POST upload list_id: $listId');
      debugPrint('[DOC] POST upload file: ${file.name}');

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      debugPrint('[DOC] POST upload status: ${response.statusCode}');
      debugPrint('[DOC] POST upload body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);

        Map<String, dynamic>? data;
        final raw = json['response'];
        if (raw is Map<String, dynamic>) {
          data = raw;
        } else if (raw is List && raw.isNotEmpty) {
          data = raw.first as Map<String, dynamic>?;
        }

        uploadedDocs[key] = {
          'id':        data?['id']?.toString() ?? '',
          'file_name': data?['file_name']?.toString() ?? file.name,
          'file_url':  data?['file_url']?.toString() ?? '',
          'source':    'profile',
        };

        // Refresh dari server agar id & file_url ter-update
        await fetchDokumenFromProfile();

        _showSuccess('Dokumen berhasil diupload');
      } else {
        final json = jsonDecode(response.body);
        _showError(
          json['metadata']?['message'] ??
              json['message'] ??
              'Gagal mengupload dokumen (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('[DOC] uploadDokumenFromProfil error: $e');
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      loadingDocs.remove(key);
    }
  }

  // ─── POST /apl01/documents/upload ────────────────────────────────────────
  Future<void> uploadDokumenFromApl01(String key) async {
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

      final url = Uri.parse('${ApiEndpoints.baseUrl}/apl01/documents/upload');
      final request = http.MultipartRequest('POST', url);

      final rawHeaders = ApiEndpoints.authHeaders(token);
      final headers = Map<String, String>.from(rawHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields['document_type'] = key;

      final ioFile = File(file.path!);
      final bytes = await ioFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
      ));

      debugPrint('[DOC] APL01 upload URL: $url');

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      debugPrint('[DOC] APL01 upload status: ${response.statusCode}');
      debugPrint('[DOC] APL01 upload body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);

        Map<String, dynamic>? data;
        final raw = json['response'];
        if (raw is Map<String, dynamic>) {
          data = raw;
        } else if (raw is List && raw.isNotEmpty) {
          data = raw.first as Map<String, dynamic>?;
        }

        uploadedDocs[key] = {
          'id':        data?['id']?.toString() ?? '',
          'file_name': data?['file_name']?.toString() ?? file.name,
          'file_url':  data?['file_url']?.toString() ?? '',
          'source':    'apl01',
        };

        _showSuccess('Dokumen berhasil diupload');
      } else {
        final json = jsonDecode(response.body);
        _showError(
          json['metadata']?['message'] ??
              json['message'] ??
              'Gagal upload dokumen (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('[DOC] uploadDokumenFromApl01 error: $e');
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      loadingDocs.remove(key);
    }
  }

  // ─── DELETE /documents/{id} ───────────────────────────────────────────────
  Future<void> deleteDokumen(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final docId = uploadedDocs[key]?['id'] ?? '';

      if (docId.isEmpty) {
        _showError('Gagal: ID dokumen tidak ditemukan');
        return;
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}/documents/$docId');
      final response = await http.delete(
        url,
        headers: ApiEndpoints.authHeaders(token),
      );

      debugPrint('[DOC] DELETE status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        uploadedDocs.remove(key);
        _showSuccess('Dokumen berhasil dihapus');
      } else {
        uploadedDocs.remove(key);
        debugPrint('[DOC] deleteDokumen: endpoint mungkin belum ada');
      }
    } catch (e) {
      uploadedDocs.remove(key);
      debugPrint('[DOC] deleteDokumen error: $e');
    }
  }

  // ─── Helper: pick file ────────────────────────────────────────────────────
  Future<PlatformFile?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
      withReadStream: false,
    );
    return result?.files.single;
  }

  // ─── Helper: snackbar ─────────────────────────────────────────────────────
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