import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

class FormApl01Controller extends GetxController {
  // ─── BAGIAN 1: Data Pribadi ───────────────────────────────────────────────
  final namaController          = TextEditingController();
  final tempatLahirController   = TextEditingController(); // place_of_birth
  final tanggalLahirController  = TextEditingController(); // date_of_birth (YYYY-MM-DD)
  final alamatController        = TextEditingController();
  final kodePosController       = TextEditingController(); // home_postal_code
  final noHpController          = TextEditingController(); // phone_number
  final pendidikanController    = TextEditingController(); // education_qualifications

  // Data Pekerjaan (masih bagian 1)
  final institusiController     = TextEditingController(); // company_name
  final jabatanController       = TextEditingController(); // job_title
  final alamatKantorController  = TextEditingController(); // company_address
  final kodePosKantorController = TextEditingController(); // company_postal_code
  final noTelpController        = TextEditingController(); // company_contact

  // gender: "male" | "female"
  final jenisKelamin = 'male'.obs;

  // ─── Dari response bagian 1 ───────────────────────────────────────────────
  int? registrationId; // disimpan setelah bagian 1 berhasil

  // ─── BAGIAN 2: Data Sertifikasi ───────────────────────────────────────────
  final tujuanAsesmen = <String>[].obs;

  void toggleTujuan(String label) {
    if (tujuanAsesmen.contains(label)) {
      tujuanAsesmen.remove(label);
    } else {
      tujuanAsesmen.add(label);
    }
  }

  // ─── BAGIAN 3: Bukti Kelengkapan ─────────────────────────────────────────
  // nilai: "memenuhi" | "tidak_memenuhi" | "tidak_ada" | ""
  final buktiStatus = <String, String>{
    'bukti_dasar_1': '',
    'bukti_dasar_2': '',
    'admin_1': '',
    'admin_2': '',
  }.obs;

  void setBuktiStatus(String key, String status) {
    // toggle: klik ulang status yg sama → reset ke ""
    buktiStatus[key] = buktiStatus[key] == status ? '' : status;
  }

  // ─── Loading state ────────────────────────────────────────────────────────
  final isLoadingBagian1 = false.obs;
  final isLoadingBagian2 = false.obs;
  final isLoadingBagian3 = false.obs;

