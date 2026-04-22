import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

class FormApl01Controller extends GetxController {
  // ─── BAGIAN 1: Data Pribadi & Pekerjaan ───────────────────────────────────
  final namaController = TextEditingController();
  final tempatLahirController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final alamatController = TextEditingController();
  final kodePosController = TextEditingController();
  final noHpController = TextEditingController();
  final pendidikanController = TextEditingController();
  final namaInstitusiController = TextEditingController();

  final institusiController = TextEditingController();
  final jabatanController = TextEditingController();
  final alamatKantorController = TextEditingController();
  final kodePosKantorController = TextEditingController();
  final noTelpController = TextEditingController();

  final jenisKelamin = 'male'.obs;
  final asesiType = 'pribadi'.obs;

  int? registrationId;

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
  final buktiStatus = <String, String>{
    'bukti_dasar_1': '',
    'bukti_dasar_2': '',
    'admin_1': '',
    'admin_2': '',
  }.obs;

  void setBuktiStatus(String key, String status) {
    buktiStatus[key] = buktiStatus[key] == status ? '' : status;
  }

  // ─── Loading States ──────────────────────────────────────────────────────
  final isLoadingBagian1 = false.obs;
  final isLoadingBagian2 = false.obs;
  final isLoadingBagian3 = false.obs;

  // ─── Helpers ─────────────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _showError(String message) {
    Get.snackbar(
      'Gagal',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // ─── Validasi Bagian 1 ────────────────────────────────────────────────────
  String? _validateBagian1() {
    if (namaController.text.trim().isEmpty)
      return 'Nama lengkap tidak boleh kosong';
    if (tempatLahirController.text.trim().isEmpty)
      return 'Tempat lahir tidak boleh kosong';
    if (tanggalLahirController.text.trim().isEmpty)
      return 'Tanggal lahir tidak boleh kosong';
    if (alamatController.text.trim().isEmpty)
      return 'Alamat tidak boleh kosong';
    if (noHpController.text.trim().isEmpty)
      return 'Nomor HP tidak boleh kosong';
    if (pendidikanController.text.trim().isEmpty)
      return 'Kualifikasi pendidikan tidak boleh kosong';
    if (institusiController.text.trim().isEmpty)
      return 'Nama institusi/perusahaan tidak boleh kosong';
    if (jabatanController.text.trim().isEmpty)
      return 'Jabatan tidak boleh kosong';
    if (alamatKantorController.text.trim().isEmpty)
      return 'Alamat kantor tidak boleh kosong';
    return null;
  }

  // ─── POST Bagian 1 ────────────────────────────────────────────────────────
  Future<bool> submitBagian1() async {
    if (namaController.text.isEmpty) {
      _showError('Nama harus diisi');
      return false;
    }
    isLoadingBagian1.value = true;
    try {
      final token = await _getToken();
      final body = {
        'gender': jenisKelamin.value, // "male" | "female"
        'place_of_birth': tempatLahirController.text.trim(),
        'date_of_birth': tanggalLahirController.text
            .trim(), // format: YYYY-MM-DD
        'address': alamatController.text.trim(),
        'home_postal_code': kodePosController.text.trim(),
        'phone_number': noHpController.text.trim(),
        'education_qualifications': pendidikanController.text.trim(),
        'company_name': institusiController.text.trim(),
        'job_title': jabatanController.text.trim(),
        'company_address': alamatKantorController.text.trim(),
        'company_postal_code': kodePosKantorController.text.trim(),
        'company_contact': noTelpController.text.trim(),
        'asesi_type': asesiType.value, // "pribadi" | "perusahaan"
        'institution_name': namaInstitusiController.text.trim(),
      };

      print('[DEBUG] asesi_type: ${asesiType.value}');
      print('[DEBUG] full body: $body');

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/apl01/data-pemohon-sertifikasi'),
        body: jsonEncode(body),
        headers: token != null
            ? ApiEndpoints.authHeaders(token)
            : ApiEndpoints.headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        registrationId = data['response']?['registration_id'];
        return true;
      }

      final bodyStr1 = response.body.trim();
      if (bodyStr1.isEmpty) {
        _showError('Server error (${response.statusCode}), coba lagi nanti');
        return false;
      }
      final json1 = jsonDecode(bodyStr1);
      _showError(
        json1['message'] ??
            json1['metadata']?['message'] ??
            'Terjadi kesalahan',
      );
      return false;
    } catch (e) {
      print('[APL01 Bagian 1] Error: $e');
      _showError('Terjadi kesalahan koneksi, coba lagi');
      return false;
    } finally {
      isLoadingBagian1.value = false;
    }
  }

  // ─── SUBMIT BAGIAN 2 (INI YANG TADI ERROR) ───────────────────────────────
  Future<bool> submitBagian2() async {
    if (tujuanAsesmen.isEmpty) {
      _showError('Pilih minimal satu tujuan asesmen');
      return false;
    }
    isLoadingBagian2.value = true;
    try {
      final token = await _getToken();
      final url = Uri.parse('${ApiEndpoints.baseUrl}/apl01/data-sertifikasi');

      print('[APL01 Bagian 2] tujuanAsesmen: $tujuanAsesmen');
      print('[APL01 Bagian 2] registrationId: $registrationId');

      if (tujuanAsesmen.isEmpty) {
        _showError('Pilih tujuan asesmen terlebih dahulu');
        return false;
      }

      final body = {
        'registration_id': registrationId,
        'certification_purpose': tujuanAsesmen.first,
        'scheme_id': 1,
      };

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/apl01/data-sertifikasi'),
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
      _showError(
        json2['message'] ??
            json2['metadata']?['message'] ??
            'Terjadi kesalahan',
      );
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoadingBagian2.value = false;
    }
  }

  // ─── SUBMIT BAGIAN 3 ──────────────────────────────────────────────────────
  Future<bool> submitBagian3() async {
    isLoadingBagian3.value = true;
    try {
      final token = await _getToken();
      final body = Map<String, String>.from(buktiStatus);
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/apl01/bukti-kelengkapan-pemohon'),
        body: jsonEncode(body),
        headers: token != null
            ? ApiEndpoints.authHeaders(token)
            : ApiEndpoints.headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess('Form APL-01 Berhasil Terkirim!');
        return true;
      }

      final bodyStr3 = response.body.trim();
      if (bodyStr3.isEmpty) {
        _showError('Server error (${response.statusCode}), coba lagi nanti');
        return false;
      }
      final json3 = jsonDecode(bodyStr3);
      _showError(
        json3['message'] ??
            json3['metadata']?['message'] ??
            'Terjadi kesalahan',
      );
      return false;
    } catch (e) {
      print('[APL01 Bagian 3] Error: $e');
      _showError('Terjadi kesalahan koneksi, coba lagi');
      return false;
    } finally {
      isLoadingBagian3.value = false;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    tempatLahirController.dispose();
    tanggalLahirController.dispose();
    alamatController.dispose();
    kodePosController.dispose();
    noHpController.dispose();
    pendidikanController.dispose();
    namaInstitusiController.dispose();
    institusiController.dispose();
    jabatanController.dispose();
    alamatKantorController.dispose();
    kodePosKantorController.dispose();
    noTelpController.dispose();
    super.onClose();
  }
}
