import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'document_controller.dart';
import 'document_page.dart';
import 'portfolio_scheme_list_page.dart';

class ProfileDocumentSection extends StatelessWidget {
  const ProfileDocumentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final DocumentController c = Get.put(DocumentController());
    return Column(
      children: [
        // ── Dokumen Saya ──
        GestureDetector(
          onTap: () => Get.to(() => const DocumentPage()),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF009447).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder_open,
                    color: Color(0xFF009447),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dokumen Saya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Obx(() {
                        // ✅ FIX: hitung hanya key yang ada di masterDocument
                        final validKeys =
                            masterDocument.map((d) => d.key).toSet();
                        final count = c.uploadedDocs.keys
                            .where((k) => validKeys.contains(k))
                            .length;
                        final total = masterDocument.length;

                        return Text(
                          count == 0
                              ? 'Belum ada dokumen yang diupload'
                              : '$count dari $total dokumen',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: count == 0
                                ? Colors.grey
                                : const Color(0xFF009447),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Obx(() {
                  // ✅ FIX: sama — hitung dari validKeys saja
                  final validKeys =
                      masterDocument.map((d) => d.key).toSet();
                  final count = c.uploadedDocs.keys
                      .where((k) => validKeys.contains(k))
                      .length;
                  final total = masterDocument.length;

                  return Column(
                    children: [
                      Text(
                        '$count/$total',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF009447),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 40,
                        child: LinearProgressIndicator(
                          // ✅ FIX: value tidak akan pernah melebihi 1.0
                          value: total > 0
                              ? (count / total).clamp(0.0, 1.0)
                              : 0,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFF009447),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Portfolio Per Skema ──
        _PortfolioPerSkemaSection(),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Portfolio Per Skema Section
// ══════════════════════════════════════════════════════════════════════
class _PortfolioPerSkemaSection extends StatefulWidget {
  @override
  State<_PortfolioPerSkemaSection> createState() =>
      _PortfolioPerSkmaSectionState();
}

class _PortfolioPerSkmaSectionState extends State<_PortfolioPerSkemaSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portfolio Per Skema',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Kelola bukti dokumen per skema sertifikasi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue[700], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Portfolio dokumen per skema ditampilkan di halaman APL-02. '
                            'Buka form APL-02 untuk mengelola bukti dokumen sesuai skema sertifikasi Anda.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF009447),
                        side: const BorderSide(color: Color(0xFF009447)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.to(() => const PortfolioSchemeListPage()),
                      icon: const Icon(Icons.list_alt, size: 18),
                      label: Text(
                        'Pilih Skema',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
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
  }
}