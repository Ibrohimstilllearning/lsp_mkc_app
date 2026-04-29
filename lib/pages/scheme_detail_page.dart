import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/scheme.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class SchemeDetailPage extends StatelessWidget {
  final Scheme scheme;
  const SchemeDetailPage({super.key, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Detail Skema',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.workspace_premium, color: Color(0xFF4CAF50), size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        scheme.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          scheme.code,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Sertifikasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.blue[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sertifikasi ini ditujukan untuk mengukur dan mengakui kompetensi Anda pada bidang terkait. Anda diwajibkan untuk mengisi form permohonan sertifikasi (APL.01), Form Asesmen Mandiri (APL.02), serta melengkapi portofolio yang dibutuhkan.',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.list_alt, size: 20, color: Colors.orange[600]),
                          const SizedBox(width: 12),
                          Text(
                            'Unit Kompetensi: ${scheme.units.length} Unit',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to APL01 and pass scheme object
                    Get.toNamed(AppPages.apl01, arguments: {'selectedScheme': scheme});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009447),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Daftar Sertifikasi', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
