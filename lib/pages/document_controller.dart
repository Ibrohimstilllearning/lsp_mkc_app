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
  DokumenItem(key: 'ijazah', label: 'Photocopy Ijazah Min. SMA/SMK Sederajat'),
  DokumenItem(
    key: 'sertifikat_pelatihan',
    label:
        'Photocopy Sertifikat Pelatihan Kompetensi Tenaga Administrasi Kewirausahaan',
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
        final data = json['response'] as Map<String, dynamic>?;

        if (data != null) {
          data.forEach((key, value) {
            if (value != null) {
              uploadedDocs[key] = {
                'file_name': value['file_name']?.toString() ?? '',
                'file_url': value['file_url']?.toString() ?? '',
                'source': 'profile', // mark the document source is from profile
              };
            }
          });
        }
      }
    } catch (e) {
      debugPrint('fetchDokumenFromProfile error: $e');
    }
  }

  // POST  /profile/documents/upload
  // Upload dokumen dari halaman Profile

  Future<void> uploadDokumenFromProfil(String key) async {
    final file = await _pickFile();
    if (file == null) return;

    loadingDocs.add(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${ApiEndpoints.baseUrl}/profile/documents/upload');

      //Send as multipart cz upload file
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(ApiEndpoints.authHeaders(token))
        ..fields['document_type'] = key 
        ..files.add(await http.MultipartFile.fromPath('file', file.path!));

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      if(response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);

        // Expected response:
        // { "response": { "file_name": "...", "file_url": "..." } }
        final data = json['response'] as Map<String, dynamic>;

        uploadedDocs[key] = {
          'file_name' : data?['file_name']?.toString() ?? file.name,
          'file_url' : data?['file_url']?.toString() ?? '',
          'source' : 'profile'
        };

        _showSuccess('Dokumen Berhasil Diupload');
      } else {
        final json = jsonDecode(response.body);
        _showError(json['metadata']?['message'] ?? 'Gagal Mengupload Dokumen');
      }
    } catch (e) {
      // Jika endpoint belum ada, simpan lokal dulu (mode offline/dev)
      final file2 = await _pickFile();
      debugPrint('uploadDokumenFromProfile error: $e');
      _showError('Endpoint belum tersedia, hubungi developer backend');
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

      final url = Uri.parse('${ApiEndpoints.baseUrl}/apl01/documents/upload'); // endpoint not exist

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(ApiEndpoints.authHeaders(token))
        ..fields['document_type'] = key
        ..files.add(await http.MultipartFile.fromPath('file', file.path!));

      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      if(response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final data = json['response'] as Map<String, dynamic>?;

        // ✅ Sync ke uploadedDocs → otomatis tersedia di Profile juga
        uploadedDocs[key] = {
          'file_name' : data?['file_name']?.toString() ?? file.name,
          'file_url' : data?['fole_url']?.toString() ?? '',
          'source' : 'apl01'
        };

        _showSuccess('Dokumen Berhasil Diupload');
      } else {
        final json = jsonDecode(response.body);
        _showError(json['metadata']?['message']?? 'Gagal Upload Dokumen');
      }
    } catch (e) {
      debugPrint('uploadDokumenFromApl01 error: $e');
      _showError('Endpoint not Available, call backend dev');
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
          '${ApiEndpoints.baseUrl}/profile/documents/$key'); // endpoint belum ada
 
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
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
      withReadStream: false,
    );
    return result?.files.single;
  }
 
  void _showSuccess(String msg) {
    Get.snackbar('Berhasil', msg,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10);
  }
 
  void _showError(String msg) {
    Get.snackbar('Gagal', msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10);
  }
}
