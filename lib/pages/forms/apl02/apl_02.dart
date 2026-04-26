import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/portfolio.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'apl02_controller.dart';
import 'model/required_document.dart';

class FormApl02 extends StatelessWidget {
  final int registrationId;

  const FormApl02({super.key, required this.registrationId});

  @override
  Widget build(BuildContext context) {
    // Gunakan Get.put dengan tag agar tidak bentrok jika controller sudah ada
    final Apl02Controller c = Get.put(Apl02Controller(), tag: 'apl02');

    // Fetch data saat pertama kali atau jika registrationId berbeda
    if (c.apl02Data.value?.registrationId != registrationId &&
        !c.isLoading.value) {
      Future.microtask(() => c.fetchData(registrationId));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDFEDD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDFEDD8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Kembali ke beranda',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        actions: [
          // Tombol Select All
          Obx(() => c.apl02Data.value != null
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) {
                    if (value == 'all_k') {
                      c.selectAll();
                      Get.snackbar('Info', 'Semua kriteria ditandai K',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF4CAF50),
                          colorText: Colors.white);
                    } else if (value == 'all_bk') {
                      c.selectAllNotCompetent();
                      Get.snackbar('Info', 'Semua kriteria ditandai BK',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'all_k',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Color(0xFF4CAF50), size: 18),
                          SizedBox(width: 8),
                          Text('Pilih Semua Kompeten (K)',
                              style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'all_bk',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Pilih Semua Belum Kompeten (BK)',
                              style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
          );
        }

        if (c.apl02Data.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 56, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Data FR.APL.02 tidak ditemukan',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Tampilkan error dari server
                  Obx(() => c.lastError.value.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            'Server: ${c.lastError.value}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.red[700]),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const Text(
                          'Pastikan APL-01 sudah disetujui admin.',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey),
                          textAlign: TextAlign.center,
                        )),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => c.fetchData(registrationId),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Coba Lagi',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        // Show competency dialog once after data loads
        if (!c.competencyDialogShown.value) {
          Future.microtask(() => c.showCompetencyDialog());
        }

        final data = c.apl02Data.value!;
        final scheme = data.scheme;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FR.APL.02. ASESMEN MANDIRI',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Skema Sertifikasi: ${scheme.name}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kode: ${scheme.code}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Tinjau kembali kriteria unjuk kerja dan tandai 'K' jika kompeten atau 'BK' jika belum kompeten.",
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          // Progress indicator
                          Obx(() {
                            final answered = c.answeredCriteria;
                            final total = c.totalCriteria;
                            final progress =
                                total > 0 ? answered / total : 0.0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress: $answered/$total kriteria',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                    Text(
                                      '${(progress * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey[200],
                                    color: const Color(0xFF4CAF50),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Portfolio / Bukti Dokumen Section ──────────────────────
              _buildPortfolioSection(c, data.portfolios),

              const SizedBox(height: 16),

              // ── Loop Unit ───────────────────────────────────────────────
              ...scheme.units.map((unit) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kode Unit: ${unit.unitCode}',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[700]),
                      ),
                      Text(
                        'Judul Unit: ${unit.unitTitle}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Divider(color: Colors.grey[300], thickness: 0.8),

                      // ── Loop Element ───────────────────────────────────
                      ...unit.elements.map((element) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(top: 8, bottom: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Elemen: ${element.title}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // ── Loop Kriteria ──────────────────────────
                              ...element.criteria.map((criterion) {
                                return Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9F9),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87)),
                                          Expanded(
                                            child: Text(
                                              criterion.name,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12, top: 4),
                                        child: Text(
                                          criterion.description,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      // Radio K / BK per kriteria
                                      Obx(() => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              const Text(
                                                'Penilaian:',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Row(
                                                children: [
                                                  Radio<bool>(
                                                    value: true,
                                                    groupValue: c.userAnswer[
                                                        criterion.id],
                                                    onChanged: (val) =>
                                                        c.setAnswer(
                                                            criterion.id,
                                                            val!),
                                                    activeColor:
                                                        const Color(
                                                            0xFF4CAF50),
                                                  ),
                                                  const Text('K',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600)),
                                                  const SizedBox(width: 8),
                                                  Radio<bool>(
                                                    value: false,
                                                    groupValue: c.userAnswer[
                                                        criterion.id],
                                                    onChanged: (val) =>
                                                        c.setAnswer(
                                                            criterion.id,
                                                            val!),
                                                    activeColor:
                                                        Colors.red[400],
                                                  ),
                                                  Text('BK',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .red[700])),
                                                ],
                                              ),
                                            ],
                                          )),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // ── QR Code Section (pengganti tanda tangan) ─────────────
              _buildQrCodeSection(data),

              const SizedBox(height: 16),

              // ── Submit Button ────────────────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: c.isSubmitting.value
                          ? null
                          : () {
                              // Validasi semua kriteria telah diisi
                              bool isComplete = true;
                              for (var unit in scheme.units) {
                                for (var element in unit.elements) {
                                  for (var criterion in element.criteria) {
                                    if (!c.userAnswer
                                        .containsKey(criterion.id)) {
                                      isComplete = false;
                                      break;
                                    }
                                  }
                                  if (!isComplete) break;
                                }
                                if (!isComplete) break;
                              }

                              if (!isComplete) {
                                Get.snackbar(
                                  'Belum Lengkap',
                                  'Harap isi semua kriteria dengan K atau BK sebelum menyimpan.',
                                  backgroundColor: Colors.orange[400],
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 3),
                                );
                                return;
                              }

                              c.submitForm();
                            },
                      child: c.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Simpan & Submit APL-02',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
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

  // ══════════════════════════════════════════════════════════════════════
  // PORTFOLIO / BUKTI DOKUMEN SECTION (Compact Card + Bottom Sheet)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildPortfolioSection(Apl02Controller c, List<Portfolio> portfolios) {
    return Obx(() {
      final docs = c.requiredDocuments;

      // Saat data belum selesai di-fetch
      if (c.isLoadingDocs.value && docs.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF4CAF50),
                ),
              ),
              SizedBox(width: 12),
              Text('Memuat daftar dokumen...',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        );
      }

      if (docs.isEmpty) return const SizedBox.shrink();

      final uploaded = docs.where((d) => d.isUploaded).length;
      final total = docs.length;
      final allUploaded = uploaded == total;
      final progress = total > 0 ? uploaded / total : 0.0;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: allUploaded
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF8F00),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    allUploaded ? Icons.task_alt : Icons.folder_open,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Bukti Dokumen Portfolio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Tombol refresh daftar dokumen
                  Obx(() => c.isLoadingDocs.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : GestureDetector(
                          onTap: () => c.refreshDocuments(),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        )),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$uploaded/$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ringkas ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badge sumber data ─────────────────────────────────
                  Obx(() {
                    final src = c.portfolioDataSource.value;
                    if (src == 0) return const SizedBox.shrink();

                    final (label, icon, color, bg) = switch (src) {
                      1 => (
                          'Data API Skema',
                          Icons.cloud_done,
                          const Color(0xFF2E7D32),
                          const Color(0xFFE8F5E9)
                        ),
                      2 => (
                          'Data API (filter skema)',
                          Icons.cloud_done,
                          const Color(0xFF1565C0),
                          const Color(0xFFE3F2FD)
                        ),
                      3 => (
                          'Data Statis (offline)',
                          Icons.offline_bolt,
                          const Color(0xFFE65100),
                          const Color(0xFFFFF3E0)
                        ),
                      _ => (
                          'Data APL02 saja',
                          Icons.folder,
                          Colors.grey,
                          const Color(0xFFF5F5F5)
                        ),
                    };

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: color.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 12, color: color),
                              const SizedBox(width: 4),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Peringatan jika pakai data statis
                        if (src == 3) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFFF8F00)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 13,
                                    color: Color(0xFFE65100)),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Daftar ini berdasarkan data statis. '
                                    'Backend sedang diperbaiki untuk filter per skema.',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFE65100)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                      ],
                    );
                  }),

                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            color: allUploaded
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF8F00),
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: allUploaded
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF8F00),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Status chips
                  Row(
                    children: [
                      _statusChip(
                        icon: Icons.check_circle,
                        label: '$uploaded Terupload',
                        color: const Color(0xFF4CAF50),
                        bg: const Color(0xFFE8F5E9),
                      ),
                      const SizedBox(width: 8),
                      if (!allUploaded)
                        _statusChip(
                          icon: Icons.cancel,
                          label: '${total - uploaded} Belum',
                          color: Colors.red,
                          bg: const Color(0xFFFFEBEE),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Tombol buka bottom sheet ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: allUploaded
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF8F00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                      ),
                      onPressed: () => _showPortfolioBottomSheet(c, docs),
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: Text(
                        allUploaded
                            ? 'Lihat & Perbarui Dokumen ($total)'
                            : 'Upload Dokumen Portfolio ($total)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      );
    });
  }

  /// Status chip kecil
  Widget _statusChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Buka bottom sheet upload dokumen
  void _showPortfolioBottomSheet(
      Apl02Controller c, List<RequiredDocument> docs) {
    Get.bottomSheet(
      _PortfolioBottomSheet(c: c, docs: docs),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }


  // ══════════════════════════════════════════════════════════════════════
  // QR CODE SECTION (Pengganti Tanda Tangan)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildQrCodeSection(dynamic data) {
    // QR data: Registration ID + scheme name + timestamp
    final qrData =
        'LSP-MKC|REG:${data.registrationId}|SKEMA:${data.scheme.name}|DATE:${DateTime.now().toIso8601String().substring(0, 10)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Tanda Tangan Digital',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'QR Code ini menggantikan tanda tangan manual',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 160,
              gapless: true,
              embeddedImage: null,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'REG-${data.registrationId} • ${DateTime.now().toIso8601String().substring(0, 10)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// _PortfolioBottomSheet — modal sheet untuk upload dokumen portfolio
// ══════════════════════════════════════════════════════════════════════
class _PortfolioBottomSheet extends StatelessWidget {
  final Apl02Controller c;
  final List<RequiredDocument> docs;

  const _PortfolioBottomSheet({
    required this.c,
    required this.docs,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Ambil data terbaru dari controller (auto-update setelah upload)
      final currentDocs = c.requiredDocuments.isNotEmpty
          ? c.requiredDocuments
          : docs;

      final uploaded = currentDocs.where((d) => d.isUploaded).length;
      final total = currentDocs.length;
      final allUploaded = uploaded == total;

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────────────
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),

            // ── Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              decoration: BoxDecoration(
                color: allUploaded
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF8F00),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    allUploaded ? Icons.task_alt : Icons.upload_file,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Dokumen Portfolio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$uploaded dari $total dokumen terupload',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: total > 0 ? uploaded / total : 0.0,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.3),
                          color: Colors.white,
                          strokeWidth: 3.5,
                        ),
                        Center(
                          child: Text(
                            '${total > 0 ? ((uploaded / total) * 100).toInt() : 0}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Info banner ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue[700], size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Semua dokumen yang dibutuhkan skema ditampilkan di sini. '
                      'Upload hasil scan / foto bukti dokumen Anda.',
                      style: TextStyle(
                          fontSize: 11, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),

            // ── Loading indicator saat fetch ─────────────────────────
            if (c.isLoadingDocs.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(
                  color: Color(0xFF4CAF50),
                  backgroundColor: Color(0xFFE8F5E9),
                ),
              ),

            // ── List dokumen (scrollable) ────────────────────────────
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: currentDocs.length,
                itemBuilder: (context, index) {
                  return _PortfolioItemTile(
                    c: c,
                    doc: currentDocs[index],
                    number: index + 1,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════
// _PortfolioItemTile — item baris dokumen di dalam bottom sheet
// ══════════════════════════════════════════════════════════════════════
class _PortfolioItemTile extends StatelessWidget {
  final Apl02Controller c;
  final RequiredDocument doc;
  final int number;

  const _PortfolioItemTile({
    required this.c,
    required this.doc,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isUploaded = doc.isUploaded;
      final isUploading = c.uploadingListIds.contains(doc.listId);

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isUploaded
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded
                ? const Color(0xFF4CAF50).withValues(alpha: 0.35)
                : const Color(0xFFFF8F00).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nomor + ikon status
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                    : const Color(0xFFFF8F00).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: isUploaded
                  ? const Icon(Icons.check,
                      size: 14, color: Color(0xFF4CAF50))
                  : Text(
                      '$number',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8F00),
                      ),
                    ),
            ),
            const SizedBox(width: 10),

            // Info dokumen
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.documentList.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isUploaded
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFBF360C),
                    ),
                  ),
                  if (doc.documentList.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      doc.documentList.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    isUploaded ? '✓ Sudah terupload' : '✗ Belum terupload',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isUploaded
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF8F00),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Tombol upload
            if (isUploading)
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUploaded
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF8F00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () => c.uploadEvidence(doc),
                icon: Icon(
                  isUploaded ? Icons.update : Icons.upload_file,
                  size: 14,
                ),
                label: Text(
                  isUploaded ? 'Update' : 'Upload',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
