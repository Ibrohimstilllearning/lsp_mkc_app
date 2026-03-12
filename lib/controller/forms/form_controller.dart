import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FormController extends GetxController {
  // Bagian 1 - Data Pribadi
  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final tempatLahirController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final kebangsaanController = TextEditingController();
  final alamatController = TextEditingController();
  final kodePosController = TextEditingController();
  final noRumahController = TextEditingController();
  final noKantorController = TextEditingController();
  final noHpController = TextEditingController();
  final emailController = TextEditingController();
  final pendidikanController = TextEditingController();

  // Bagian 1 - Data Pekerjaan
  final institusiController = TextEditingController();
  final jabatanController = TextEditingController();
  final alamatKantorController = TextEditingController();
  final kodePosKantorController = TextEditingController();
  final noTelpController = TextEditingController();
  final noFaxController = TextEditingController();
  final emailKantorController = TextEditingController();

  // Bagian 2 - Data Sertifikasi
  var tujuanAsesmen = <String>[].obs;

  var jenisKelamin = "Laki-laki".obs;
  final formKey = GlobalKey<FormState>();

  void toggleTujuan(String value) {
    if (tujuanAsesmen.contains(value)) {
      tujuanAsesmen.remove(value);
    } else {
      tujuanAsesmen.add(value);
    }
  }

  // Bagian 3 - Bukti Kelengkapan
var buktiStatus = <String, String>{}.obs;

void setBuktiStatus(String key, String value) {
  if (buktiStatus[key] == value) {
    buktiStatus[key] = "";
  } else {
    buktiStatus[key] = value;
  }
}

// Bagian 4 - Upload File
var uploadedFiles = <String, String>{}.obs;

void pickFile(String tipe) async {
  // nanti integrasi file picker
  // sementara simulasi dulu
  uploadedFiles[tipe] = "contoh_file.pdf";
}

void removeFile(String tipe) {
  uploadedFiles.remove(tipe);
}

  @override
  void onClose() {
    namaController.dispose();
    nikController.dispose();
    tempatLahirController.dispose();
    tanggalLahirController.dispose();
    kebangsaanController.dispose();
    alamatController.dispose();
    kodePosController.dispose();
    noRumahController.dispose();
    noKantorController.dispose();
    noHpController.dispose();
    emailController.dispose();
    pendidikanController.dispose();
    institusiController.dispose();
    jabatanController.dispose();
    alamatKantorController.dispose();
    kodePosKantorController.dispose();
    noTelpController.dispose();
    noFaxController.dispose();
    emailKantorController.dispose();
    super.onClose();
  }
}