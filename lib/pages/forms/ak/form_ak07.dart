import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:lsp_mkc_app/pages/forms/ak/form_ak07_controller.dart';

class FormAk07 extends StatefulWidget {
  const FormAk07({super.key});

  @override
  State<FormAk07> createState() => _FormAk07State();
}

class _FormAk07State extends State<FormAk07> {
  final FormAk07Controller c = Get.find<FormAk07Controller>();

  final SignatureController _ttdAsesor = SignatureController(
    penStrokeWidth: 2,
    penColor: const Color(0xFF111827),
    exportBackgroundColor: Colors.white,
  );
  final SignatureController _ttdAsesi = SignatureController(
    penStrokeWidth: 2,
    penColor: const Color(0xFF111827),
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _ttdAsesor.dispose();
    _ttdAsesi.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
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
                offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );

  Widget _sectionHeader(String title, IconData icon, {String? subtitle}) =>
      Padding(
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
    int maxLines = 1,
  }) =>
      Padding(
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
              readOnly: readOnly,
              onTap: onTap,
              maxLines: maxLines,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF111827)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13, color: Color(0xFFD1D5DB)),
                suffixIcon: suffix,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF4CAF50), width: 1.5),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildDropdown({
    required String label,
    required RxString value,
    required List<String> items,
    String? hint,
  }) =>
      Padding(
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
            Obx(() => DropdownButtonFormField<String>(
                  value: value.value.isEmpty ? null : value.value,
                  hint: Text(hint ?? '',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFD1D5DB))),
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF111827)),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF4CAF50), width: 1.5),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9CA3AF)),
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) value.value = val;
                  },
                )),
          ],
        ),
      );

  // ─── Potensi Asesi checkbox ───────────────────────────────────────────────
  Widget _potensiCheckbox(int index) {
    return Obx(() => GestureDetector(
          onTap: () => c.potensiChecked[index] = !c.potensiChecked[index],
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: c.potensiChecked[index]
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: c.potensiChecked[index]
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE5E7EB),
                width: c.potensiChecked[index] ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: c.potensiChecked[index]
                        ? const Color(0xFF4CAF50)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: c.potensiChecked[index]
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: c.potensiChecked[index]
                      ? const Icon(Icons.check_rounded,
                          size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(c.potensiList[index],
                      style: TextStyle(
                          fontSize: 12,
                          color: c.potensiChecked[index]
                              ? const Color(0xFF1B5E20)
                              : const Color(0xFF374151),
                          height: 1.4)),
                ),
              ],
            ),
          ),
        ));
  }

  // ─── Bagian A row ─────────────────────────────────────────────────────────
  Widget _bagianARow(BagianAItem item) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: No + Pertanyaan + Ya/Tidak ────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // No
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(item.no,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Pertanyaan
                    Expanded(
                      child: Text(item.mengidentifikasi,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151),
                              height: 1.4)),
                    ),
                    const SizedBox(width: 8),
                    // Ya / Tidak buttons
                    Column(
                      children: [
                        _miniYaTidak(true, item.diperlukan),
                        const SizedBox(height: 4),
                        _miniYaTidak(false, item.diperlukan),
                      ],
                    ),
                  ],
                ),
              ),
              // ── Keterangan checkboxes (tampil jika Ya) ────────────────
              if (item.diperlukan.value == true)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Color(0xFFE5E7EB)),
                      const Text('Keterangan:',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50))),
                      const SizedBox(height: 8),
                      ...List.generate(
                        item.keteranganOptions.length,
                        (i) => Obx(() => GestureDetector(
                              onTap: () =>
                                  item.keteranganChecked[i] =
                                      !item.keteranganChecked[i],
                              child: Container(
                                margin:
                                    const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: item.keteranganChecked[i]
                                      ? const Color(0xFFE8F5E9)
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  border: Border.all(
                                    color: item.keteranganChecked[i]
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 150),
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color:
                                            item.keteranganChecked[i]
                                                ? const Color(
                                                    0xFF4CAF50)
                                                : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(3),
                                        border: Border.all(
                                          color:
                                              item.keteranganChecked[i]
                                                  ? const Color(
                                                      0xFF4CAF50)
                                                  : const Color(
                                                      0xFFD1D5DB),
                                        ),
                                      ),
                                      child: item.keteranganChecked[i]
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 10,
                                              color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                          item.keteranganOptions[i],
                                          style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  item.keteranganChecked[
                                                          i]
                                                      ? const Color(
                                                          0xFF1B5E20)
                                                      : const Color(
                                                          0xFF374151),
                                              height: 1.3)),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _miniYaTidak(bool isYa, RxnBool value) {
    final selected = isYa
        ? value.value == true
        : value.value == false;
    return GestureDetector(
      onTap: () => value.value = isYa,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 28,
        decoration: BoxDecoration(
          color: selected
              ? (isYa ? const Color(0xFF4CAF50) : const Color(0xFFEF4444))
              : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? (isYa
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF4444))
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Center(
          child: Text(isYa ? 'YA' : 'TDK',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF9CA3AF))),
        ),
      ),
    );
  }

  // ─── Bagian B row ─────────────────────────────────────────────────────────
  Widget _bagianBRow(int index, BagianBItem item) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text('${index + 1}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.pertanyaan,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF374151),
                            height: 1.4)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      _miniYaTidak(true, item.jawaban),
                      const SizedBox(height: 4),
                      _miniYaTidak(false, item.jawaban),
                    ],
                  ),
                ],
              ),
              // Keputusan penyesuaian (tampil jika Ya)
              if (item.jawaban.value == true) ...[
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFE5E7EB)),
                const Text('Keputusan Penyesuaian:',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: item.keputusan,
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF111827)),
                  decoration: InputDecoration(
                    hintText: 'Tuliskan keputusan penyesuaian...',
                    hintStyle: const TextStyle(
                        fontSize: 12, color: Color(0xFFD1D5DB)),
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
            ],
          ),
        ));
  }

  // ─── TTD ──────────────────────────────────────────────────────────────────
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
              ? Stack(children: [
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
                      child: Image.memory(signatureBytes.value!,
                          fit: BoxFit.contain),
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
                          border:
                              Border.all(color: Colors.red.shade200),
                        ),
                        child: Icon(Icons.refresh_rounded,
                            size: 14, color: Colors.red.shade400),
                      ),
                    ),
                  ),
                ])
              : Column(children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Signature(
                          controller: signatureController,
                          backgroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                        ),
                        icon: const Icon(Icons.clear_rounded,
                            size: 14, color: Color(0xFF9CA3AF)),
                        label: const Text('Hapus',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF))),
                        onPressed: () => signatureController.clear(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                        ),
                        icon: const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white),
                        label: const Text('Simpan TTD',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white)),
                        onPressed: () async {
                          if (signatureController.isNotEmpty) {
                            final bytes =
                                await signatureController.toPngBytes();
                            signatureBytes.value = bytes;
                          } else {
                            Get.snackbar(
                              'Perhatian',
                              'Tanda tangan belum diisi',
                              backgroundColor:
                                  const Color(0xFFFFF3CD),
                              colorText: const Color(0xFF856404),
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        },
                      ),
                    ),
                  ]),
                ])),
          const SizedBox(height: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          ]),
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
        title: const Text('FR.AK.07',
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
                children: const [
                  Text('Ceklis Penyesuaian yang Wajar dan Beralasan',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text(
                      'Formulir penyesuaian asesmen berdasarkan karakteristik dan kebutuhan asesi.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.5)),
                ],
              ),
            ),

            // ── Info Umum ──────────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                      'Informasi Umum', Icons.info_outline_rounded),
                  _buildDropdown(
                    label: 'TUK',
                    value: c.tukSelected,
                    hint: 'Pilih jenis TUK',
                    items: const ['Sewaktu', 'Tempat Kerja', 'Mandiri'],
                  ),
                  _buildField(
                      label: 'Nama Asesor',
                      controller: c.namaAsesor,
                      hint: 'Nama lengkap asesor'),
                  _buildField(
                      label: 'Nama Asesi',
                      controller: c.namaAsesi,
                      hint: 'Nama lengkap asesi'),
                  _buildField(
                    label: 'Tanggal',
                    controller: c.tanggal,
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
                        c.tanggal.text =
                            '${picked.year}-'
                            '${picked.month.toString().padLeft(2, '0')}-'
                            '${picked.day.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                ],
              ),
            ),

            // ── Panduan ───────────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                      'Panduan Bagi Asesor', Icons.menu_book_outlined),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Text(
                      '• Formulir ini digunakan pada saat pelaksanaan pra asesmen ada asesi yang mempunyai keterbatasan sesuai karakteristik yang dimilikinya.\n'
                      '• Formulir ini terdiri dari dua bagian yaitu bagian A dan bagian B.\n'
                      '• Coretlah pada tanda * yang tidak sesuai.\n'
                      '• Berilah tanda √ Ya atau Tidak pada tanda ** sesuai pilihan.\n'
                      '• Berilah tanda √ pada kotak □ pada kolom potensi asesi.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF374151),
                          height: 1.6),
                    ),
                  ),
                ],
              ),
            ),

            // ── Potensi Asesi ─────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Potensi Asesi',
                    Icons.school_outlined,
                    subtitle: 'Pilih satu atau lebih yang sesuai',
                  ),
                  ...List.generate(
                      c.potensiList.length, (i) => _potensiCheckbox(i)),
                ],
              ),
            ),

            // ── Bagian A ──────────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Bagian A — Penyesuaian sesuai Karakteristik Asesi',
                    Icons.tune_outlined,
                    subtitle:
                        'Pilih Ya/Tidak, jika Ya centang keterangan yang sesuai',
                  ),
                  ...c.bagianAItems.map((item) => _bagianARow(item)),
                ],
              ),
            ),

            // ── Bagian B ──────────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Bagian B — Penyesuaian Rencana Asesmen',
                    Icons.checklist_outlined,
                    subtitle:
                        'Sesuai acuan pembanding, potensi asesi dan konteks asesi',
                  ),
                  ...List.generate(c.bagianBItems.length,
                      (i) => _bagianBRow(i, c.bagianBItems[i])),
                ],
              ),
            ),

            // ── Hasil Penyesuaian ──────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                      'Hasil Penyesuaian', Icons.summarize_outlined),
                  // A
                  const Text('A. Hasil penyesuaian sesuai karakteristik asesi',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 10),
                  _buildField(
                      label: '1) Acuan Pembanding Asesmen',
                      controller: c.acuanPembandingA,
                      hint: 'Tuliskan nama acuan pembanding'),
                  _buildField(
                      label: '2) Metode Asesmen',
                      controller: c.metodeAsesmen_A,
                      hint: 'Tuliskan nama metode asesmen'),
                  _buildField(
                      label: '3) Instrumen Asesmen',
                      controller: c.instrumenAsesmen_A,
                      hint: 'Tuliskan nama formulir instrumen asesmen'),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),
                  // B
                  const Text(
                      'B. Hasil penyesuaian rencana asesmen sesuai acuan pembanding, potensi asesi dan konteks asesi',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 10),
                  _buildField(
                      label: '1) Acuan Pembanding Asesmen',
                      controller: c.acuanPembandingB,
                      hint: 'Tuliskan nama acuan pembanding'),
                  _buildField(
                      label: '2) Metode Asesmen',
                      controller: c.metodeAsesmen_B,
                      hint: 'Tuliskan nama metode asesmen'),
                  _buildField(
                      label: '3) Instrumen Asesmen',
                      controller: c.instrumenAsesmen_B,
                      hint: 'Tuliskan nama formulir instrumen asesmen'),
                ],
              ),
            ),

            // ── Tanda Tangan ──────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Tanda Tangan', Icons.draw_outlined),
                  _ttdRow(
                    context,
                    role: 'Tanda Tangan Asesor',
                    signatureController: _ttdAsesor,
                    tanggalController: c.tanggalAsesor,
                    signatureBytes: c.ttdAsesorBytes,
                  ),
                  _ttdRow(
                    context,
                    role: 'Tanda Tangan Asesi',
                    signatureController: _ttdAsesi,
                    tanggalController: c.tanggalAsesi,
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
                                'FR.AK.07 berhasil disimpan',
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