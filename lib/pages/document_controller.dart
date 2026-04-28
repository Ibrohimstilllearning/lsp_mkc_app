import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

//Model
class DokumenItem {
  final String key; // key identify for the API
  final String label; // Interface name
  final String? keterangan; // additional information

  const DokumenItem({required this.key, required this.label, this.keterangan});
}

//Master document list
const List<DokumenItem> masterDocument = [
  DokumenItem(key: 'ijazah', label: 'Photocopy Ijazah SMA/SMK Sederajat'),
  DokumenItem(key: 'pas_foto', label: 'Pas Foto 3x4'),
  DokumenItem(key: 'ktp/kk', label: 'Photocopy KTP/KK'),
  DokumenItem(key: 'sertifikat_d3', label: 'Sertifikat D3'),
];

// Controller utama — dipakai bersama oleh
// ProfileDokumenPage DAN FormApl01Bagian4
class DocumentController extends GetxController {
  // key dokumen → info file yang sudah terupload
  // { 'ijazah': {'file_name': 'ijazah.pdf', 'file_url': 'https://...'} }
  final RxMap<String, Map<String, String>> uploadedDocs =
      <String, Map<String, String>>{}.obs;

  // key dokumen yang sedang dalam proses upload
  final RxSet<String> loadingDocs = <String>{}.obs;

  // key dokumen yang dipilih user untuk ditampilkan (checkbox selection)
  // kosong = belum pilih, kita isi dari masterDokumen secara default semua terpilih
  final RxSet<String> selectedKeys = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();

    selectedKeys.addAll(masterDocument.map((d) => d.key));
    fetchDokumenFromProfile();
  }

  // ── Toggle pilihan dokumen (checkbox di atas list) ──
  void toggleSelected(String key) {
    if (selectedKeys.contains(key)) {
      selectedKeys.remove(key);
    } else {
      selectedKeys.add(key);
    }
  }

  //isUploaded?
  bool isUploaded(String key) => uploadedDocs.containsKey(key);

  //isLoaded?
  bool isLoading(String key) => loadingDocs.contains(key);

  Future<void> fetchDokumenFromProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${ApiEndpoints.baseUrl}/profile/documents');

      final response = await http.get(
        url,
        headers: ApiEndpoints.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> raw = json is List 
            ? json 
            : (json['response'] ?? json['data'] ?? []);

        for (var item in raw) {
          if (item is Map<String, dynamic>) {
            final listId = item['document_list_id'] as int?;
            if (listId != null) {
              final key = _getKeyFromListId(listId);
              uploadedDocs[key] = {
                'file_name': item['file_name']?.toString() ?? '',
                'file_url': item['file_url']?.toString() ?? '',
                'source': 'profile',
              };
            }
          }
        }
      }
    } catch (e) {
      debugPrint('fetchDokumenFromProfile error: $e');
    }
  }

  int _getListIdFromKey(String key) {
    switch (key) {
      case 'pas_foto': return 1;
      case 'ktp/kk': return 2;
      case 'ijazah': return 3;
      case 'sertifikat_d3': return 4;
      default: return 0;
    }
  }

  String _getKeyFromListId(int id) {
    switch (id) {
      case 1: return 'pas_foto';
      case 2: return 'ktp/kk';
      case 3: return 'ijazah';
      case 4: return 'sertifikat_d3';
      default: return 'unknown_$id';
    }
  }

  // POST  /profile/documents/upload (dialihkan ke /documents)
  // Upload dokumen dari halaman Profile

  Future<void> uploadDokumenFromProfil(String key) async {
    final file = await _pickFile();
    if (file == null) return;

    loadingDocs.add(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${ApiEndpoints.baseUrl}/documents');
      final listId = _getListIdFromKey(key);

      //Send as multipart cz upload file
      final headers = ApiEndpoints.authHeaders(token);
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(headers)
        ..fields['documents[0][list_id]'] = listId.toString()
        ..files.add(await http.MultipartFile.fromPath('documents[0][file]', file.path!));

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);

        Map<String, dynamic>? data;
        final List<dynamic> raw = json is List 
            ? json 
            : (json['response'] ?? json['data'] ?? []);
            
        if (raw.isNotEmpty && raw[0] is Map) {
          data = raw[0] as Map<String, dynamic>;
        }

        uploadedDocs[key] = {
          'file_name': data?['file_name']?.toString() ?? file.name,
          'file_url': data?['file_url']?.toString() ?? '',
          'source': 'profile',
        };

        _showSuccess('Dokumen Berhasil Diupload');
      } else {
        String msg = 'Gagal Mengupload (${response.statusCode})';
        try {
          final json = jsonDecode(response.body);
          msg = json['metadata']?['message'] ?? json['message'] ?? msg;
        } catch (_) {
          msg = 'Server Error ${response.statusCode}: ${response.body}';
        }
        _showError(msg);
      }
    } catch (e) {
      debugPrint('uploadDokumenFromProfile error: $e');
      _showError('Gagal terkoneksi atau membaca file: $e');
    } finally {
      loadingDocs.remove(key);
    }
  }

  // POST  /apl01/documents/upload
  // Upload dokumen dari halaman APL01
  // Setelah berhasil → otomatis sync ke profile (uploadedDocs)
  Future<void> uploadDokumenFromApl01(String key) async {
    final file = await _pickFile();
    if (file == null) return;

    loadingDocs.add(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}/documents',
      ); // fallback /documents
      final listId = _getListIdFromKey(key);

      final headers = ApiEndpoints.authHeaders(token);
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(headers)
        ..fields['documents[0][list_id]'] = listId.toString()
        ..files.add(await http.MultipartFile.fromPath('documents[0][file]', file.path!));

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        Map<String, dynamic>? data;
        
        final List<dynamic> raw = json is List 
            ? json 
            : (json['response'] ?? json['data'] ?? []);
            
        if (raw.isNotEmpty && raw[0] is Map) {
          data = raw[0] as Map<String, dynamic>;
        }

        // ✅ Sync ke uploadedDocs → otomatis tersedia di Profile juga
        uploadedDocs[key] = {
          'file_name': data?['file_name']?.toString() ?? file.name,
          'file_url': data?['fole_url']?.toString() ?? '',
          'source': 'apl01',
        };

        _showSuccess('Dokumen Berhasil Diupload');
      } else {
        String msg = 'Gagal Mengupload (${response.statusCode})';
        try {
          final json = jsonDecode(response.body);
          msg = json['metadata']?['message'] ?? json['message'] ?? msg;
        } catch (_) {
          msg = 'Server Error ${response.statusCode}: ${response.body}';
        }
        _showError(msg);
      }
    } catch (e) {
      debugPrint('uploadDokumenFromApl01 error: $e');
      _showError('Gagal terkoneksi atau membaca file: $e');
    } finally {
      loadingDocs.remove(key);
    }
  }

  // DELETE
  Future<void> deleteDokumen(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}/profile/documents/$key',
      ); // endpoint belum ada

      final response = await http.delete(
        url,
        headers: ApiEndpoints.authHeaders(token),
      );

      if (response.statusCode == 200) {
        uploadedDocs.remove(key);
        _showSuccess('Dokumen berhasil dihapus');
      } else {
        _showError('Gagal menghapus dokumen');
      }
    } catch (e) {
      // Silent remove di UI jika endpoint belum ada (mode dev)
      uploadedDocs.remove(key);
      debugPrint('deleteDokumen error: $e');
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
