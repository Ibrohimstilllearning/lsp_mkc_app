import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyController extends GetxController {
  var countdown = 60.obs;
  var canResend = false.obs;
  var isVerified = false.obs;

  Timer? _countdownTimer;
  Timer? _checkTimer;
  String? _token;

  @override
  void onInit() {
    super.onInit();
    _startCountdown();
    _startCheckingVerification();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _checkTimer?.cancel();
    super.onClose();
  }

  Future<void> _loginToGetToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('temp_email');
      final password = prefs.getString('temp_password');

      if (email == null || password == null) return;

      final url = Uri.parse(
        ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.loginPoint,
      );
      final response = await http.post(
        url,
        headers: ApiEndpoints.headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Auto login status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var bodyStr = response.body.trim();
        if (bodyStr.startsWith('"') && bodyStr.endsWith('"')) {
          bodyStr = jsonDecode(bodyStr);
        }
        final json = jsonDecode(bodyStr);
        _token = json['token'];
        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
        }
      }
    } catch (e) {
      print('Auto login error: $e');
    }
  }

  void _startCountdown() {
    countdown.value = 60;
    canResend.value = false;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // cek tiap 10 detik, hanya kalau token sudah ada
  void _startCheckingVerification() {
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_token != null) {
        await _checkVerificationStatus();
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    if (_token == null) return;
    try {
      final url = Uri.parse(
        ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.userPoint,
      );
      final response = await http.get(
        url,
        headers: ApiEndpoints.authHeaders(_token!),
      );
      print('Check verify status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var bodyStr = response.body.trim();
        if (bodyStr.startsWith('"') && bodyStr.endsWith('"')) {
          bodyStr = jsonDecode(bodyStr);
        }
        final json = jsonDecode(bodyStr);
        final verified = json['response']?['is_verified'] ?? false;

        if (verified) {
          await _redirectToHome();
        }
      } else if (response.statusCode == 401) {
        _token = null;
      }
    } catch (e) {
      print('Check verify error: $e');
    }
  }

  // dipanggil dari main.dart saat deep link verify berhasil
  Future<void> onDeepLinkVerified() async {
    _checkTimer?.cancel();
    await _loginToGetToken();

    if (_token != null) {
      await _redirectToHome();
    } else {
      // login gagal, arahkan ke login manual
      Get.offAllNamed(AppPages.login);
    }
  }

  Future<void> _redirectToHome() async {
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    isVerified.value = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('temp_email');
    await prefs.remove('temp_password');

    await Future.delayed(const Duration(seconds: 2));
    Get.offAllNamed(AppPages.home);
  }

  Future<void> resendVerification() async {
    if (!canResend.value) return;

    if (_token == null) {
      await _loginToGetToken();
    }

    if (_token == null) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat mengirim ulang, coba lagi nanti',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
      return;
    }

    try {
      final url = Uri.parse(
        ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.resendVerifyPoint,
      );
      final response = await http.post(
        url,
        headers: ApiEndpoints.authHeaders(_token!),
      );
      print('Resend status: ${response.statusCode}');
      print('Resend body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Berhasil',
          'Link verifikasi telah dikirim ulang, cek email Anda',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );
        _startCountdown();
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal mengirim ulang, coba lagi',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak ada koneksi internet',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    }
  }
}
