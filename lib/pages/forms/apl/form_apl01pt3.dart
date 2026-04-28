import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01_controller.dart';
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01pt4.dart';
import 'package:lsp_mkc_app/pages/document_controller.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum sumber dokumen
enum DocSource { profil, upload }

class FormApl01Bagian3 extends StatefulWidget {
  const FormApl01Bagian3({super.key});

  @override
  State<FormApl01Bagian3> createState() => _FormApl01Bagian3State();
}

class _FormApl01Bagian3State extends State<FormApl01Bagian3> {
  final FormApl01Controller c = Get.find<FormApl01Controller>();
  final ImagePicker _picker = ImagePicker();

  // ── Ambil DocumentController (sudah di-register sebelumnya) ──────────────
  DocumentController get _docC {
    if (Get.isRegistered<DocumentController>()) {
      return Get.find<DocumentController>();
    }
    return Get.put(DocumentController());
  }

  // ── State pilihan dokumen ─────────────────────────────────────────────────
  int? _selectedRequirementId;

  // Per requirementId: sumber dokumen (profil atau upload baru)
  final Map<int, DocSource> _docSource = {};

  // File upload baru per requirementId
  final Map<int, File?> _uploadedFiles = {};

  bool _isLoading = false;

  final List<Map<String, dynamic>> _buktiDasar = [
    {
      'requirementId': 1,
      'listId': 3,
      'profileKey': 'ijazah', // ← key di DocumentController.uploadedDocs
      'label': 'Ijazah / Sertifikat Pelatihan',
      'desc':
          'Pendidikan minimal SMA/SMK atau sertifikat pelatihan berbasis Kompetensi Tenaga Administrasi Kewirausahaan.',
      'accept': ['jpg', 'jpeg', 'png', 'pdf'],
      'icon': Icons.school_outlined,
    },
    {
      'requirementId': 2,
      'listId': 16,
      'profileKey': 'surat_pengalaman_kerja',
      'label': 'Surat Pengalaman Kerja',
      'desc': 'Pengalaman kerja minimal 2 tahun di bidang Tenaga Administrasi.',
      'accept': ['jpg', 'jpeg', 'png', 'pdf'],
      'icon': Icons.work_outline_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Set default dulu ke upload
    for (final item in _buktiDasar) {
      final reqId = item['requirementId'] as int;
      _docSource[reqId] = DocSource.upload;
    }

    // Fetch ulang data profil, lalu update source
    _docC.fetchDokumenFromProfile().then((_) {
      if (mounted) {
        setState(() {
          for (final item in _buktiDasar) {
            final reqId = item['requirementId'] as int;
            final profileKey = item['profileKey'] as String;
            final hasDoc = _hasProfileDoc(profileKey);
            print(
              '[DEBUG PT3] key: $profileKey → hasDoc: $hasDoc → data: ${_docC.uploadedDocs[profileKey]}',
            );
            if (hasDoc) _docSource[reqId] = DocSource.profil;
          }
        });
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  bool _hasProfileDoc(String profileKey) =>
      _docC.uploadedDocs.containsKey(profileKey) &&
      (_docC.uploadedDocs[profileKey]?['file_name'] ?? '').isNotEmpty;

  bool get _isReady {
    if (_selectedRequirementId == null) return false;
    final item = _buktiDasar.firstWhere(
      (e) => e['requirementId'] == _selectedRequirementId,
    );
    final reqId = _selectedRequirementId!;
    final source = _docSource[reqId] ?? DocSource.upload;
    if (source == DocSource.profil) {
      return _hasProfileDoc(item['profileKey'] as String);
    }
    return _uploadedFiles[reqId] != null;
  }

  void _selectType(int requirementId) {
    if (_selectedRequirementId != requirementId) {
      setState(() => _selectedRequirementId = requirementId);
    }
  }

  // ── Picker ────────────────────────────────────────────────────────────────
  Future<void> _pickFile(int reqId, List<String> accept) async {
    final source = await _showPickerDialog(accept);
    if (source == null) return;

    try {
      File? file;
      if (source == 'camera') {
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (picked != null) file = File(picked.path);
      } else if (source == 'gallery') {
        final picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (picked != null) file = File(picked.path);
      } else if (source == 'file') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: accept,
        );
        if (result != null && result.files.single.path != null) {
          file = File(result.files.single.path!);
        }
      }
      if (file != null && mounted) {
        setState(() => _uploadedFiles[reqId] = file);
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
                leading: _pickerIconBox(
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
                leading: _pickerIconBox(
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
                  leading: _pickerIconBox(
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

  Widget _pickerIconBox(IconData icon, Color bg, Color fg) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: fg, size: 20),
  );

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (c.registrationId == null) {
      Get.snackbar(
        'Error',
        'Registration ID tidak ditemukan, silakan ulangi dari awal',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (!_isReady) {
      Get.snackbar(
        'Belum Lengkap',
        'Pilih jenis dokumen dan pastikan dokumen tersedia',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}/apl01/bukti-persyaratan-dasar',
      );
      final request = http.MultipartRequest('POST', url);

      final rawHeaders = token != null
          ? ApiEndpoints.authHeaders(token)
          : ApiEndpoints.headers;
      final headers = Map<String, String>.from(rawHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields['registration_id'] = (c.registrationId ?? '').toString();

      final itemData = _buktiDasar.firstWhere(
        (e) => e['requirementId'] == _selectedRequirementId,
      );
      final reqId = _selectedRequirementId!;
      final listId = itemData['listId'] as int;
      final profileKey = itemData['profileKey'] as String;
      final source = _docSource[reqId] ?? DocSource.upload;

      request.fields['evidence[0][requirement_id]'] = reqId.toString();
      request.fields['evidence[0][list_id]'] = listId.toString();

      if (source == DocSource.profil) {
        final docId = _docC.uploadedDocs[profileKey]?['id'] ?? '';
        final fileName =
            _docC.uploadedDocs[profileKey]?['file_name'] ?? 'document';

        print('[DEBUG STREAM] docId: $docId');
        print('[DEBUG STREAM] token: $token');

        final streamUrl = Uri.parse(
          '${ApiEndpoints.baseUrl}/documents/$docId/stream',
        );
        print('[DEBUG STREAM] url: $streamUrl');

        final fileResponse = await http.get(
          streamUrl,
          headers: ApiEndpoints.authHeaders(token!),
        );

        print('[DEBUG STREAM] status: ${fileResponse.statusCode}');
        print('[DEBUG STREAM] bytes length: ${fileResponse.bodyBytes.length}');
        print('[DEBUG STREAM] body: ${fileResponse.body}');
        print(
          '[DEBUG STREAM] content-type: ${fileResponse.headers['content-type']}',
        );

        if (fileResponse.statusCode == 200) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'evidence[0][file]',
              fileResponse.bodyBytes,
              filename: fileName,
            ),
          );
        } else {
          Get.snackbar(
            'Gagal',
            'Gagal mengambil dokumen dari profil',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
          );
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      } else {
        // ✅ TAMBAHKAN INI — upload file baru
        final file = _uploadedFiles[reqId];
        if (file == null) {
          Get.snackbar(
            'Belum Lengkap',
            'Silakan unggah file terlebih dahulu',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
          );
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        if (!await file.exists()) {
          Get.snackbar(
            'Gagal',
            'File tidak ditemukan, silakan unggah ulang.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
          );
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        final bytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'evidence[0][file]',
            bytes,
            filename: file.path.split('/').last,
          ),
        );
      }

      print('[APL01 Bagian 3] URL: $url');
      print('[APL01 Bagian 3] Fields: ${request.fields}');

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print('[APL01 Bagian 3] Status: ${response.statusCode}');
      print('[APL01 Bagian 3] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.to(() => const FormApl01Bagian4());
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
      print('[APL01 Bagian 3] Error: ${e.toString()}');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: ${e.toString()}',
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

  // ── Widgets ───────────────────────────────────────────────────────────────
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

  // ── Doc option item dengan auto-fill dari profil ──────────────────────────
  Widget _docOptionItem(Map<String, dynamic> item) {
    final int reqId = item['requirementId'] as int;
    final String profileKey = item['profileKey'] as String;
    final bool isSelected = _selectedRequirementId == reqId;
    final bool hasProfileDoc = _hasProfileDoc(profileKey);
    final DocSource source = _docSource[reqId] ?? DocSource.upload;
    final bool isUsingProfil = source == DocSource.profil;
    final File? uploadedFile = _uploadedFiles[reqId];
    final bool hasUploadedFile = uploadedFile != null;

    // Card dianggap ready jika: pakai profil (dan ada) ATAU sudah upload file
    final bool itemReady =
        isSelected && (isUsingProfil ? hasProfileDoc : hasUploadedFile);

    final String? profileFileName =
        _docC.uploadedDocs[profileKey]?['file_name'];
    final String? profileFileUrl = _docC.uploadedDocs[profileKey]?['file_url'];

    return GestureDetector(
      onTap: () => _selectType(reqId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: itemReady
              ? const Color(0xFFF0FDF4)
              : isSelected
              ? const Color(0xFFF0FDF4)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Radio dot
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFD1D5DB),
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF111827),
                                ),
                              ),
                            ),
                            // Badge "Ada di Profil"
                            if (hasProfileDoc)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cloud_done_rounded,
                                      size: 10,
                                      color: Color(0xFF16A34A),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Ada di Profil',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF16A34A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['desc'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (itemReady) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),

            // ── Area konten (hanya tampil saat dipilih) ───────────────────
            if (isSelected) ...[
              // Toggle sumber: pakai profil vs upload baru
              if (hasProfileDoc)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _sourceToggle(
                          label: 'Gunakan dari Profil',
                          icon: Icons.cloud_done_rounded,
                          selected: isUsingProfil,
                          onTap: () => setState(
                            () => _docSource[reqId] = DocSource.profil,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _sourceToggle(
                          label: 'Upload Baru',
                          icon: Icons.upload_rounded,
                          selected: !isUsingProfil,
                          onTap: () => setState(
                            () => _docSource[reqId] = DocSource.upload,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Preview dokumen profil ───────────────────────────────────
              if (isUsingProfil && hasProfileDoc) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.insert_drive_file_rounded,
                            size: 18,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dokumen dari Profil',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF166534),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profileFileName ?? profileFileUrl ?? '-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4CAF50),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF4CAF50),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Upload file baru ─────────────────────────────────────────
              if (!isUsingProfil) ...[
                if (hasUploadedFile) ...[_buildFilePreview(uploadedFile!)],
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickFile(
                            reqId,
                            List<String>.from(item['accept'] as List),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: hasUploadedFile
                                  ? Colors.white
                                  : const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  hasUploadedFile
                                      ? Icons.edit_outlined
                                      : Icons.upload_file_rounded,
                                  size: 16,
                                  color: hasUploadedFile
                                      ? const Color(0xFF4CAF50)
                                      : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  hasUploadedFile
                                      ? 'Ganti File'
                                      : 'Unggah File',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: hasUploadedFile
                                        ? const Color(0xFF4CAF50)
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (hasUploadedFile) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _uploadedFiles[reqId] = null),
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _sourceToggle({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildFilePreview(File file) {
    final fileName = file.path.split('/').last;
    final isImage = [
      'jpg',
      'jpeg',
      'png',
    ].any((ext) => fileName.toLowerCase().endsWith(ext));

    if (isImage) {
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                style: const TextStyle(fontSize: 12, color: Color(0xFF1D4ED8)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
          onPressed: () => Get.back(),
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
            // ── Progress card ─────────────────────────────────────────────
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
                      _stepDot(3, active: true),
                      _stepLine(),
                      _stepDot(4),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bagian 3 dari 4',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Bukti Persyaratan Dasar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih salah satu dokumen persyaratan dan unggah filenya.',
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
                            value: _isReady ? 1.0 : 0.0,
                            backgroundColor: const Color(0xFFE5E7EB),
                            color: const Color(0xFF4CAF50),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isReady ? '1/1' : '0/1',
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

            // ── Pilihan dokumen ───────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Persyaratan Dasar',
                    'Pilih salah satu dokumen di bawah ini',
                    Icons.school_outlined,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: Color(0xFF3B82F6),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pilih salah satu: Ijazah atau Surat Pengalaman Kerja. Dokumen yang sudah ada di profil akan otomatis terisi.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ Obx agar reaktif saat uploadedDocs berubah
                  Obx(
                    () => Column(
                      children: _buktiDasar
                          .map((item) => _docOptionItem(item))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info lanjut ───────────────────────────────────────────────
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
                      'Setelah ini Anda akan melanjutkan ke unggah bukti administratif.',
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

            // ── Tombol navigasi ───────────────────────────────────────────
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
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isReady ? 'Selanjutnya' : 'Pilih Dokumen Dulu',
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
