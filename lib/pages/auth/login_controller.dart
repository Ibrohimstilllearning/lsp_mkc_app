import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:lsp_mkc_app/utils/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  String? _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email))
      return 'Format email tidak valid';
    if (password.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (password.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  Future<void> loginMethod() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      ApiHelper.showError(validationError);
      return;
    }

    isLoading.value = true;
    try {
      final url = Uri.parse(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.authEndPoints.loginPoint}');
      final response = await http.post(
        url,
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
        headers: ApiEndpoints.headers,
      );

      final data = ApiHelper.handleResponse(response);
      if (data != null) {
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        emailController.clear();
        passwordController.clear();
        ApiHelper.showSuccess('Selamat datang kembali!');
        Get.offAllNamed(AppPages.home);
      }
    } catch (e) {
      ApiHelper.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}