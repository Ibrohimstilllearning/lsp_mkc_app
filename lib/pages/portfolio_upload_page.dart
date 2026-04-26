import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/scheme.dart';
import 'package:lsp_mkc_app/pages/portfolio_upload_controller.dart';

class PortfolioUploadPage extends StatefulWidget {
  final Scheme scheme;
  const PortfolioUploadPage({super.key, required this.scheme});

  @override
  State<PortfolioUploadPage> createState() => _PortfolioUploadPageState();
}

class _PortfolioUploadPageState extends State<PortfolioUploadPage> {
  late PortfolioUploadController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(PortfolioUploadController(), tag: 'portfolio_upload_${widget.scheme.id}');
    c.fetchPortfolios(widget.scheme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Upload Portfolio',
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
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF009447)),
          );
        }

        final docs = c.requiredDocuments;
        final uploaded = docs.where((d) => d.isUploaded).length;
        final total = docs.length;

        // Jika tidak ada data document yang butuh di upload.
        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_off, size: 56, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada dokumen yang dibutuhkan untuk skema ini.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009447),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => c.fetchPortfolios(widget.scheme),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Refresh', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skema Sertifikasi: ${widget.scheme.name}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Semua dokumen yang dibutuhkan skema ini ditampilkan di sini. Upload hasil scan / foto bukti dokumen Anda. Dokumen yang diunggah di sini akan otomatis sinkron dengan APL02 Anda.',
                            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

             // Progress
             Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               color: Colors.white,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(
                     'Progress Upload',
                     style: GoogleFonts.plusJakartaSans(
                       fontSize: 14,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                     decoration: BoxDecoration(
                       color: (uploaded == total && total > 0) ? const Color(0xFF009447) : const Color(0xFFFF8F00),
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Text(
                       '$uploaded / $total',
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

             const SizedBox(height: 8),

            // Document List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final isUploaded = doc.isUploaded;
                  final isUploading = c.uploadingListIds.contains(doc.listId);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUploaded ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUploaded
                            ? const Color(0xFF009447).withOpacity(0.35)
                            : const Color(0xFFFF8F00).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isUploaded
                                ? const Color(0xFF009447).withOpacity(0.15)
                                : const Color(0xFFFF8F00).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              isUploaded ? Icons.check : Icons.circle_outlined,
                              size: 16,
                              color: isUploaded ? const Color(0xFF009447) : const Color(0xFFFF8F00),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              if (isUploaded) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.description, size: 12, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        doc.fileUrl,
                                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                         // Upload Btn
                        isUploading
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isUploaded ? Colors.white : const Color(0xFF009447),
                                  foregroundColor: isUploaded ? const Color(0xFF009447) : Colors.white,
                                  side: isUploaded
                                      ? BorderSide(color: const Color(0xFF009447).withOpacity(0.5))
                                      : null,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  minimumSize: const Size(60, 32),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  c.uploadEvidence(doc).then((_) {
                                    c.fetchPortfolios(widget.scheme);
                                  });
                                },
                                child: Text(
                                  isUploaded ? 'Update' : 'Upload',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
