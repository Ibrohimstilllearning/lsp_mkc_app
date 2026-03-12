import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/forms/form_controller.dart';

class FormApl01Bagian4 extends StatelessWidget {
  final FormController c = Get.find();

  // Nanti list ini dari API, sekarang dummy dulu
  final List<String> buktiTypes = [
    "Pas Foto 3x4 Background Merah",
    "KTP",
    "Ijazah Terakhir",
    "Sertifikat Pelatihan",
    "Surat Pengalaman Kerja",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFEDD8),
      appBar: AppBar(
        backgroundColor: Color(0xFFDFEDD8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text("Kembali ke beranda",
            style: TextStyle(color: Colors.black, fontSize: 14)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Card Header
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
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bagian 4 : Bukti Administratif",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text(
                          "Upload file bukti administratif per tipe. Format yang diterima: PDF/JPG, maksimal 2MB per file.",
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // List Upload per tipe
            ...buktiTypes.map((tipe) => _uploadCard(tipe)),

            SizedBox(height: 24),

            // Tombol Navigasi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF4CAF50)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Get.back(),
                    child: Text("Sebelumnya",
                        style: TextStyle(color: Color(0xFF4CAF50))),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Get.snackbar(
                        "Berhasil",
                        "Form APL01 berhasil dikirim!",
                        backgroundColor: Color(0xFF4CAF50),
                        colorText: Colors.white,
                      );
                    },
                    child: Text("Kirim", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _uploadCard(String tipe) {
    return Obx(() {
      final fileName = c.uploadedFiles[tipe];
      final hasFile = fileName != null && fileName.isNotEmpty;

      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tipe,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Format: PDF/JPG • Maks 2MB",
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            SizedBox(height: 12),

            // Status upload
            if (hasFile)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(fileName,
                          style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
                          overflow: TextOverflow.ellipsis),
                    ),
                    GestureDetector(
                      onTap: () => c.removeFile(tipe),
                      child: Icon(Icons.close, color: Colors.red, size: 18),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: () => c.pickFile(tipe),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Color(0xFF4CAF50), style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFFF9FFF9),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          color: Color(0xFF4CAF50), size: 32),
                      SizedBox(height: 6),
                      Text("Tap untuk upload file",
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF4CAF50))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}