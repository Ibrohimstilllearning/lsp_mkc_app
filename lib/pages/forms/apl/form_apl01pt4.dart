import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/pages/document_controller.dart';
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01_controller.dart';
<<<<<<< HEAD
=======
import 'package:lsp_mkc_app/pages/profil_controller.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';
>>>>>>> fa851aee07189e56c65188bb354f737ea1536690
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormApl01Bagian4 extends StatefulWidget {
  const FormApl01Bagian4({super.key});

  @override
  State<FormApl01Bagian4> createState() => _FormApl01Bagian4State();
}

class _FormApl01Bagian4State extends State<FormApl01Bagian4> {
  final FormApl01Controller c = Get.find<FormApl01Controller>();
  final ImagePicker _picker = ImagePicker();

  DocumentController get _docC {
    if (Get.isRegistered<DocumentController>())
      return Get.find<DocumentController>();
    return Get.put(DocumentController());
  }

  // ─── State upload manual ──────────────────────────────────────────────────
  File? _pasFotoFile;
  File? _ktpFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _docC.fetchDokumenFromProfile();
  }

  // ─── Config ───────────────────────────────────────────────────────────────
  static const int _pasFotoReqId = 3;
  static const int _pasFotoListId = 1;
  static const int _ktpReqId = 4;
  static const int _ktpListId = 2;

  // ─── Cek dokumen dari profil ──────────────────────────────────────────────
  bool get _pasFotoFromProfil =>
      (_docC.uploadedDocs['pas_foto']?['file_url'] ?? '').isNotEmpty;

  bool get _ktpFromProfil =>
      (_docC.uploadedDocs['ktp/kk']?['file_url'] ?? '').isNotEmpty;

  // ─── Cek apakah dokumen siap ──────────────────────────────────────────────
  bool get _pasFotoReady => _pasFotoFromProfil || _pasFotoFile != null;
  bool get _ktpReady => _ktpFromProfil || _ktpFile != null;

  // ─── Minimal 1 dokumen untuk bisa kirim ──────────────────────────────────
  bool get _isReady => _pasFotoReady || _ktpReady;

  int get _uploadedCount => (_pasFotoReady ? 1 : 0) + (_ktpReady ? 1 : 0);

  // ─── Picker ───────────────────────────────────────────────────────────────
  Future<void> _pickPasFoto() async {
    final file = await _pickFile(['jpg', 'jpeg', 'png']);
    if (file != null && mounted) setState(() => _pasFotoFile = file);
  }

  Future<void> _pickKtp() async {
    final file = await _pickFile(['jpg', 'jpeg', 'png', 'pdf']);
    if (file != null && mounted) setState(() => _ktpFile = file);
  }

  Future<File?> _pickFile(List<String> accept) async {
    final source = await _showPickerDialog(accept);
    if (source == null) return null;
    try {
      if (source == 'camera') {
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (picked != null) return File(picked.path);
      } else if (source == 'gallery') {
        final picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (picked != null) return File(picked.path);
      } else if (source == 'file') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: accept,
        );
        if (result != null && result.files.single.path != null) {
          return File(result.files.single.path!);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    }
    return null;
  }

  Future<String?> _showPickerDialog(List<String> accept) async {
    final hasPdf = accept.contains('pdf');
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih Sumber File',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: _pickerBox(
                  Icons.camera_alt_outlined,
                  const Color(0xFFE8F5E9),
                  const Color(0xFF4CAF50),
                ),
                title: const Text(
                  'Ambil Foto',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                subtitle: const Text(
                  'Buka kamera',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: _pickerBox(
                  Icons.photo_library_outlined,
                  const Color(0xFFE8F5E9),
                  const Color(0xFF4CAF50),
                ),
                title: const Text(
                  'Pilih dari Galeri',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                subtitle: const Text(
                  'Gambar dari galeri',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              if (hasPdf)
                ListTile(
                  leading: _pickerBox(
                    Icons.upload_file_rounded,
                    const Color(0xFFEFF6FF),
                    const Color(0xFF3B82F6),
                  ),
                  title: const Text(
                    'Pilih File / PDF',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Dokumen dari penyimpanan',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                  onTap: () => Navigator.pop(ctx, 'file'),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerBox(IconData icon, Color bg, Color fg) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: fg, size: 20),
  );

  // ─── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_isReady) return;
    if (mounted) setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}/apl01/bukti-administratif',
      );
      final request = http.MultipartRequest('POST', url);

      final rawHeaders = token != null
          ? ApiEndpoints.authHeaders(token)
          : ApiEndpoints.headers;
      final headers = Map<String, String>.from(rawHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields['registration_id'] = (c.registrationId ?? '').toString();

      print('[DEBUG] uploadedDocs: ${_docC.uploadedDocs}');
      print('[DEBUG] pas_foto entry: ${_docC.uploadedDocs['pas_foto']}');
      print('[DEBUG] pas_foto id: ${_docC.uploadedDocs['pas_foto']?['id']}');
      print('[DEBUG] ktp entry: ${_docC.uploadedDocs['ktp/kk']}');

      int index = 0;

      // ── Pas Foto ──────────────────────────────────────────────────────────
      if (_pasFotoReady) {
        request.fields['evidence[$index][requirement_id]'] = _pasFotoReqId
            .toString();
        request.fields['evidence[$index][list_id]'] = _pasFotoListId.toString();

        if (_pasFotoFile != null) {
          // Upload file baru
          if (!await _pasFotoFile!.exists()) {
            _showFileNotFound();
            return;
          }
          final bytes = await _pasFotoFile!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'evidence[$index][file]',
              bytes,
              filename: _pasFotoFile!.path.split('/').last,
            ),
          );
        } else {
          // Dari profil — download via stream
          final docId = _docC.uploadedDocs['pas_foto']?['id'] ?? '';
          if (docId.isEmpty) {
            Get.snackbar(
              'Gagal',
              'Dokumen Pas Foto tidak ditemukan di profil',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(16),
            );
            if (mounted) setState(() => _isLoading = false);
            return;
          }
          final fileName =
              _docC.uploadedDocs['pas_foto']?['file_name'] ?? 'pas_foto';
          final streamUrl = Uri.parse(
            '${ApiEndpoints.baseUrl}/documents/$docId/stream',
          );
          final fileResp = await http.get(
            streamUrl,
            headers: ApiEndpoints.authHeaders(token!),
          );
          if (fileResp.statusCode == 200) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'evidence[$index][file]',
                fileResp.bodyBytes,
                filename: fileName,
              ),
            );
          } else {
            Get.snackbar(
              'Gagal',
              'Gagal mengambil Pas Foto dari profil',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(16),
            );
            if (mounted) setState(() => _isLoading = false);
            return;
          }
        }
        index++;
      }

      // ── KTP ───────────────────────────────────────────────────────────────
      if (_ktpReady) {
        request.fields['evidence[$index][requirement_id]'] = _ktpReqId
            .toString();
        request.fields['evidence[$index][list_id]'] = _ktpListId.toString();

        if (_ktpFile != null) {
          // Upload file baru
          if (!await _ktpFile!.exists()) {
            _showFileNotFound();
            return;
          }
          final bytes = await _ktpFile!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'evidence[$index][file]',
              bytes,
              filename: _ktpFile!.path.split('/').last,
            ),
          );
        } else {
          // Dari profil — download via stream
          final docId = _docC.uploadedDocs['ktp/kk']?['id'] ?? '';
          if (docId.isEmpty) {
            Get.snackbar(
              'Gagal',
              'Dokumen KTP tidak ditemukan di profil',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(16),
            );
            if (mounted) setState(() => _isLoading = false);
            return;
          }
          final fileName = _docC.uploadedDocs['ktp/kk']?['file_name'] ?? 'ktp';
          final streamUrl = Uri.parse(
            '${ApiEndpoints.baseUrl}/documents/$docId/stream',
          );
          final fileResp = await http.get(
            streamUrl,
            headers: ApiEndpoints.authHeaders(token!),
          );
          if (fileResp.statusCode == 200) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'evidence[$index][file]',
                fileResp.bodyBytes,
                filename: fileName,
              ),
            );
          } else {
            Get.snackbar(
              'Gagal',
              'Gagal mengambil KTP dari profil',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(16),
            );
            if (mounted) setState(() => _isLoading = false);
            return;
          }
        }
        index++;
      }

      print('[APL01 Bagian 4] URL: $url');
      print('[APL01 Bagian 4] Fields: ${request.fields}');
      print('[APL01 Bagian 4] Files count: ${request.files.length}');
      print('[APL01 Bagian 4] Evidence count: $index');

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print('[APL01 Bagian 4] Status: ${response.statusCode}');
      print('[APL01 Bagian 4] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Berhasil',
          'Form APL-01 berhasil dikirim!',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );
        Get.offAllNamed(AppPages.home);
      } else {
        final bodyStr = response.body.trim();
        String msg = 'Terjadi kesalahan (${response.statusCode})';
        if (bodyStr.isNotEmpty) {
          try {
            msg = jsonDecode(bodyStr)['message'] ?? msg;
          } catch (_) {}
        }
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
    } catch (e) {
      print('[APL01 Bagian 4] Error: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFileNotFound() {
    if (mounted) setState(() => _isLoading = false);
    Get.snackbar(
      'Gagal',
      'File tidak ditemukan, silakan unggah ulang.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  // ─── UI Helpers ───────────────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );

  Widget _stepDot(int num, {bool active = false, bool done = false}) =>
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: (active || done)
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: done
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : Text(
                  '$num',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                ),
        ),
      );

  Widget _stepLine({bool active = false}) => Expanded(
    child: Container(
      height: 3,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _sectionHeader(String title, String subtitle, IconData icon) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // ─── Widget: Dokumen Card ─────────────────────────────────────────────────
  Widget _dokumenCard({
    required String label,
    required String desc,
    required IconData icon,
    required bool fromProfil,
    required bool ready,
    required String? profilLabel,
    required File? uploadFile,
    required VoidCallback onPickFile,
    required VoidCallback onDeleteFile,
  }) {
    final fileName = uploadFile != null ? uploadFile.path.split('/').last : '';
    final isImage = [
      'jpg',
      'jpeg',
      'png',
    ].any((ext) => fileName.toLowerCase().endsWith(ext));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ready ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ready ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
          width: ready ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ready
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: ready
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ready
                              ? const Color(0xFF166534)
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (ready)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
              ],
            ),
          ),

          // Status dari profil
          if (fromProfil && uploadFile == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profilLabel ?? 'Dokumen dari profil',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF166534),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Warning kalau tidak ada di profil dan belum upload
          if (!fromProfil && uploadFile == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dokumen belum tersedia di profil. '
                        'Silakan upload dokumen ini.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Preview file upload
          if (uploadFile != null) ...[
            if (isImage)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    uploadFile,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        size: 18,
                        color: Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1D4ED8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          // Tombol upload
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onPickFile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: uploadFile != null
                            ? Colors.white
                            : const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            uploadFile != null
                                ? Icons.edit_outlined
                                : Icons.upload_file_rounded,
                            size: 16,
                            color: uploadFile != null
                                ? const Color(0xFF4CAF50)
                                : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            uploadFile != null
                                ? 'Ganti File'
                                : fromProfil
                                ? 'Upload Baru'
                                : 'Unggah File',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: uploadFile != null
                                  ? const Color(0xFF4CAF50)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (uploadFile != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDeleteFile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111827),
            size: 18,
          ),
          onPressed: () {
            Get.find<PengajuanController>().fetchPengajuan();
            Get.offAllNamed(AppPages.home);
          },
        ),
        title: const Text(
          'FR.APL.01',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _stepDot(1, done: true),
                      _stepLine(active: true),
                      _stepDot(2, done: true),
                      _stepLine(active: true),
                      _stepDot(3, done: true),
                      _stepLine(active: true),
                      _stepDot(4, active: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bagian 4 dari 4',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Bukti Administratif',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Upload minimal 1 dokumen identitas untuk melengkapi pengajuan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _uploadedCount / 2,
                            backgroundColor: const Color(0xFFE5E7EB),
                            color: const Color(0xFF4CAF50),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$_uploadedCount/2',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Info
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Upload minimal 1 dokumen (Pas Foto atau KTP). '
                      'Dokumen yang sudah ada di profil akan otomatis terisi.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1D4ED8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dokumen Cards
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Bukti Administratif',
                    'Foto & identitas diri',
                    Icons.folder_open_outlined,
                  ),

                  Obx(
                    () => _dokumenCard(
                      label: 'Pas Foto 3×4',
                      desc: 'Background merah, format JPG/PNG.',
                      icon: Icons.portrait_outlined,
                      fromProfil: _pasFotoFromProfil,
                      ready: _pasFotoReady,
                      profilLabel: _docC.uploadedDocs['pas_foto']?['file_name'],
                      uploadFile: _pasFotoFile,
                      onPickFile: _pickPasFoto,
                      onDeleteFile: () => setState(() => _pasFotoFile = null),
                    ),
                  ),

                  Obx(
                    () => _dokumenCard(
                      label: 'KTP',
                      desc: 'Kartu Tanda Penduduk yang masih berlaku.',
                      icon: Icons.badge_outlined,
                      fromProfil: _ktpFromProfil,
                      ready: _ktpReady,
                      profilLabel: _docC.uploadedDocs['ktp/kk']?['file_name'],
                      uploadFile: _ktpFile,
                      onPickFile: _pickKtp,
                      onDeleteFile: () => setState(() => _ktpFile = null),
                    ),
                  ),
                ],
              ),
            ),

            // Info LSP
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rekomendasi dan tanda tangan akan dilengkapi oleh '
                      'petugas LSP setelah pengajuan diterima.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Navigasi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    onPressed: () => Get.back(),
                    label: const Text(
                      'Sebelumnya',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isReady
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFD1D5DB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: (_isLoading || !_isReady) ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isReady ? 'Kirim Form' : 'Belum ada dokumen',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
