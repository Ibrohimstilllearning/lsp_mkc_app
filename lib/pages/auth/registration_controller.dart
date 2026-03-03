import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/routes/app_pages.dart';
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
      'Gagal', message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  Future<void> registerMethod() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    Future<void> _autoLogin(String email, String password) async {
  try {
    var url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.loginPoint);
    Map body = {
      'email': email,
      'password': password,
    };
    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: ApiEndpoints.headers,
    );

    print('Auto login status: ${response.statusCode}');
    print('Auto login body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      var bodyStr = response.body.trim();
      if (bodyStr.startsWith('"') && bodyStr.endsWith('"')) {
        bodyStr = jsonDecode(bodyStr);
      }
      final json = jsonDecode(bodyStr);
      final token = json['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        print('Auto login token saved: $token');
      }
    }
  } catch (e) {
    print('Auto login error: $e');
  }
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
      final prefs = await SharedPreferences.getInstance();
  await prefs.setString('temp_email', emailController.text.trim());
  await prefs.setString('temp_password', passwordController.text);

      roleController.clear();
      identityTypeController.clear();
      identityNumberController.clear();
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      passwordConfController.clear();

      Get.offAllNamed(AppPages.verify);
} else if (response.statusCode == 422) {
        final errors = json['errors'];
        if (errors != null) {
          final firstError = (errors as Map).values.first;
          _showError(firstError is List ? firstError.first : firstError.toString());
        } else {
          _showError(json['metadata']?['message'] ?? 'Data tidak valid');
        }
      } else if (response.statusCode == 409) {
        _showError('Email sudah terdaftar, gunakan email lain');
      } else if (response.statusCode == 500) {
        _showError('Server sedang bermasalah, coba lagi nanti');
      } else {
        _showError(json['metadata']?['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');
      _showError('Terjadi kesalahan, coba lagi');
    }
  }
}