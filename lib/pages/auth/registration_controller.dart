import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationController extends GetxController {
  TextEditingController roleController = TextEditingController();
  TextEditingController identityTypeController = TextEditingController();
  TextEditingController identityNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String? _validateInputs() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final identityType = identityTypeController.text.trim();
    final identityNumber = identityNumberController.text.trim();
    final password = passwordController.text;
    final passwordConf = passwordConfController.text;

    if (name.isEmpty) return 'Nama lengkap tidak boleh kosong';
    if (name.length < 3) return 'Nama minimal 3 karakter';

    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Format email tidak valid';
    }

    if (identityType.isEmpty) return 'Jenis identitas tidak boleh kosong';

    if (identityNumber.isEmpty) return 'Nomor identitas tidak boleh kosong';
    if (identityNumber.length != 16) return 'NIK harus 16 digit';
    if (!RegExp(r'^\d+$').hasMatch(identityNumber)) return 'NIK hanya boleh angka';

    if (password.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (password.length < 6) return 'Kata sandi minimal 6 karakter';

    if (passwordConf.isEmpty) return 'Konfirmasi kata sandi tidak boleh kosong';
    if (password != passwordConf) return 'Kata sandi tidak cocok';

    return null;
  }

  void _showError(String message) {
    Get.snackbar(
      'Gagal',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> registerMethod() async {
    // validasi dulu sebelum hit API
    final validationError = _validateInputs();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    try {
      var headers = ApiEndpoints.headers;
      var url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.registerPoint);

      Map body = {
        'role': 'asesi',
        'identity_type': identityTypeController.text.trim(),
        'identity_number': identityNumberController.text.trim(),
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'password_confirmation': passwordConfController.text,
      };

      print('URL: $url');
      print('Body: ${jsonEncode(body)}');

      http.Response response = await http.post(url, body: jsonEncode(body), headers: headers);
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      var bodyStr = response.body.trim();
      if (bodyStr.startsWith('"') && bodyStr.endsWith('"')) {
        bodyStr = jsonDecode(bodyStr);
      }
      final json = jsonDecode(bodyStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        roleController.clear();
        identityTypeController.clear();
        identityNumberController.clear();
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        passwordConfController.clear();

        Get.back();
        _showSuccess('Akun berhasil dibuat! Cek email Anda untuk verifikasi');
      } else if (response.statusCode == 422) {
        final errors = json['errors'];
        if (errors != null) {
          final firstError = (errors as Map).values.first;
          _showError(firstError is List ? firstError.first : firstError.toString());
        } else {
          _showError(json['metadata']?['message'] ?? json['message'] ?? 'Data tidak valid');
        }
      } else if (response.statusCode == 409) {
        _showError('Email sudah terdaftar, gunakan email lain');
      } else if (response.statusCode == 500) {
        _showError('Server sedang bermasalah, coba lagi nanti');
      } else {
        _showError(json['metadata']?['message'] ?? json['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException')) {
        _showError('Tidak ada koneksi internet');
      } else {
        _showError('Terjadi kesalahan, coba lagi');
      }
    }
  }
}