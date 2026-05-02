import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:lsp_mkc_app/utils/api_error_handler.dart';

class EducationOption {
  final int id;
  final String name;
  EducationOption({required this.id, required this.name});
  factory EducationOption.fromJson(Map<String, dynamic> json) =>
      EducationOption(id: json['id'], name: json['title'] ?? '');
}

class FormApl01Controller extends GetxController {
  // ─── BAGIAN 1: Data Pribadi & Pekerjaan ───────────────────────────────────
  final namaController = TextEditingController();
  final tempatLahirController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final alamatController = TextEditingController();
  final kodePosController = TextEditingController();
  final noHpController = TextEditingController();
  // Education dropdown
  final educationList = <EducationOption>[].obs;
  final selectedEducationId = Rxn<int>();
  final isLoadingEducation = false.obs;
  final namaInstitusiController = TextEditingController();

  final institusiController = TextEditingController();
  final jabatanController = TextEditingController();
  final alamatKantorController = TextEditingController();
  final kodePosKantorController = TextEditingController();
  final noTelpController = TextEditingController();

  final jenisKelamin = 'male'.obs;
  final asesiType = 'pribadi'.obs;

  int? registrationId;
  int? selectedSchemeId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['selectedScheme'] != null) {
      selectedSchemeId = Get.arguments['selectedScheme'].id;
    }
    fetchEducationOptions();
  }

  // ─── Fetch Master Education ───────────────────────────────────────────────
  Future<void> fetchEducationOptions() async {
    isLoadingEducation.value = true;
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/master-education'),
        headers: token != null
            ? ApiEndpoints.authHeaders(token)
            : ApiEndpoints.headers,
      );
      print('[APL01] Education status: ${response.statusCode}');
      print('[APL01] Education body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['response'] ?? data['data'] ?? [];
        educationList.value = (list as List)
            .map((e) => EducationOption.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('[APL01] Education fetch error: $e');
    } finally {
      isLoadingEducation.value = false;
    }
  }

  // ─── BAGIAN 2: Data Sertifikasi ───────────────────────────────────────────
  final tujuanAsesmen = <String>[].obs;

  void selectTujuan(String value) {
    tujuanAsesmen.clear();
    tujuanAsesmen.add(value);
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
  final isLoadingProfile = false.obs; // ✅ tambah

  // ─── Helpers ─────────────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _showError(String message) {
    Get.snackbar(
      'Informasi',
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  // ─── Load dari Profil ─────────────────────────────────────────────────────
  Future<void> loadFromProfile() async {
    isLoadingProfile.value = true;
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/user'),
        headers: token != null
            ? ApiEndpoints.authHeaders(token)
            : ApiEndpoints.headers,
      );

      print('[APL01] Load profile status: ${response.statusCode}');
      print('[APL01] Load profile body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['response'] ?? data['data'] ?? data;

        // ✅ Isi field yang tersedia dari profil
        if (user['name'] != null && user['name'].toString().isNotEmpty) {
          namaController.text = user['name'];
        }
        if (user['gender'] != null) {
          jenisKelamin.value = user['gender'];
        }
        if (user['place_of_birth'] != null) {
          tempatLahirController.text = user['place_of_birth'];
        }
        if (user['date_of_birth'] != null) {
          tanggalLahirController.text = user['date_of_birth'];
        }
        if (user['address'] != null) {
          alamatController.text = user['address'];
        }
        if (user['home_postal_code'] != null) {
          kodePosController.text = user['home_postal_code'];
        }
        if (user['phone_number'] != null) {
          noHpController.text = user['phone_number'];
        }
        if (user['education_id'] != null) {
          selectedEducationId.value = int.tryParse(user['education_id'].toString());
        }
        if (user['company_name'] != null) {
          institusiController.text = user['company_name'];
        }
        if (user['job_title'] != null) {
          jabatanController.text = user['job_title'];
        }
        if (user['company_address'] != null) {
          alamatKantorController.text = user['company_address'];
        }
        if (user['company_postal_code'] != null) {
          kodePosKantorController.text = user['company_postal_code'];
        }
        if (user['company_contact'] != null) {
          noTelpController.text = user['company_contact'];
        }
      }
    } catch (e) {
      print('[APL01] Load profile error: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // ─── POST Bagian 1 ────────────────────────────────────────────────────────
  Future<bool> submitBagian1() async {
    if (namaController.text.isEmpty) {
      _showError('Nama harus diisi');
      return false;
    }
    if (selectedEducationId.value == null) {
      _showError('Kualifikasi pendidikan harus dipilih');
      return false;
    }
    isLoadingBagian1.value = true;
    try {
      final token = await _getToken();
      final body = {
        'gender': jenisKelamin.value,
        'place_of_birth': tempatLahirController.text.trim(),
        'date_of_birth': tanggalLahirController.text.trim(),
        'address': alamatController.text.trim(),
        'home_postal_code': kodePosController.text.trim(),
        'phone_number': noHpController.text.trim(),
        'education_id': selectedEducationId.value,
        'company_name': institusiController.text.trim(),
        'job_title': jabatanController.text.trim(),
        'company_address': alamatKantorController.text.trim(),
        'company_postal_code': kodePosKantorController.text.trim(),
        'company_contact': noTelpController.text.trim(),
        'asesi_type': asesiType.value,
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

      print('[APL01 Bagian 1] Status: ${response.statusCode}');
      print('[APL01 Bagian 1] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        registrationId =
            data['response']?['registration_id'] ??
            data['data']?['registration_id'] ??
            data['registration_id'];
        print('[APL01 Bagian 1] registrationId: $registrationId');
        return true;
      }

      ApiErrorHandler.handleError(response: response, defaultFallback: 'Data gagal disimpan');
      return false;
    } catch (e, stackTrace) {
      print('[APL01 Bagian 1] Error type: ${e.runtimeType}');
      print('[APL01 Bagian 1] Error detail: $e');
      print('[APL01 Bagian 1] StackTrace: $stackTrace');
      ApiErrorHandler.showNetworkError(e);
      return false;
    } finally {
      isLoadingBagian1.value = false;
    }
  }

  // ─── POST Bagian 2 ────────────────────────────────────────────────────────
  Future<bool> submitBagian2() async {
    if (tujuanAsesmen.isEmpty) {
      _showError('Pilih minimal satu tujuan asesmen');
      return false;
    }
    isLoadingBagian2.value = true;
    try {
      final token = await _getToken();

      print('[APL01 Bagian 2] tujuanAsesmen: $tujuanAsesmen');
      print('[APL01 Bagian 2] registrationId: $registrationId');

      final body = {
        'registration_id': registrationId,
        'certification_purpose': tujuanAsesmen.first,
        'scheme_id': selectedSchemeId ?? 1,
      };

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/apl01/data-sertifikasi'),
        body: jsonEncode(body),
        headers: token != null
            ? ApiEndpoints.authHeaders(token)
            : ApiEndpoints.headers,
      );

      print('[APL01 Bagian 2] Status: ${response.statusCode}');
      print('[APL01 Bagian 2] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      ApiErrorHandler.handleError(response: response, defaultFallback: 'Data gagal disimpan');
      return false;
    } catch (e, stackTrace) {
      print('[APL01 Bagian 2] Error type: ${e.runtimeType}');
      print('[APL01 Bagian 2] Error detail: $e');
      print('[APL01 Bagian 2] StackTrace: $stackTrace');
      ApiErrorHandler.showNetworkError(e);
      return false;
    } finally {
      isLoadingBagian2.value = false;
    }
  }

  // ─── POST Bagian 3 ────────────────────────────────────────────────────────
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

      print('[APL01 Bagian 3] Status: ${response.statusCode}');
      print('[APL01 Bagian 3] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess('Form APL-01 Berhasil Terkirim!');
        return true;
      }

      ApiErrorHandler.handleError(response: response, defaultFallback: 'Gagal mengirim form');
      return false;
    } catch (e, stackTrace) {
      print('[APL01 Bagian 3] Error type: ${e.runtimeType}');
      print('[APL01 Bagian 3] Error detail: $e');
      print('[APL01 Bagian 3] StackTrace: $stackTrace');
      ApiErrorHandler.showNetworkError(e);
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
    namaInstitusiController.dispose();
    institusiController.dispose();
    jabatanController.dispose();
    alamatKantorController.dispose();
    kodePosKantorController.dispose();
    noTelpController.dispose();
    super.onClose();
  }
}