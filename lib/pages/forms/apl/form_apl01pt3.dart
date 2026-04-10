import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';
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

  final Map<int, File?> _files = {1: null, 2: null, 3: null, 4: null};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _buktiDasar = [
    {
      'requirementId': 1,
      'label': 'Ijazah / Sertifikat Pelatihan',
      'desc': 'Pendidikan minimal SMA/SMK atau sertifikat pelatihan berbasis Kompetensi Tenaga Administrasi Kewirausahaan.',
      'accept': ['jpg', 'jpeg', 'png', 'pdf'],
      'icon': Icons.school_outlined,
    },
    {
      'requirementId': 2,
      'label': 'Surat Pengalaman Kerja',
      'desc': 'Pengalaman kerja minimal 2 tahun di bidang Tenaga Administrasi.',
      'accept': ['jpg', 'jpeg', 'png', 'pdf'],
      'icon': Icons.work_outline_rounded,
    },
  ];

  final List<Map<String, dynamic>> _buktiAdmin = [
    {
      'requirementId': 3,
      'label': 'Pas Foto 3×4',
      'desc': 'Background merah, format JPG/PNG.',
      'accept': ['jpg', 'jpeg', 'png'],
      'icon': Icons.portrait_outlined,
    },
    {
      'requirementId': 4,
      'label': 'KTP',
      'desc': 'Kartu Tanda Penduduk yang masih berlaku.',
      'accept': ['jpg', 'jpeg', 'png', 'pdf'],
      'icon': Icons.badge_outlined,
    },
  ];

  // ─── Picker ───────────────────────────────────────────────────────────────
  Future<void> _pickFile(int requirementId, List<String> accept) async {
    final source = await _showPickerDialog(accept);
    if (source == null) return;

    try {
      if (source == 'camera') {
        final picked = await _picker.pickImage(
            source: ImageSource.camera, imageQuality: 80);
        if (picked != null) {
          setState(() => _files[requirementId] = File(picked.path));
        }
      } else if (source == 'gallery') {
        final picked = await _picker.pickImage(
            source: ImageSource.gallery, imageQuality: 80);
        if (picked != null) {
          setState(() => _files[requirementId] = File(picked.path));
        }
      } else if (source == 'file') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: accept,
        );
        if (result != null && result.files.single.path != null) {
          setState(
              () => _files[requirementId] = File(result.files.single.path!));
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih file: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 10);
    }
  }

  Future<String?> _showPickerDialog(List<String> accept) async {
    final hasPdf = accept.contains('pdf');
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  child: Text('Pilih Sumber File',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: Color(0xFF4CAF50), size: 20),
                ),
                title: const Text('Ambil Foto',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                subtitle: const Text('Buka kamera',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: Color(0xFF4CAF50), size: 20),
                ),
                title: const Text('Pilih dari Galeri',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                subtitle: const Text('Gambar dari galeri',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              if (hasPdf)
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.upload_file_rounded,
                        color: Color(0xFF3B82F6), size: 20),
                  ),
                  title: const Text('Pilih File / PDF',
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: const Text('Dokumen dari penyimpanan',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF))),
                  onTap: () => Navigator.pop(ctx, 'file'),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    for (final entry in _files.entries) {
      if (entry.value == null) {
        Get.snackbar('Belum Lengkap', 'Semua dokumen harus diunggah',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            borderRadius: 10);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
          '${ApiEndpoints.baseUrl}/apl01/bukti-kelengkapan-pemohon');

      final request = http.MultipartRequest('POST', url);

      final headers = token != null
          ? ApiEndpoints.authHeaders(token)
          : ApiEndpoints.headers;
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields['registration_id'] =
          (c.registrationId ?? '').toString();

      int index = 0;
      for (final entry in _files.entries) {
        request.fields['evidence[$index][requirement_id]'] =
            entry.key.toString();
        request.files.add(await http.MultipartFile.fromPath(
          'evidence[$index][file]',
          entry.value!.path,
        ));
        index++;
      }

      print('[APL01 Bagian 3] URL: $url');
      print('[APL01 Bagian 3] Fields: ${request.fields}');

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print('[APL01 Bagian 3] Status: ${response.statusCode}');
      print('[APL01 Bagian 3] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Berhasil', 'Form APL-01 berhasil dikirim!',
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            borderRadius: 10);
        Get.offAllNamed(AppPages.home);
      } else {
        final bodyStr = response.body.trim();
        String msg = 'Terjadi kesalahan (${response.statusCode})';
        if (bodyStr.isNotEmpty) {
          try {
            final json = jsonDecode(bodyStr);
            msg = json['message'] ?? msg;
          } catch (_) {}
        }
        Get.snackbar('Gagal', msg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            borderRadius: 10);
      }
    } catch (e) {
      print('[APL01 Bagian 3] Error: $e');
      Get.snackbar('Gagal', 'Terjadi kesalahan koneksi, coba lagi',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 10);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
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
  }

  Widget _stepDot(int num, {bool active = false, bool done = false}) {
    return Container(
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
            : Text('$num',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        active ? Colors.white : const Color(0xFF9CA3AF))),
      ),
    );
  }

  Widget _stepLine({bool active = false}) {
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color:
              active ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Padding(
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadItem(Map<String, dynamic> item) {
    final int reqId = item['requirementId'] as int;
    final File? file = _files[reqId];
    final bool hasFile = file != null;
    final String fileName =
        hasFile ? file.path.split('/').last : '';
    final bool isImage = hasFile &&
        ['jpg', 'jpeg', 'png']
            .any((ext) => fileName.toLowerCase().endsWith(ext));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: hasFile
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE5E7EB),
          width: hasFile ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hasFile
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item['icon'] as IconData,
                      size: 18,
                      color: hasFile
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF9CA3AF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['label'] as String,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: hasFile
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF111827))),
                      const SizedBox(height: 2),
                      Text(item['desc'] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                              height: 1.4)),
                    ],
                  ),
                ),
                if (hasFile)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50), size: 20),
              ],
            ),
          ),

          // ── Preview gambar ───────────────────────────────────────────
          if (hasFile && isImage)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(file),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // ── Preview PDF ──────────────────────────────────────────────
          if (hasFile && !isImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded,
                        size: 18, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(fileName,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF1D4ED8)),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),

          // ── Tombol ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickFile(
                        reqId,
                        List<String>.from(
                            item['accept'] as List)),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: hasFile
                            ? Colors.white
                            : const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF4CAF50)),
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
                            hasFile ? 'Ganti File' : 'Unggah File',
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
                    onTap: () =>
                        setState(() => _files[reqId] = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Color(0xFFEF4444)),
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
    final uploadedCount =
        _files.values.where((f) => f != null).length;
    final totalCount = _files.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF111827), size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text('FR.APL.01',
            style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w700)),
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
            // ── Progress ────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _stepDot(1, done: true),
                    _stepLine(active: true),
                    _stepDot(2, done: true),
                    _stepLine(active: true),
                    _stepDot(3, active: true),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Bagian 3 dari 3',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50))),
                  const SizedBox(height: 2),
                  const Text('Bukti Kelengkapan Pemohon',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  const Text(
                      'Unggah semua dokumen yang diperlukan untuk melengkapi pengajuan sertifikasi.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: uploadedCount / totalCount,
                            backgroundColor: const Color(0xFFE5E7EB),
                            color: const Color(0xFF4CAF50),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('$uploadedCount/$totalCount',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50))),
                    ],
                  ),
                ],
              ),
            ),

            // ── 3.1 Persyaratan Dasar ────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                      '3.1 Persyaratan Dasar',
                      'Ijazah & pengalaman kerja',
                      Icons.school_outlined),
                  ..._buktiDasar.map((item) => _uploadItem(item)),
                ],
              ),
            ),

            // ── 3.2 Bukti Administratif ──────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                      '3.2 Bukti Administratif',
                      'Foto & identitas diri',
                      Icons.folder_open_outlined),
                  ..._buktiAdmin.map((item) => _uploadItem(item)),
                ],
              ),
            ),

            // ── Info ─────────────────────────────────────────────────
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
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFFD97706)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rekomendasi dan tanda tangan akan dilengkapi oleh petugas LSP setelah pengajuan diterima.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Navigasi ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF4CAF50)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Color(0xFF4CAF50), size: 16),
                    onPressed: () => Get.back(),
                    label: const Text('Sebelumnya',
                        style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: uploadedCount == totalCount
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFD1D5DB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed:
                        (_isLoading || uploadedCount < totalCount)
                            ? null
                            : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                uploadedCount == totalCount
                                    ? 'Kirim Form'
                                    : 'Lengkapi ($uploadedCount/$totalCount)',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
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