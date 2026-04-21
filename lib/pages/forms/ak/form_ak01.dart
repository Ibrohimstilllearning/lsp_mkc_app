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

  final SignatureController _ttdAsesi = SignatureController(
    penStrokeWidth: 2,
    penColor: const Color(0xFF111827),
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    c.fetchData(registrationId: widget.registrationId);
  }

  @override
  void dispose() {
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
  Widget _sectionHeader(String title, IconData icon,
          {String? subtitle}) =>
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
              child:
                  Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
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
                            fontSize: 11,
                            color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          ],
        ),
      );

  // ─── Info row read-only ───────────────────────────────────────────────────
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280))),
            ),
            const Text(':  ',
                style: TextStyle(color: Color(0xFF9CA3AF))),
            Expanded(
              child: Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827)),
              ),
            ),
          ],
        ),
      );

  // ─── Evidence item ────────────────────────────────────────────────────────
  Widget _evidenceItem(Map<String, dynamic> item) {
    final bool answer = item['answer'] == true;
    final List? items = item['items'];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: answer
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: answer
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE5E7EB),
          width: answer ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: answer
                      ? const Color(0xFF4CAF50)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: answer
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                child: answer
                    ? const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['label'] ?? '',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: answer
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFF9CA3AF)),
                ),
              ),
            ],
          ),
          if (answer && items != null && items.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...items.map((sub) => Padding(
                  padding:
                      const EdgeInsets.only(left: 28, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right_rounded,
                          size: 14, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(sub.toString(),
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF374151))),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ─── TTD Asesi ────────────────────────────────────────────────────────────
  Widget _ttdAsesiWidget() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tanda Tangan Asesi',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
            const SizedBox(height: 12),
            Obx(() => c.ttdAsesiBytes.value != null
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
                          c.ttdAsesiBytes.value!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          _ttdAsesi.clear();
                          c.ttdAsesiBytes.value = null;
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
                          controller: _ttdAsesi,
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
                          onPressed: () => _ttdAsesi.clear(),
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
                            if (_ttdAsesi.isNotEmpty) {
                              final bytes =
                                  await _ttdAsesi.toPngBytes();
                              c.ttdAsesiBytes.value = bytes;
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

  // ─── Skeleton loading ─────────────────────────────────────────────────────
  Widget _skeleton() => Column(
        children: List.generate(
          4,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 10),
                  Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6))),
                ],
              ),
            ),
          ),
        ),
      );

  // ─── Error state ──────────────────────────────────────────────────────────
  Widget _errorState() {
    final code = c.fetchErrorCode.value;

    String title;
    String subtitle;
    IconData icon;
    Color color;

    switch (code) {
      case 'E2019':
        title = 'Asesor Belum Ditugaskan';
        subtitle =
            'Formulir AK.01 belum tersedia karena asesor belum ditugaskan oleh admin. Silakan tunggu konfirmasi dari LSP.';
        icon = Icons.person_off_outlined;
        color = const Color(0xFFF59E0B);
        break;
      case 'E2018':
        title = 'APL.02 Belum Disetujui';
        subtitle =
            'Formulir AK.01 baru bisa diakses setelah APL.02 kamu disetujui oleh admin.';
        icon = Icons.pending_actions_outlined;
        color = const Color(0xFF3B82F6);
        break;
      case 'E2009':
        title = 'APL.01 Belum Disetujui';
        subtitle =
            'Formulir AK.01 baru bisa diakses setelah APL.01 kamu disetujui oleh admin.';
        icon = Icons.pending_actions_outlined;
        color = const Color(0xFF3B82F6);
        break;
      case 'E1005':
        title = 'Akses Ditolak';
        subtitle =
            'Kamu tidak memiliki akses ke formulir ini.';
        icon = Icons.lock_outline_rounded;
        color = const Color(0xFFEF4444);
        break;
      case 'NETWORK':
        title = 'Koneksi Bermasalah';
        subtitle =
            'Periksa koneksi internet kamu dan coba lagi.';
        icon = Icons.wifi_off_rounded;
        color = const Color(0xFF6B7280);
        break;
      default:
        title = 'Formulir Tidak Tersedia';
        subtitle = c.fetchError.value.isNotEmpty
            ? c.fetchError.value
            : 'Formulir AK.01 belum tersedia saat ini.';
        icon = Icons.description_outlined;
        color = const Color(0xFF6B7280);
    }

    return Column(
      children: [
        // ── Ilustrasi & pesan ──────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
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
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 20),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
              const SizedBox(height: 8),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.5)),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Info tambahan ──────────────────────────────────────────
        Container(
          width: double.infinity,
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
                  'Jika kamu merasa ini adalah kesalahan, silakan hubungi pihak LSP untuk informasi lebih lanjut.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Tombol retry (khusus network error) ───────────────────
        if (code == 'NETWORK') ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 16),
              label: const Text('Coba Lagi',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              onPressed: () =>
                  c.fetchData(registrationId: widget.registrationId),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // ── Tombol kembali ─────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF4CAF50)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF4CAF50), size: 16),
            label: const Text('Kembali',
                style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600)),
            onPressed: () => Get.back(),
          ),
        ),
      ],
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
      body: Obx(() {
        // ── Loading ──────────────────────────────────────────────
        if (c.isLoadingData.value) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _skeleton(),
          );
        }

        // ── Error state ──────────────────────────────────────────
        if (c.fetchError.value.isNotEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _errorState(),
          );
        }

        // ── Normal UI ────────────────────────────────────────────
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────
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
                        'Data di bawah diisi oleh admin. Asesi hanya perlu menandatangani formulir ini.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            height: 1.5)),
                  ],
                ),
              ),

              // ── Skema Sertifikasi ────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Skema Sertifikasi',
                        Icons.workspace_premium_outlined),
                    _infoRow('Judul', c.certificationName.value),
                    _infoRow('Nomor', c.certificationCode.value),
                  ],
                ),
              ),

              // ── Pihak yang Terlibat ──────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Pihak yang Terlibat',
                        Icons.people_outline_rounded),
                    _infoRow('TUK', c.tuk.value),
                    _infoRow('Nama Asesor', c.asesorName.value),
                    _infoRow('Nama Asesi', c.asesiName.value),
                  ],
                ),
              ),

              // ── Bukti yang Dikumpulkan ───────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      'Bukti yang Akan Dikumpulkan',
                      Icons.folder_open_outlined,
                      subtitle: 'Diisi oleh asesor',
                    ),
                    c.evidenceMethods.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text('-',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF))),
                          )
                        : Column(
                            children: c.evidenceMethods
                                .map((item) => _evidenceItem(item))
                                .toList(),
                          ),
                  ],
                ),
              ),

              // ── Pelaksanaan Asesmen ──────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Pelaksanaan Asesmen',
                        Icons.event_note_outlined),
                    _infoRow('Hari / Tanggal', c.agreementDate.value),
                    _infoRow('Waktu', c.agreementTime.value),
                    _infoRow('TUK', c.agreementTuk.value),
                  ],
                ),
              ),

              // ── Pernyataan Kerahasiaan ───────────────────────────
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

              // ── Tanda Tangan Asesi ───────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      'Tanda Tangan',
                      Icons.draw_outlined,
                      subtitle:
                          'Tanggal otomatis terisi saat submit',
                    ),
                    _ttdAsesiWidget(),
                  ],
                ),
              ),

              // ── Tombol Simpan ────────────────────────────────────
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
                                  snackPosition:
                                      SnackPosition.BOTTOM,
                                );
                              }
                            },
                      child: c.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                    Icons
                                        .check_circle_outline_rounded,
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
        );
      }),
    );
  }
}