import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01_controller.dart';
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01pt3.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class FormApl01Bagian2 extends StatelessWidget {
  final FormApl01Controller c = Get.find<FormApl01Controller>();

  final List<Map<String, String>> unitKompetensi = [
    {
      "no": "1",
      "kode": "M.741000.004.01",
      "judul": "Melakukan survey sumber bahan baku dan bahan pembantu",
    },
    {
      "no": "2",
      "kode": "M.741000.006.01",
      "judul": "Menentukan jenis produk yang akan diusahakan",
    },
    {
      "no": "3",
      "kode": "M.741000.008.01",
      "judul": "Melakukan pengurusan perijinan usaha industri",
    },
    {
      "no": "4",
      "kode": "M.741000.014.01",
      "judul": "Membuat jadwal kerja personil bagian produksi",
    },
    {
      "no": "5",
      "kode": "M.741000.019.01",
      "judul":
          "Melakukan pengaturan penyimpanan bahan baku, bahan pembantu, produk antara dan produk akhir",
    },
    {
      "no": "6",
      "kode": "M.741000.026.01",
      "judul": "Menjalin hubungan dengan pelanggan",
    },
    {
      "no": "7",
      "kode": "M.741000.027.01",
      "judul": "Melakukan pembukuan keuangan untuk setiap transaksi",
    },
    {
      "no": "8",
      "kode": "N.821100.001.02",
      "judul": "Menangani Penerimaan dan Pengiriman Dokumen/Surat",
    },
    {
      "no": "9",
      "kode": "N.821100.067.01",
      "judul": "Melakukan Transaksi Perbankan Sederhana",
    },
  ];

  final List<Map<String, String>> tujuanOptions = [
    {"value": "sertifikasi", "label": "Sertifikasi"},
    {
      "value": "pengakuan_kompetensi_terkini",
      "label": "Pengakuan Kompetensi Terkini (PKT)",
    },
    {
      "value": "rekognisi_pembelajaran_lampau",
      "label": "Rekognisi Pembelajaran Lampau (RPL)",
    },
    {"value": "lainnya", "label": "Lainnya"},
  ];

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
        color: done
            ? const Color(0xFF4CAF50)
            : active
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : Text(
                "$num",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF9CA3AF),
                ),
              ),
      ),
    );
  }

  Widget _stepLine({bool active = false}) {
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2),
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
          onPressed: () {
            Get.find<PengajuanController>().fetchPengajuan();
            Get.offAllNamed(AppPages.home);
          },
        ),
        title: const Text(
          "FR.APL.01",
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
            // ── Progress ────────────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _stepDot(1, done: true),
                    _stepLine(active: true),
                    _stepDot(2, active: true),
                    _stepLine(active: true),
                    _stepDot(3),
                    _stepLine(),
                    _stepDot(4),
                  ]),
                  const SizedBox(height: 12),
                  const Text(
                    'Bagian 2 dari 4',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Data Sertifikasi",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tuliskan judul dan nomor skema sertifikasi beserta daftar unit kompetensi.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Skema Sertifikasi ────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Skema Sertifikasi",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Judul Skema",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 1,
                          height: 36,
                          child: VerticalDivider(
                            color: Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: Text(
                            "Tenaga Administrasi Kewirausahaan",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            "Nomor Skema",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 1,
                          height: 36,
                          child: VerticalDivider(
                            color: Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "SUK-SKS-REV1-L007",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tujuan Asesmen (RADIO - hanya 1 pilihan) ────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.track_changes_rounded,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Tujuan Asesmen",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Pilih satu tujuan asesmen", // ✅ ubah teks
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 14),
                  ...tujuanOptions.map(
                    (opt) => Obx(() {
                      final value = opt["value"]!;
                      final label = opt["label"]!;
                      // ✅ selected = hanya 1 yang dipilih
                      final selected = c.tujuanAsesmen.isNotEmpty &&
                          c.tujuanAsesmen.first == value;
                      return GestureDetector(
                        // ✅ selectTujuan: clear dulu, baru set 1 nilai
                        onTap: () => c.selectTujuan(value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFE5E7EB),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // ✅ Ganti checkbox → radio button style
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFD1D5DB),
                                    width: selected ? 2 : 1.5,
                                  ),
                                ),
                                child: selected
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF4CAF50),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // ── Daftar Unit Kompetensi ───────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.list_alt_rounded,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Daftar Unit Kompetensi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Sesuai kemasan skema sertifikasi",
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 14),
                  ...unitKompetensi.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                item["no"]!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["kode"]!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item["judul"]!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Navigasi ────────────────────────────────────────────────────
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
                      "Sebelumnya",
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
                    () => ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: c.isLoadingBagian2.value
                          ? null
                          : () async {
                              final ok = await c.submitBagian2();
                              if (ok) Get.to(() => FormApl01Bagian3());
                            },
                      icon: c.isLoadingBagian2.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                      label: const Text(
                        "Selanjutnya",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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