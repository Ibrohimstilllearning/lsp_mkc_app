import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsp_mkc_app/pages/document_controller.dart';

class DocumentPage extends GetView<DocumentController> {
  const DocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFEDD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009447),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Dokumen Saya',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner info ──
            _InfoBanner(),
            const SizedBox(height: 16),

            // ── Section: Pilih Dokumen (checkbox) ──
            _SectionCard(
              title: 'Pilih Dokumen yang Ingin Dikelola',
              child: Obx(
                () => Column(
                  children: masterDocument.map((doc) {
                    final isSelected = controller.selectedKeys.contains(
                      doc.key,
                    );
                    return CheckboxListTile(
                      value: isSelected,
                      // Toggle: tampilkan/sembunyikan card dokumen di bawah
                      onChanged: (_) => controller.toggleSelected(doc.key),
                      activeColor: const Color(0xFF4CAF50),
                      title: Text(
                        doc.label,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                      ),
                      subtitle: doc.keterangan != null
                          ? Text(
                              doc.keterangan!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Section: Card Upload per Dokumen ──
            // Hanya tampil jika dokumen dipilih di atas
            Obx(() {
              final filtered = masterDocument
                  .where((d) => controller.selectedKeys.contains(d.key))
                  .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Pilih minimal satu dokumen di atas',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: filtered
                    .map(
                      (doc) => _DokumenUploadCard(
                        doc: doc,
                        controller: controller,
                        // Upload dari profile menggunakan uploadDokumenFromProfile
                        onUpload: () =>
                            controller.uploadDokumenFromProfil(doc.key),
                        onDelete: () => controller.deleteDokumen(doc.key),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF009447).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF009447).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF009447), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Dokumen yang diupload di sini akan otomatis tersedia saat pengisian APL01. '
              'Sebaliknya, dokumen yang diupload di APL01 juga akan muncul di sini.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF009447),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}

class _DokumenUploadCard extends StatelessWidget {
  final DokumenItem doc;
  final DocumentController controller;
  final VoidCallback onUpload;
  final VoidCallback onDelete;

  const _DokumenUploadCard({
    required this.doc,
    required this.controller,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isUploaded = controller.isUploaded(doc.key);
      final isLoading = controller.isLoading(doc.key);
      final fileInfo = controller.uploadedDocs[doc.key];
      // Tandai jika dokumen berasal dari APL01
      final fromApl01 = fileInfo?['source'] == 'apl01';

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // Hijau jika sudah upload, abu jika belum
            color: isUploaded
                ? const Color(0xFF4CAF50).withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Judul + badge source ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    doc.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isUploaded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      // Warna badge berbeda tergantung sumber upload
                      color: fromApl01
                          ? Colors.blue.withOpacity(0.1)
                          : const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      // Keterangan sumber dokumen
                      fromApl01 ? 'Dari APL01' : 'Dari Profil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: fromApl01
                            ? Colors.blue
                            : const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            if (doc.keterangan != null) ...[
              const SizedBox(height: 3),
              Text(
                doc.keterangan!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],

            const SizedBox(height: 10),
            Text(
              'Format: PDF / JPG / PNG  •  Maks. 2MB',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 12),

            // ── Area status file ──
            if (isLoading)
              // Tampilkan loading indicator saat upload berlangsung
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (isUploaded)
              // File sudah ada → tampilkan nama file + tombol hapus
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileInfo?['file_name'] ?? '-',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF4CAF50),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Tombol hapus
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Belum ada file → tampilkan area tap untuk upload
              GestureDetector(
                onTap: onUpload,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF9FFF9),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFF4CAF50),
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap untuk upload',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // Dialog konfirmasi sebelum hapus
  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Dokumen',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin ingin menghapus dokumen "${doc.label}"?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back();
              onDelete();
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
