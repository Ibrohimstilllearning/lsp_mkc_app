import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/pages/document_controller.dart';
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01_controller.dart';
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01pt4.dart';
<<<<<<< HEAD
=======
import 'package:lsp_mkc_app/pages/document_controller.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';
>>>>>>> fa851aee07189e56c65188bb354f737ea1536690
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormApl01Bagian3 extends StatefulWidget {
  const FormApl01Bagian3({super.key});

  @override
  State<FormApl01Bagian3> createState() => _FormApl01Bagian3State();
}

class _FormApl01Bagian3State extends State<FormApl01Bagian3> {
  final FormApl01Controller c = Get.find<FormApl01Controller>();
  final ImagePicker _picker = ImagePicker();

  // ✅ Tambah DocumentController untuk fetch dari profil
  DocumentController get _docC {
    if (Get.isRegistered<DocumentController>())
      return Get.find<DocumentController>();
    return Get.put(DocumentController());
  }

  final Map<int, File?> _files = {1: null, 2: null, 3: null};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _dokumenWajib = [
    {
      'requirementId': 1,
      'listId': 3,
      'label': 'Ijazah',
      'desc': 'Pendidikan minimal SMA/SMK atau sederajat. Wajib diisi.',
      'accept': ['jpg', 'jpeg', 'png', 'pdf'],
      'icon': Icons.school_outlined,
      'required': true,
      'profileKey': 'ijazah', // ✅ key untuk fetch dari profil
    },
  ];

  final List<Map<String, dynamic>> _dokumenOpsional = [
    {
      'requirementId': 2,
      'listId': 5,
      'label': 'Sertifikat Pelatihan',
      'desc':
          'Sertifikat pelatihan berbasis Kompetensi Tenaga Administrasi Kewirausahaan.',
      'accept': ['jpg', 'jpeg', 'png', 'pdf'],
      'icon': Icons.workspace_premium_outlined,
      'required': false,
      'profileKey': 'sertifikat_pelatihan', // ✅ key untuk fetch dari profil
    },
    {
      'requirementId': 3,
      'listId': 16,
      'label': 'Surat Pengalaman Kerja',
      'desc': 'Pengalaman kerja minimal 2 tahun di bidang Tenaga Administrasi.',
      'accept': ['jpg', 'jpeg', 'png', 'pdf'],
      'icon': Icons.work_outline_rounded,
      'required': false,
      'profileKey': 'surat_pengalaman_kerja', // ✅ key untuk fetch dari profil
    },
  ];

  // ✅ Cek apakah dokumen tersedia dari profil
  bool _isFromProfil(String profileKey) =>
      (_docC.uploadedDocs[profileKey]?['file_url'] ?? '').isNotEmpty;

  // ✅ Validasi: ijazah wajib (dari profil atau upload) + minimal 1 opsional
  bool get _ijazahReady => _files[1] != null || _isFromProfil('ijazah');

  bool get _opsionalUploaded =>
      _files[2] != null ||
      _files[3] != null ||
      _isFromProfil('sertifikat_pelatihan') ||
      _isFromProfil('surat_pengalaman_kerja');

  bool get _isReady => _ijazahReady && _opsionalUploaded;

