import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsp_mkc_app/pages/document_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class ProfileDocumentSection extends StatelessWidget {
  const ProfileDocumentSection({super.key});

  @override
  Widget build(BuildContext context) {
    // [FIX] pakai find() bukan put() di dalam build()
    // put() di dalam build() bikin controller dibuat ulang setiap rebuild
    // find() ambil controller yang udah ada dari routes binding
    final DocumentController c = Get.find<DocumentController>();

    return GestureDetector(
      // [FIX] pakai toNamed() bukan to()
      // toNamed() pakai routes binding yang udah setup controller nya
      onTap: () => Get.toNamed(AppPages.document),
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
                    final count = c.uploadedDocs.length;
                    return Text(
                      count == 0
                          ? 'Belum ada dokumen yang diupload'
                          : '$count dari ${masterDocument.length} dokumen',
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
              final count = c.uploadedDocs.length;
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
                      value: total > 0 ? count / total : 0,
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
    );
  }
}