import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final isLoading = false.obs;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // COMMENT: Validasi input email & password sebelum API call
  String? _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) return 'Format email tidak valid';
    if (password.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (password.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  void _showError(String message) => Get.snackbar('Gagal', message, backgroundColor: Colors.red, colorText: Colors.white);
  void _showSuccess(String message) => Get.snackbar('Berhasil', message, backgroundColor: Colors.green, colorText: Colors.white);

  Future<void> loginMethod() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    isLoading.value = true;
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.authEndPoints.loginPoint}');
      final body = jsonEncode({
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      final response = await http.post(url, body: body, headers: ApiEndpoints.headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['metadata']['code'] == 200) {
          final token = json['token'];
          final prefs = await _prefs;
          // COMMENT: Simpan token login ke SharedPreferences
          await prefs.setString('token', token);
          print('TOKEN SAVED: $token'); 

          emailController.clear();
          passwordController.clear();
          _showSuccess('Selamat datang kembali!');

          // COMMENT: Navigasi ke HomePage
          Get.offAllNamed(AppPages.home);
        }
      } else {
        _showError('Login gagal, cek email & password');
      }
    } finally {
      isLoading.value = false;
    }
  }
}