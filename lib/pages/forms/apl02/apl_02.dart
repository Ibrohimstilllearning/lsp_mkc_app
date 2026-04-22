import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'apl02_controller.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/unit.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/element.dart' as model_element;
import 'package:lsp_mkc_app/pages/forms/apl02/model/criterion.dart';

class FormApl02 extends StatelessWidget {
  final int registrationId;
  final int userId;

  FormApl02({super.key, required this.registrationId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final Apl02Controller c = Get.put(Apl02Controller(userId: userId));

    // Fetch data jika belum ada atau registrationId berbeda
    if (c.apl02Data.value?.registrationId != registrationId && !c.isLoading.value) {
      Future.microtask(() => c.fetchData(registrationId));
    }

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
      body: Obx(() {
        if (c.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
        }

        if (c.apl02Data.value == null) {
          return Center(child: Text("Data FR.APL.02 tidak ditemukan"));
        }

        final data = c.apl02Data.value!;
        final scheme = data.scheme;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                          Text("FR.APL.02. ASESMEN MANDIRI",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          Text("Skema Sertifikasi: ${scheme.name}",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                              "Tinjau kembali kriteria unjuk kerja dan tandai 'K' jika kompeten atau 'BK' jika belum kompeten.",
                              style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Loop unit
              ...scheme.units.map((Unit unit) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kode Unit: ${unit.unitCode}", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      Text("Judul Unit: ${unit.unitTitle}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Divider(color: Colors.grey[400], thickness: 0.8),

                      // Loop element
                      ...unit.elements.map((model_element.Element element) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Elemen: ${element.title}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                              SizedBox(height: 8),

                              // Kriteria
                              ...element.criteria.map((Criterion criterion) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8, bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("\u2022 ", style: TextStyle(fontSize: 13, color: Colors.black87)),
                                      Expanded(
                                        child: Text("${criterion.name} - ${criterion.description}", style: TextStyle(fontSize: 13, color: Colors.black87)),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              SizedBox(height: 8),

                              // Radio K/BK
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Penilaian: ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    Obx(() => Row(
                                      children: [
                                        Radio<bool>(
                                          value: true,
                                          groupValue: c.userAnswer[element.id],
                                          onChanged: (val) => c.setAnswer(element.id, val!),
                                          activeColor: Color(0xFF4CAF50),
                                        ),
                                        Text("K", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                        SizedBox(width: 8),
                                        Radio<bool>(
                                          value: false,
                                          groupValue: c.userAnswer[element.id],
                                          onChanged: (val) => c.setAnswer(element.id, val!),
                                          activeColor: Colors.red[400],
                                        ),
                                        Text("BK", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                      ],
                                    )),
                                  ],
                                ),
                              ),

                              SizedBox(height: 12),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),

              SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (c.isSubmitting.value) return;

                    // Validasi semua elemen
                    bool isComplete = true;
                    for (var unit in scheme.units) {
                      for (var element in unit.elements) {
                        if (!c.userAnswer.containsKey(element.id)) {
                          isComplete = false;
                          break;
                        }
                      }
                    }

                    if (!isComplete) {
                      Get.snackbar(
                        "Menunggu",
                        "Harap isi semua elemen dengan menekan tombol K atau BK sebelum menyimpan",
                        backgroundColor: Colors.orange[400],
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    c.submitForm();
                  },
                  child: c.isSubmitting.value
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Simpan Data", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),

              SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}