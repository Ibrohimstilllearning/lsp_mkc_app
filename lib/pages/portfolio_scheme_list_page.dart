import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsp_mkc_app/pages/portfolio_scheme_controller.dart';
import 'package:lsp_mkc_app/pages/portfolio_upload_page.dart';

class PortfolioSchemeListPage extends StatelessWidget {
  const PortfolioSchemeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PortfolioSchemeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Pilih Skema',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF009447)),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat skema',
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey[700]),
                ),
                TextButton(
                  onPressed: () => controller.fetchSchemes(),
                  child: const Text('Coba Lagi', style: TextStyle(color: Color(0xFF009447))),
                ),
              ],
            ),
          );
        }

        if (controller.schemeList.isEmpty) {
          return Center(
            child: Text(
              'Belum ada skema tersedia',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.schemeList.length,
          itemBuilder: (context, index) {
            final scheme = controller.schemeList[index];

            return GestureDetector(
              onTap: () {
                Get.to(() => PortfolioUploadPage(scheme: scheme));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
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
                        Icons.workspace_premium,
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
                            scheme.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scheme.code,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
