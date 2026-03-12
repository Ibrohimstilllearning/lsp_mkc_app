import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/controller/forms/form_controller.dart';
import 'form_apl01pt3.dart';

class FormApl01Bagian2 extends StatelessWidget {
  final FormController c = Get.find();

  final List<Map<String, String>> unitKompetensi = [
    {"no": "1.", "kode": "M.741000.004.01", "judul": "Melakukan survey sumber bahan baku dan bahan pembantu"},
    {"no": "2.", "kode": "M.741000.006.01", "judul": "Menentukan jenis produk yang akan diusahakan"},
    {"no": "3.", "kode": "M.741000.008.01", "judul": "Melakukan pengurusan perijinan usaha industri"},
    {"no": "4.", "kode": "M.741000.014.01", "judul": "Membuat jadwal kerja personil bagian produksi"},
    {"no": "5.", "kode": "M.741000.019.01", "judul": "Melakukan pengaturan penyimpanan bahan baku, bahan pembantu, produk antara dan produk akhir"},
    {"no": "6.", "kode": "M.741000.026.01", "judul": "Menjalin hubungan dengan pelanggan"},
    {"no": "7.", "kode": "M.741000.027.01", "judul": "Melakukan pembukuan keuangan untuk setiap transaksi"},
    {"no": "8.", "kode": "N.821100.001.02", "judul": "Menangani Penerimaan dan Pengiriman Dokumen/Surat"},
    {"no": "9.", "kode": "N.821100.067.01", "judul": "Melakukan Transaksi Perbankan Sederhana"},
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
                        Text("Bagian 2 : Data Sertifikasi",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text(
                          "Tuliskan Judul dan Nomor Skema Sertifikasi yang anda ajukan berikut Daftar Unit Kompetensi sesuai kemasan pada skema sertifikasi untuk mendapatkan pengakuan sesuai dengan latar belakang pendidikan, pelatihan serta pengalaman kerja yang anda miliki.",
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Card Skema Sertifikasi
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Table(
                border: TableBorder.all(color: Colors.black, width: 0.5),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FixedColumnWidth(20),
                  3: FlexColumnWidth(3),
                },
                children: [
                  TableRow(children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Skema Sertifikasi\n(KKNI/Okupasi/Klaster)",
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    TableCell(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Judul", style: TextStyle(fontSize: 12)),
                          ),
                          Divider(height: 1, color: Colors.black),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Nomor", style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    TableCell(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(":", style: TextStyle(fontSize: 12)),
                          ),
                          Divider(height: 1, color: Colors.black),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(":", style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    TableCell(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Tenaga Administrasi Kewirausahaan",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          Divider(height: 1, color: Colors.black),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("SUK-SKS-REV1-L007",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Tujuan Asesmen", style: TextStyle(fontSize: 12)),
                    ),
                    Padding(padding: EdgeInsets.all(8), child: SizedBox()),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(":", style: TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _checkboxOption("Sertifikasi"),
                          _checkboxOption("Pengakuan Kompetensi Terkini (PKT)"),
                          _checkboxOption("Rekognisi Pembelajaran Lampau (RPL)"),
                          _checkboxOption("Lainnya"),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Card Tabel Unit Kompetensi
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Daftar Unit Kompetensi sesuai kemasan:",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: Colors.black, width: 0.5),
                    columnWidths: {
                      0: FixedColumnWidth(32),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[100]),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("No", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Kode Unit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Judul Unit Kompetensi", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      ...unitKompetensi.map((item) => TableRow(
                        children: [
                          Padding(padding: EdgeInsets.all(8), child: Text(item["no"]!, style: TextStyle(fontSize: 12))),
                          Padding(padding: EdgeInsets.all(8), child: Text(item["kode"]!, style: TextStyle(fontSize: 12))),
                          Padding(padding: EdgeInsets.all(8), child: Text(item["judul"]!, style: TextStyle(fontSize: 12))),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF4CAF50)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Get.back(),
                    child: Text("Sebelumnya", style: TextStyle(color: Color(0xFF4CAF50))),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Get.to(() => FormApl01Bagian3()),
                    child: Text("Selanjutnya", style: TextStyle(color: Colors.white)),
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

  Widget _checkboxOption(String label) {
    return Obx(() => Row(
      children: [
        Checkbox(
          value: c.tujuanAsesmen.contains(label),
          onChanged: (val) => c.toggleTujuan(label),
          activeColor: Color(0xFF4CAF50),
        ),
        Expanded(child: Text(label, style: TextStyle(fontSize: 12))),
      ],
    ));
  }
}