  Future<void> _pickFile(int requirementId, List<String> accept) async {
    final source = await _showPickerDialog(accept);
    if (source == null) return;

    try {
      if (source == 'camera') {
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (picked != null && mounted) {
          setState(() => _files[requirementId] = File(picked.path));
        }
      } else if (source == 'gallery') {
        final picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (picked != null && mounted) {
          setState(() => _files[requirementId] = File(picked.path));
        }
      } else if (source == 'file') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: accept,
        );
        if (result != null && result.files.single.path != null && mounted) {
          setState(
            () => _files[requirementId] = File(result.files.single.path!),
          );
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
                leading: _pickerIcon(
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
                leading: _pickerIcon(
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
                  leading: _pickerIcon(
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

  Widget _pickerIcon(IconData icon, Color bg, Color fg) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: fg, size: 20),
  );

  // ─── Submit — TIDAK DIUBAH, hanya tambah logika profil ───────────────────
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

    if (!_ijazahReady) {
      Get.snackbar(
        'Belum Lengkap',
        'Ijazah wajib diunggah atau tersedia di profil',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
      return;
    }

    if (!_opsionalUploaded) {
      Get.snackbar(
        'Belum Lengkap',
        'Upload minimal 1 dokumen: Sertifikat Pelatihan atau Surat Pengalaman Kerja',
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

      final allDokumen = [..._dokumenWajib, ..._dokumenOpsional];
      int index = 0;

      for (final item in allDokumen) {
        final int reqId = item['requirementId'] as int;
        final String profileKey = item['profileKey'] as String;
        final int listId = item['listId'] as int;
        final File? file = _files[reqId];
        final bool fromProfil = _isFromProfil(profileKey);

        // Skip jika tidak ada file dan tidak ada di profil
        if (file == null && !fromProfil) continue;

        request.fields['evidence[$index][list_id]'] = listId.toString();

        if (file != null) {
          // ✅ Prioritas: file yang diupload manual
          final exists = await file.exists();
          if (!exists) {
            Get.snackbar(
              'Gagal',
              'File tidak ditemukan, silakan unggah ulang.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(16),
              borderRadius: 10,
            );
            if (mounted) setState(() => _isLoading = false);
            return;
          }
          final bytes = await file.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'evidence[$index][file]',
              bytes,
              filename: file.path.split('/').last,
            ),
          );
        } else {
          // ✅ Dari profil — download via stream
          final docId = _docC.uploadedDocs[profileKey]?['id'] ?? '';
          if (docId.isEmpty) continue;

          final streamUrl = Uri.parse(
            '${ApiEndpoints.baseUrl}/documents/$docId/stream',
          );
          final fileResp = await http.get(
            streamUrl,
            headers: ApiEndpoints.authHeaders(token!),
          );

          if (fileResp.statusCode == 200) {
            final fileName =
                _docC.uploadedDocs[profileKey]?['file_name'] ?? profileKey;
            request.files.add(
              http.MultipartFile.fromBytes(
                'evidence[$index][file]',
                fileResp.bodyBytes,
                filename: fileName,
              ),
            );
          } else {
            // Skip dokumen ini jika gagal download (tidak block submit)
            print(
              '[APL01 Bagian 3] Gagal download $profileKey dari profil: ${fileResp.statusCode}',
            );
            continue;
          }
        }
        index++;
      }

      print('[APL01 Bagian 3] URL: $url');
      print('[APL01 Bagian 3] Fields: ${request.fields}');
      print('[APL01 Bagian 3] Files count: ${request.files.length}');

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
      print('[APL01 Bagian 3] Error: $e');
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

  // ─── Widgets ──────────────────────────────────────────────────────────────
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

  Widget _sectionHeader(
    String title,
    String subtitle,
    IconData icon, {
    Color? color,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF4CAF50)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color ?? const Color(0xFF4CAF50)),
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
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _uploadItem(Map<String, dynamic> item) {
    final int reqId = item['requirementId'] as int;
    final bool isRequired = item['required'] as bool;
    final String profileKey = item['profileKey'] as String;
    final File? file = _files[reqId];
    final bool hasFile = file != null;

    // ✅ Cek dari profil
    final profilDoc = _docC.uploadedDocs[profileKey];
    final bool fromProfil = (profilDoc?['file_url'] ?? '').isNotEmpty;
    final bool ready = hasFile || fromProfil;

    final String fileName = hasFile ? file.path.split('/').last : '';
    final bool isImage =
        hasFile &&
        [
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
                    item['icon'] as IconData,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ready
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF111827),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isRequired
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isRequired ? 'Wajib' : 'Opsional',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isRequired
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF3B82F6),
                              ),
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
                if (ready) ...[
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

          // ✅ Tampilkan badge profil jika dari profil dan tidak ada file manual
          if (fromProfil && !hasFile)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
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
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        profilDoc!['file_name'] ?? 'Dokumen dari profil',
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

          // Preview gambar
          if (hasFile && isImage)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(file),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Preview PDF
          if (hasFile && !isImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
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

          // Tombol upload/hapus
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
                        color: hasFile ? Colors.white : const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasFile
                                ? Icons.edit_outlined
                                : Icons.upload_file_rounded,
                            size: 16,
                            color: hasFile
                                ? const Color(0xFF4CAF50)
                                : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasFile
                                ? 'Ganti File'
                                : fromProfil
                                ? 'Upload Baru'
                                : 'Unggah File',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: hasFile
                                  ? const Color(0xFF4CAF50)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasFile) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _files[reqId] = null),
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
    final wajibCount = _ijazahReady ? 1 : 0;
    final opsionalCount =
        (_files[2] != null || _isFromProfil('sertifikat_pelatihan') ? 1 : 0) +
        (_files[3] != null || _isFromProfil('surat_pengalaman_kerja') ? 1 : 0);
    final totalUploaded = wajibCount + opsionalCount;

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
            // Progress card
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
                    'Unggah ijazah (wajib) dan minimal 1 dokumen pendukung.',
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
                            value: _isReady ? 1.0 : (wajibCount / 2),
                            backgroundColor: const Color(0xFFE5E7EB),
                            color: _isReady
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFBBF24),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isReady ? 'Siap' : '$totalUploaded dokumen',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isReady
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Dokumen Wajib
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Dokumen Wajib',
                    'Harus diisi untuk melanjutkan',
                    Icons.school_outlined,
                  ),
                  Obx(() => _uploadItem(_dokumenWajib[0])),
                ],
              ),
            ),

            // Dokumen Pendukung
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Dokumen Pendukung',
                    'Upload minimal 1 dari 2 dokumen di bawah',
                    Icons.folder_copy_outlined,
                    color: const Color(0xFF3B82F6),
                  ),
                  Obx(() {
                    final opsionalTerpenuhi = _opsionalUploaded;
                    return Container(
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
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bisa upload salah satu atau keduanya',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: opsionalTerpenuhi
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              opsionalTerpenuhi ? '✓ Terpenuhi' : 'Min. 1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: opsionalTerpenuhi
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Obx(() => _uploadItem(_dokumenOpsional[0])),
                  Obx(() => _uploadItem(_dokumenOpsional[1])),
                ],
              ),
            ),

            // Info
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
                  child: Obx(
                    () => ElevatedButton(
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
                                  _isReady
                                      ? 'Selanjutnya'
                                      : !_ijazahReady
                                      ? 'Upload Ijazah Dulu'
                                      : 'Upload Min. 1 Dokumen',
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
