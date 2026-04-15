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
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // validasi input sebelum hit API
  String? _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Format email tidak valid';
    }
    if (password.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (password.length < 6) return 'Kata sandi minimal 6 karakter';

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
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> loginMethod() async {
    // validasi dulu sebelum hit API
    final validationError = _validateInputs();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    try {
      var headers = ApiEndpoints.headers;
      var url = Uri.parse(
        ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.loginPoint,
      );

      Map body = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      };

      print('URL: $url');
      print('Body: ${jsonEncode(body)}');

      http.Response response = await http.post(
        url,
        body: jsonEncode(body),
        headers: headers,
      );
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      var bodyStr = response.body.trim();
      if (bodyStr.startsWith('"') && bodyStr.endsWith('"')) {
        bodyStr = jsonDecode(bodyStr);
      }

      final json = jsonDecode(bodyStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (json['metadata']['code'] == 200) {
          var token = json['token'];
          final SharedPreferences prefs = await _prefs;
          await prefs.setString('token', token);

          emailController.clear();
          passwordController.clear();

          _showSuccess('Selamat datang kembali!');
          print('Navigating to home...');
          Get.offAllNamed(AppPages.home);
        } else {
          _showError(json['metadata']['message'] ?? 'Terjadi kesalahan');
        }
      } else if (response.statusCode == 401) {
        _showError('Email atau kata sandi salah');
      } else if (response.statusCode == 403) {
        final message = json['metadata']?['message'] ?? '';
        if (message.toLowerCase().contains('aktivasi') ||
            message.toLowerCase().contains('verified')) {
          _showError('Akun belum diaktivasi, cek email Anda');
        } else {
          _showError(message.isNotEmpty ? message : 'Akses ditolak');
        }
      } else if (response.statusCode == 404) {
        _showError('Email tidak terdaftar');
      } else if (response.statusCode == 422) {
        final errors = json['errors'];
        if (errors != null) {
          final firstError = (errors as Map).values.first;
          _showError(
            firstError is List ? firstError.first : firstError.toString(),
          );
        } else {
          _showError(json['metadata']?['message'] ?? 'Data tidak valid');
        }
      } else if (response.statusCode == 500) {
        _showError('Server sedang bermasalah, coba lagi nanti');
      } else {
        _showError(json['metadata']?['message'] ?? 'Terjadi kesalahan');
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
