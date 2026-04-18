import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:lsp_mkc_app/pages/forms/ak/form_ak04_controller.dart';

class FormAk04 extends StatefulWidget {
  const FormAk04({super.key});

  @override
  State<FormAk04> createState() => _FormAk04State();
}

class _FormAk04State extends State<FormAk04> {
  final FormAk04Controller c = Get.find<FormAk04Controller>();

  final SignatureController _ttdAsesi = SignatureController(
    penStrokeWidth: 2,
    penColor: const Color(0xFF111827),
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _ttdAsesi.dispose();
    super.dispose();
  }

  // ─── Full-width input ─────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: type,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 13, color: Color(0xFFD1D5DB)),
              suffixIcon: suffix,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section header ───────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                if (subtitle != null)
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

  // ─── Card ─────────────────────────────────────────────────────────────────
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

  // ─── Ya / Tidak row ───────────────────────────────────────────────────────
  Widget _yaTidakRow(String pertanyaan, Rx<bool?> jawaban) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(pertanyaan,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF374151), height: 1.4)),
              ),
              const SizedBox(width: 12),
              // YA
              GestureDetector(
                onTap: () => jawaban.value = true,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 36,
                  decoration: BoxDecoration(
                    color: jawaban.value == true
                        ? const Color(0xFF4CAF50)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: jawaban.value == true
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE5E7EB),
                      width: jawaban.value == true ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text('YA',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: jawaban.value == true
                                ? Colors.white
                                : const Color(0xFF9CA3AF))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // TIDAK
              GestureDetector(
                onTap: () => jawaban.value = false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 54,
                  height: 36,
                  decoration: BoxDecoration(
                    color: jawaban.value == false
                        ? const Color(0xFFEF4444)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: jawaban.value == false
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFE5E7EB),
                      width: jawaban.value == false ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text('TIDAK',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: jawaban.value == false
                                ? Colors.white
                                : const Color(0xFF9CA3AF))),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // ─── TTD real signature ───────────────────────────────────────────────────
  Widget _ttdRow(
    BuildContext context, {
    required String role,
    required SignatureController signatureController,
    required TextEditingController tanggalController,
    required Rx<Uint8List?> signatureBytes,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const SizedBox(height: 12),
          Obx(() => signatureBytes.value != null
              ? Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          signatureBytes.value!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          signatureController.clear();
                          signatureBytes.value = null;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: Colors.red.shade200),
                          ),
                          child: Icon(Icons.refresh_rounded,
                              size: 14, color: Colors.red.shade400),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFE5E7EB)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Signature(
                          controller: signatureController,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                            ),
                            icon: const Icon(Icons.clear_rounded,
                                size: 14,
                                color: Color(0xFF9CA3AF)),
                            label: const Text('Hapus',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF))),
                            onPressed: () =>
                                signatureController.clear(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8)),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                            ),
                            icon: const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white),
                            label: const Text('Simpan TTD',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white)),
                            onPressed: () async {
                              if (signatureController.isNotEmpty) {
                                final bytes = await signatureController
                                    .toPngBytes();
                                signatureBytes.value = bytes;
                              } else {
                                Get.snackbar(
                                  'Perhatian',
                                  'Tanda tangan belum diisi',
                                  backgroundColor:
                                      const Color(0xFFFFF3CD),
                                  colorText:
                                      const Color(0xFF856404),
                                  snackPosition: SnackPosition.TOP,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tanggal',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF))),
              const SizedBox(height: 4),
              TextFormField(
                controller: tanggalController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF4CAF50),
                          onPrimary: Colors.white,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    tanggalController.text =
                        '${picked.year}-'
                        '${picked.month.toString().padLeft(2, '0')}-'
                        '${picked.day.toString().padLeft(2, '0')}';
                  }
                },
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF111827)),
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  hintStyle: const TextStyle(
                      fontSize: 12, color: Color(0xFFD1D5DB)),
                  suffixIcon: const Icon(Icons.calendar_today_rounded,
                      size: 14, color: Color(0xFF9CA3AF)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Color(0xFF4CAF50), width: 1.5),
                  ),
                ),
              ),
            ],
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF111827), size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text('FR.AK.04',
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
            // ── Header ────────────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Banding Asesmen',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  const Text(
                      'Formulir pengajuan banding terhadap keputusan asesmen yang telah dibuat.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.5)),
                ],
              ),
            ),

            // ── Data Asesi & Asesor ───────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                      'Informasi Asesmen', Icons.people_outline_rounded),
                  _buildField(
                    label: 'Nama Asesi',
                    controller: c.namaAsesi,
                    hint: 'Nama lengkap asesi',
                  ),
                  _buildField(
                    label: 'Nama Asesor',
                    controller: c.namaAsesor,
                    hint: 'Nama lengkap asesor',
                  ),
                  _buildField(
                    label: 'Tanggal Asesmen',
                    controller: c.tanggalAsesmen,
                    hint: 'YYYY-MM-DD',
                    readOnly: true,
                    suffix: const Icon(Icons.calendar_today_rounded,
                        size: 14, color: Color(0xFF9CA3AF)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF4CAF50),
                              onPrimary: Colors.white,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        c.tanggalAsesmen.text =
                            '${picked.year}-'
                            '${picked.month.toString().padLeft(2, '0')}-'
                            '${picked.day.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                ],
              ),
            ),

            // ── Pertanyaan Ya/Tidak ───────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Pertanyaan Banding',
                    Icons.quiz_outlined,
                    subtitle: 'Jawab dengan Ya atau Tidak',
                  ),
                  _yaTidakRow(
                    'Apakah Proses Banding telah dijelaskan kepada Anda?',
                    c.jawabanProsesBanding,
                  ),
                  _yaTidakRow(
                    'Apakah Anda telah mendiskusikan Banding dengan Asesor?',
                    c.jawabanDiskusiBanding,
                  ),
                  _yaTidakRow(
                    'Apakah Anda mau melibatkan "orang lain" membantu Anda dalam Proses Banding?',
                    c.jawabanMelibatkanOrang,
                  ),
                ],
              ),
            ),

            // ── Skema Sertifikasi ─────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Skema Sertifikasi',
                    Icons.workspace_premium_outlined,
                    subtitle:
                        'Banding diajukan atas keputusan asesmen terhadap skema berikut',
                  ),
                  _buildField(
                    label: 'Skema Sertifikasi',
                    controller: c.skemaSertifikasi,
                    hint: 'Nama skema sertifikasi',
                  ),
                  _buildField(
                    label: 'No. Skema Sertifikasi',
                    controller: c.noSkemaSertifikasi,
                    hint: 'SUK-SKS-...',
                  ),
                ],
              ),
            ),

            // ── Alasan Banding ────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Alasan Banding',
                    Icons.edit_note_outlined,
                    subtitle: 'Jelaskan alasan pengajuan banding',
                  ),
                  _buildField(
                    label: 'Alasan',
                    controller: c.alasanBanding,
                    hint:
                        'Tuliskan alasan banding secara lengkap dan jelas...',
                    maxLines: 5,
                  ),
                ],
              ),
            ),

            // ── Info hak banding ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFF2563EB)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Anda mempunyai hak mengajukan banding jika Anda menilai Proses Asesmen tidak sesuai SOP dan tidak memenuhi Prinsip Asesmen.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E40AF),
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tanda Tangan Asesi ────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                      'Tanda Tangan', Icons.draw_outlined),
                  _ttdRow(
                    context,
                    role: 'Tanda Tangan Asesi',
                    signatureController: _ttdAsesi,
                    tanggalController: c.tanggalTtd,
                    signatureBytes: c.ttdAsesiBytes,
                  ),
                ],
              ),
            ),

            // ── Tombol Simpan ─────────────────────────────────────────────
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: c.isLoading.value
                        ? null
                        : () async {
                            final ok = await c.submit();
                            if (ok) {
                              Get.back();
                              Get.snackbar(
                                'Berhasil',
                                'FR.AK.04 berhasil disimpan',
                                backgroundColor:
                                    const Color(0xFF4CAF50),
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                    child: c.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Simpan',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}