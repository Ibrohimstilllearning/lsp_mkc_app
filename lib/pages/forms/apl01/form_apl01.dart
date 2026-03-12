import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/forms/form_controller.dart';
import 'package:lsp_mkc_app/pages/home/home_page.dart';
import 'form_apl01pt2.dart';

class FormApl01 extends StatelessWidget {
  final FormController c = Get.put(FormController());

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: TextStyle(fontSize: 13)),
          ),
          Text(": ", style: TextStyle(fontSize: 13)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: type,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 4),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4CAF50)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

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
                        Text("FR.APL.01. PERMOHONAN SERTIFIKASI KOMPETENSI",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Text("Bagian 1 : Rincian Data Pemohon Sertifikasi",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                            "Pada bagian ini, cantumkan data pribadi, data pendidikan formal serta data pekerjaan anda pada saat ini.",
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Card Data Pribadi
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
                  _sectionTitle("a.  Data Pribadi"),
                  _buildTextField("Nama lengkap", c.namaController),
                  _buildTextField("No. KTP/NIK/Paspor", c.nikController),
                  _buildTextField("Tempat / tgl. Lahir", c.tempatLahirController),

                  // Jenis Kelamin
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 160,
                          child: Text("Jenis kelamin", style: TextStyle(fontSize: 13)),
                        ),
                        Text(": "),
                        Obx(() => Row(
                          children: [
                            Radio<String>(
                              value: "Laki-laki",
                              groupValue: c.jenisKelamin.value,
                              onChanged: (val) => c.jenisKelamin.value = val!,
                              activeColor: Color(0xFF4CAF50),
                            ),
                            Text("Laki-laki", style: TextStyle(fontSize: 13)),
                            SizedBox(width: 8),
                            Radio<String>(
                              value: "Wanita",
                              groupValue: c.jenisKelamin.value,
                              onChanged: (val) => c.jenisKelamin.value = val!,
                              activeColor: Color(0xFF4CAF50),
                            ),
                            Text("Wanita", style: TextStyle(fontSize: 13)),
                          ],
                        )),
                      ],
                    ),
                  ),

                  _buildTextField("Kebangsaan", c.kebangsaanController),
                  _buildTextField("Alamat rumah", c.alamatController),
                  _buildTextField("Kode pos", c.kodePosController, type: TextInputType.number),

                  // Telepon
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 160,
                            child: Text("No. Telepon/E-mail", style: TextStyle(fontSize: 13))),
                        Text(": "),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Rumah: ", style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: TextField(
                                      controller: c.noRumahController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(bottom: 4),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CAF50))),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("Kantor: ", style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: TextField(
                                      controller: c.noKantorController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(bottom: 4),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CAF50))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text("HP: ", style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: TextField(
                                      controller: c.noHpController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(bottom: 4),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CAF50))),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("E-mail: ", style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: TextField(
                                      controller: c.emailController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(bottom: 4),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CAF50))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildTextField("Kualifikasi Pendidikan", c.pendidikanController),
                  Text("*Coret yang tidak perlu",
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Card Data Pekerjaan
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
                  _sectionTitle("b.  Data Pekerjaan Sekarang"),
                  _buildTextField("Nama Institusi /\nPerusahaan", c.institusiController),
                  _buildTextField("Jabatan", c.jabatanController),
                  _buildTextField("Alamat Kantor", c.alamatKantorController),
                  _buildTextField("Kode pos", c.kodePosKantorController, type: TextInputType.number),

                  // Telp/Fax/Email kantor
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 160,
                            child: Text("No. Telp/Fax/E-mail", style: TextStyle(fontSize: 13))),
                        Text(": "),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Telp: ", style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: TextField(
                                      controller: c.noTelpController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(bottom: 4),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CAF50))),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("Fax: ", style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: TextField(
                                      controller: c.noFaxController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(bottom: 4),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CAF50))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text("E-mail: ", style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: TextField(
                                      controller: c.emailKantorController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(bottom: 4),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CAF50))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Tombol Next
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Get.to(() => FormApl01Bagian2()),
                child: Text("Selanjutnya", style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}