import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:lsp_mkc_app/pages/forms/ak/form_ak01_controller.dart';

class FormAk01 extends StatefulWidget {
  final int registrationId;
  const FormAk01({super.key, required this.registrationId});

  @override
  State<FormAk01> createState() => _FormAk01State();
}

class _FormAk01State extends State<FormAk01> {
  final FormAk01Controller c = Get.find<FormAk01Controller>();

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

  // ─── Card ─────────────────────────────────────────────────────────────────
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

  // ─── Section header ───────────────────────────────────────────────────────
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

  // ─── Field ────────────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
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
              keyboardType: type,
              readOnly: readOnly,
              onTap: onTap,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF111827)),
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

  // ─── Dropdown ─────────────────────────────────────────────────────────────
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

  // ─── Bukti checkbox ───────────────────────────────────────────────────────
  Widget _buktiCheckbox(
          String label, RxBool value, IconData icon) =>
      Obx(() => GestureDetector(
            onTap: () => value.value = !value.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: value.value
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: value.value
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE5E7EB),
                  width: value.value ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      size: 16,
                      color: value.value
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF9CA3AF)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: value.value
                                ? const Color(0xFF1B5E20)
                                : const Color(0xFF374151))),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: value.value
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: value.value
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFD1D5DB),
                      ),
                    ),
                    child: value.value
                        ? const Icon(Icons.check_rounded,
                            size: 12, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ));

  // ─── Lainnya dynamic list ─────────────────────────────────────────────────
  Widget _lainnyaSection() => Obx(() {
        if (!c.buktiLainnya.value) return const SizedBox.shrink();
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // List item
                ...List.generate(c.lainnyaList.length, (i) {
                  return Obx(() => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: c.lainnyaList[i],
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF111827)),
                                decoration: InputDecoration(
                                  hintText:
                                      'Bukti lainnya ${i + 1}...',
                                  hintStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFD1D5DB)),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF4CAF50),
                                        width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => c.removeLainnya(i),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.red.shade200),
                                ),
                                child: Icon(Icons.remove_rounded,
                                    size: 16,
                                    color: Colors.red.shade400),
                              ),
                            ),
                          ],
                        ),
                      ));
                }),
                // Tombol tambah
                GestureDetector(
                  onTap: () => c.addLainnya(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF4CAF50)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded,
                            size: 16, color: Color(0xFF4CAF50)),
                        SizedBox(width: 6),
                        Text('Tambah Bukti Lainnya',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4CAF50))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      });

  // ─── Info row (read-only) ─────────────────────────────────────────────────
  Widget _infoRow(String label, String value) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280))),
            ),
            const Text(':  ',
                style: TextStyle(color: Color(0xFF9CA3AF))),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
            ),
          ],
        ),
      );

  // ─── Autofill info box ────────────────────────────────────────────────────
  Widget _autoFillInfo() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: const Row(
          children: [
            Icon(Icons.access_time_rounded,
                size: 16, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tanggal dan waktu akan otomatis terisi sesuai waktu submit.',
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF1E40AF)),
              ),
            ),
          ],
        ),
      );

  // ─── TTD ──────────────────────────────────────────────────────────────────
  Widget _ttdRow(
    BuildContext context, {
    required String role,
    required SignatureController signatureController,
    required Rx<Uint8List?> signatureBytes,
  }) =>
      Container(
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
                        border: Border.all(
                            color: const Color(0xFF4CAF50)),
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
                              size: 14,
                              color: Colors.red.shade400),
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
                    Row(children: [
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
                              final bytes =
                                  await signatureController
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
                    ]),
                  ])),
          ],
        ),
      );

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
        title: const Text('FR.AK.01',
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Persetujuan Asesmen dan Kerahasiaan',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text(
                      'Isi informasi skema, pihak yang terlibat, bukti, pelaksanaan, dan tanda tangan persetujuan.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.5)),
                ],
              ),
            ),

            // ── Skema Sertifikasi ─────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Skema Sertifikasi',
                      Icons.workspace_premium_outlined),
                  _infoRow('Judul', 'Ahli Desain Grafis'),
                  _infoRow('Nomor', 'SUK-SKS-REV1-L007'),
                ],
              ),
            ),

            // ── Pihak yang Terlibat ───────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Pihak yang Terlibat',
                      Icons.people_outline_rounded),
                  _buildDropdown(
                    label: 'TUK',
                    value: c.tukSelected,
                    hint: 'Pilih jenis TUK',
                    items: const [
                      'Sewaktu',
                      'Tempat Kerja',
                      'Mandiri'
                    ],
                  ),
                  _buildField(
                    label: 'Nama Asesi',
                    controller: c.namaAsesi,
                    hint: 'Nama lengkap asesi',
                  ),
                ],
              ),
            ),

            // ── Bukti yang Dikumpulkan ────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Bukti yang Akan Dikumpulkan',
                    Icons.folder_open_outlined,
                    subtitle: 'Pilih satu atau lebih jenis bukti',
                  ),
                  _buktiCheckbox(
                      'Hasil Verifikasi Portofolio',
                      c.buktiVerifikasiPortofolio,
                      Icons.folder_copy_outlined),
                  _buktiCheckbox(
                      'Hasil Reviu Produk',
                      c.buktiReviewProduk,
                      Icons.rate_review_outlined),
                  _buktiCheckbox(
                      'Hasil Observasi Langsung',
                      c.buktiObservasiLangsung,
                      Icons.visibility_outlined),
                  _buktiCheckbox(
                      'Hasil Kegiatan Terstruktur',
                      c.buktiKegiatanTerstruktur,
                      Icons.account_tree_outlined),
                  _buktiCheckbox(
                      'Hasil Tanya Jawab',
                      c.buktiTanyaJawab,
                      Icons.quiz_outlined),
                  _buktiCheckbox(
                      'Lainnya',
                      c.buktiLainnya,
                      Icons.more_horiz_rounded),
                  _lainnyaSection(),
                ],
              ),
            ),

            // ── Pelaksanaan Asesmen ───────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Pelaksanaan Asesmen',
                      Icons.event_note_outlined),
                  _autoFillInfo(),
                  _buildField(
                    label: 'TUK Pelaksanaan',
                    controller: c.tukPelaksanaan,
                    hint: 'Nama TUK pelaksanaan',
                  ),
                ],
              ),
            ),

            // ── Pernyataan Kerahasiaan ────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Pernyataan Kerahasiaan',
                      Icons.lock_outline_rounded),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Asesor :',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF166534))),
                        SizedBox(height: 6),
                        Text(
                          'Menyatakan tidak akan membuka hasil pekerjaan yang saya peroleh karena penugasan saya sebagai Asesor dalam pekerjaan Asesmen kepada siapapun atau organisasi apapun selain kepada pihak yang berwenang sehubungan dengan kewajiban saya sebagai Asesor yang ditugaskan oleh LSP.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151),
                              height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Asesi :',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF166534))),
                        SizedBox(height: 6),
                        Text(
                          'Saya setuju mengikuti asesmen dengan pemahaman bahwa informasi yang dikumpulkan hanya digunakan untuk pengembangan profesional dan hanya dapat diakses oleh orang tertentu saja.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151),
                              height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tanda Tangan ──────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                      'Tanda Tangan', Icons.draw_outlined),
                  _autoFillInfo(),
                  _ttdRow(
                    context,
                    role: 'Tanda Tangan Asesor',
                    signatureController: _ttdAsesor,
                    signatureBytes: c.ttdAsesorBytes,
                  ),
                  _ttdRow(
                    context,
                    role: 'Tanda Tangan Asesi',
                    signatureController: _ttdAsesi,
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
                            final ok = await c.submit(
                                registrationId:
                                    widget.registrationId);
                            if (ok) {
                              Get.back();
                              Get.snackbar(
                                'Berhasil',
                                'FR.AK.01 berhasil disimpan',
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
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 18),
                              SizedBox(width: 8),
                              Text('Simpan',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w600)),
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