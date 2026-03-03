import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/form_controller.dart';

class FormApl01Bagian3 extends StatelessWidget {
  final FormController c = Get.find();

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
                        Text("Bagian 3 : Bukti Kelengkapan Pemohon",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("3.1 Bukti Persyaratan Dasar Pemohon",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Card Tabel 3.1
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Table(
                border: TableBorder.all(color: Colors.black, width: 0.5),
                columnWidths: {
                  0: FixedColumnWidth(28),
                  1: FlexColumnWidth(4),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(1.5),
                },
                children: [
                  _headerRow(),
                  _buktiRow(
                    "1.",
                    "Pendidikan minimal SMA/SMK Sederajat dan memiliki sertifikat pelatihan berbasis Kompetensi Tenaga Administrasi Kewirausahaan atau Pekerja dengan pengalaman minimal selama 2 tahun di bidang tenaga administrasi.",
                    "bukti_dasar_1",
                  ),
                  _buktiRow(
                    "2.",
                    "Surat Pengalaman Kerja Minimal 2 Tahun di bidang Tenaga Administrasi",
                    "bukti_dasar_2",
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Card Tabel 3.2
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("3.2 Bukti Administratif",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: Colors.black, width: 0.5),
                    columnWidths: {
                      0: FixedColumnWidth(28),
                      1: FlexColumnWidth(4),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.5),
                      4: FlexColumnWidth(1.5),
                    },
                    children: [
                      _headerRow(),
                      _buktiRow("1.", "Pas Foto 3x4 Background Merah", "admin_1"),
                      _buktiRow("2.", "KTP", "admin_2"),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Card Rekomendasi & Tanda Tangan
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 0.5),
              ),
              child: Table(
                border: TableBorder.all(color: Colors.black, width: 0.5),
                columnWidths: {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Rekomendasi (diisi oleh LSP):",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text("Berdasarkan ketentuan persyaratan dasar, maka pemohon:",
                              style: TextStyle(fontSize: 11)),
                          SizedBox(height: 4),
                          Text("Diterima/ Tidak diterima *) sebagai peserta sertifikasi",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("* coret yang tidak sesuai",
                              style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pemohon/ Kandidat :",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text("Nama", style: TextStyle(fontSize: 11)),
                          SizedBox(height: 40),
                          Text("Tanda tangan/ Tanggal", style: TextStyle(fontSize: 11)),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Catatan :",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Admin LSP :",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text("Nama :", style: TextStyle(fontSize: 11)),
                          SizedBox(height: 40),
                          Text("Tanda tangan/ Tanggal", style: TextStyle(fontSize: 11)),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),

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
                        "Form berhasil dikirim!",
                        backgroundColor: Color(0xFF4CAF50),
                        colorText: Colors.white,
                      );
                    },
                    child: Text("Kirim",
                        style: TextStyle(color: Colors.white)),
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

  TableRow _headerRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[100]),
      children: [
        Padding(
          padding: EdgeInsets.all(6),
          child: Text("No",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(6),
          child: Text("Bukti Persyaratan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Text("Memenuhi\nSyarat",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Text("Tidak\nMemenuhi\nSyarat",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Text("Tidak\nAda",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  TableRow _buktiRow(String no, String label, String key) {
    return TableRow(children: [
      Padding(
        padding: EdgeInsets.all(6),
        child: Text(no, style: TextStyle(fontSize: 11)),
      ),
      Padding(
        padding: EdgeInsets.all(6),
        child: Text(label, style: TextStyle(fontSize: 11)),
      ),
      Obx(() => TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Checkbox(
            value: c.buktiStatus[key] == "memenuhi",
            onChanged: (val) => c.setBuktiStatus(key, "memenuhi"),
            activeColor: Color(0xFF4CAF50),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      )),
      Obx(() => TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Checkbox(
            value: c.buktiStatus[key] == "tidak_memenuhi",
            onChanged: (val) => c.setBuktiStatus(key, "tidak_memenuhi"),
            activeColor: Colors.red,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      )),
      Obx(() => TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Checkbox(
            value: c.buktiStatus[key] == "tidak_ada",
            onChanged: (val) => c.setBuktiStatus(key, "tidak_ada"),
            activeColor: Colors.grey,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      )),
    ]);
  }
}