  // ─── Helper: ambil token dari SharedPreferences ───────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ─── Helper snackbar ──────────────────────────────────────────────────────
  void _showError(String message) {
    Get.snackbar(
      'Gagal', message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil', message,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  // ─── Validasi Bagian 1 ────────────────────────────────────────────────────
  String? _validateBagian1() {
    if (namaController.text.trim().isEmpty)          return 'Nama lengkap tidak boleh kosong';
    if (tempatLahirController.text.trim().isEmpty)   return 'Tempat lahir tidak boleh kosong';
    if (tanggalLahirController.text.trim().isEmpty)  return 'Tanggal lahir tidak boleh kosong';
    if (alamatController.text.trim().isEmpty)        return 'Alamat tidak boleh kosong';
    if (noHpController.text.trim().isEmpty)          return 'Nomor HP tidak boleh kosong';
    if (pendidikanController.text.trim().isEmpty)    return 'Kualifikasi pendidikan tidak boleh kosong';
    if (institusiController.text.trim().isEmpty)     return 'Nama institusi/perusahaan tidak boleh kosong';
    if (jabatanController.text.trim().isEmpty)       return 'Jabatan tidak boleh kosong';
    if (alamatKantorController.text.trim().isEmpty)  return 'Alamat kantor tidak boleh kosong';
    return null;
  }

  // ─── POST Bagian 1 ────────────────────────────────────────────────────────
  Future<bool> submitBagian1() async {
    final error = _validateBagian1();
    if (error != null) {
      _showError(error);
      return false;
    }

    isLoadingBagian1.value = true;
    try {
      final token = await _getToken();
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}/apl01/data-pemohon-sertifikasi',
      );

      final body = {
        'gender'                  : jenisKelamin.value,           // "male" | "female"
        'place_of_birth'          : tempatLahirController.text.trim(),
        'date_of_birth'           : tanggalLahirController.text.trim(), // format: YYYY-MM-DD
        'address'                 : alamatController.text.trim(),
        'home_postal_code'        : kodePosController.text.trim(),
        'phone_number'            : noHpController.text.trim(),
        'education_qualifications': pendidikanController.text.trim(),
        'company_name'            : institusiController.text.trim(),
        'job_title'               : jabatanController.text.trim(),
        'company_address'         : alamatKantorController.text.trim(),
        'company_postal_code'     : kodePosKantorController.text.trim(),
        'company_contact'         : noTelpController.text.trim(),
      };

      print('[APL01 Bagian 1] URL  : $url');
      print('[APL01 Bagian 1] Body : ${jsonEncode(body)}');

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: token != null
            ? ApiEndpoints.authHeaders(token)
            : ApiEndpoints.headers,
      );

      print('[APL01 Bagian 1] Status : ${response.statusCode}');
      print('[APL01 Bagian 1] Body   : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final b = response.body.trim();
        if (b.isNotEmpty) {
          final j = jsonDecode(b);
          registrationId = j['response']?['registration_id'] as int?;
          print('[APL01 Bagian 1] registration_id: $registrationId');
        }
        return true;
      }

      final bodyStr1 = response.body.trim();
      if (bodyStr1.isEmpty) {
        _showError('Server error (${response.statusCode}), coba lagi nanti');
        return false;
      }
      final json1 = jsonDecode(bodyStr1);
      _showError(json1['message'] ?? json1['metadata']?['message'] ?? 'Terjadi kesalahan');
      return false;
    } catch (e) {
      print('[APL01 Bagian 1] Error: $e');
      _showError('Terjadi kesalahan koneksi, coba lagi');
      return false;
    } finally {
      isLoadingBagian1.value = false;
    }
  }

  // ─── Validasi Bagian 2 ────────────────────────────────────────────────────
  String? _validateBagian2() {
    if (tujuanAsesmen.isEmpty) return 'Pilih minimal satu tujuan asesmen';
    return null;
  }

  // ─── POST Bagian 2 ────────────────────────────────────────────────────────
  Future<bool> submitBagian2() async {
    final error = _validateBagian2();
    if (error != null) {
      _showError(error);
      return false;
    }

    isLoadingBagian2.value = true;
    try {
      final token = await _getToken();
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}/apl01/data-sertifikasi',
      );

      print('[APL01 Bagian 2] tujuanAsesmen: $tujuanAsesmen');
      print('[APL01 Bagian 2] registrationId: $registrationId');

      if (tujuanAsesmen.isEmpty) {
        _showError('Pilih tujuan asesmen terlebih dahulu');
        return false;
      }

      final body = {
        'registration_id'      : registrationId,
        'certification_purpose' : tujuanAsesmen.first,
        'scheme_id'            : 1,
      };

      print('[APL01 Bagian 2] URL  : $url');
      print('[APL01 Bagian 2] Body : ${jsonEncode(body)}');

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: token != null
            ? ApiEndpoints.authHeaders(token)
            : ApiEndpoints.headers,
      );

      print('[APL01 Bagian 2] Status : ${response.statusCode}');
      print('[APL01 Bagian 2] Body   : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      final bodyStr2 = response.body.trim();
      if (bodyStr2.isEmpty) {
        _showError('Server error (${response.statusCode}), coba lagi nanti');
        return false;
      }
      final json2 = jsonDecode(bodyStr2);
      _showError(json2['message'] ?? json2['metadata']?['message'] ?? 'Terjadi kesalahan');
      return false;
    } catch (e) {
      print('[APL01 Bagian 2] Error: $e');
      _showError('Terjadi kesalahan koneksi, coba lagi');
      return false;
    } finally {
      isLoadingBagian2.value = false;
    }
  }

  // ─── Validasi Bagian 3 ────────────────────────────────────────────────────
  String? _validateBagian3() {
    for (final entry in buktiStatus.entries) {
      if (entry.value.isEmpty) {
        return 'Semua bukti kelengkapan harus diisi';
      }
    }
    return null;
  }

  // ─── POST Bagian 3 ────────────────────────────────────────────────────────
  Future<bool> submitBagian3() async {
    final error = _validateBagian3();
    if (error != null) {
      _showError(error);
      return false;
    }

    isLoadingBagian3.value = true;
    try {
      final token = await _getToken();
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}/apl01/bukti-kelengkapan-pemohon',
      );

      final body = Map<String, String>.from(buktiStatus);

      print('[APL01 Bagian 3] URL  : $url');
      print('[APL01 Bagian 3] Body : ${jsonEncode(body)}');

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: token != null
            ? ApiEndpoints.authHeaders(token)
            : ApiEndpoints.headers,
      );

      print('[APL01 Bagian 3] Status : ${response.statusCode}');
      print('[APL01 Bagian 3] Body   : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess('Form APL-01 berhasil dikirim!');
        return true;
      }

      final bodyStr3 = response.body.trim();
      if (bodyStr3.isEmpty) {
        _showError('Server error (${response.statusCode}), coba lagi nanti');
        return false;
      }
      final json3 = jsonDecode(bodyStr3);
      _showError(json3['message'] ?? json3['metadata']?['message'] ?? 'Terjadi kesalahan');
      return false;
    } catch (e) {
      print('[APL01 Bagian 3] Error: $e');
      _showError('Terjadi kesalahan koneksi, coba lagi');
      return false;
    } finally {
      isLoadingBagian3.value = false;
    }
  }

  // ─── Dispose ─────────────────────────────────────────────────────────────
  @override
  void onClose() {
    namaController.dispose();
    tempatLahirController.dispose();
    tanggalLahirController.dispose();
    alamatController.dispose();
    kodePosController.dispose();
    noHpController.dispose();
    pendidikanController.dispose();
    institusiController.dispose();
    jabatanController.dispose();
    alamatKantorController.dispose();
    kodePosKantorController.dispose();
    noTelpController.dispose();
    super.onClose();
  }
}