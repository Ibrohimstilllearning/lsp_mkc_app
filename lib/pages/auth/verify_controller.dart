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
    _loginToGetToken().then((_) {
      _startCheckingVerification();
    });
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

      // [FIX] cek dulu kalau token udah ada
      final existingToken = prefs.getString('token');
      if (existingToken != null && existingToken.isNotEmpty) {
        _token = existingToken;
        return;
      }

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
          await prefs.setString('token', _token!);
        }
      } else if (response.statusCode == 403) {
        // Email belum diverifikasi - normal, tunggu user verifikasi
        print('Email belum diverifikasi, tunggu verifikasi dulu');
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

  void _startCheckingVerification() {
    // cek langsung sekali dulu
    _checkVerificationStatus();

    // lanjut cek tiap 5 detik
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkVerificationStatus();
    });
  }

  Future<void> _checkVerificationStatus() async {
    // [FIX] kalau token null, coba login dulu
    if (_token == null) {
      await _loginToGetToken();
      if (_token == null) return;
    }

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
        // Token expired, reset dan coba login ulang
        _token = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await _loginToGetToken();
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('temp_email') ?? '';

      if (email.isEmpty) {
        Get.snackbar(
          'Gagal',
          'Email tidak ditemukan, silakan daftar ulang',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );
        return;
      }

      final url = Uri.parse(
        ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.resendVerifyPoint,
      );

      // [FIX] pakai API-KEY bukan Bearer token
      final response = await http.post(
        url,
        headers: ApiEndpoints.headers,
        body: jsonEncode({'email': email}),
      );

      print('Resend status: ${response.statusCode}');
      print('Resend body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final message = json['metadata']?['message'] ?? '';

        // [FIX] kalau server bilang udah terverifikasi, coba redirect
        if (message.toLowerCase().contains('sudah terverifikasi')) {
          // coba login ulang karena mungkin udah verified
          await _loginToGetToken();
          if (_token != null) {
            await _checkVerificationStatus();
          }
          return;
        }

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
        final json = jsonDecode(response.body);
        Get.snackbar(
          'Gagal',
          json['metadata']?['message'] ?? 'Gagal mengirim ulang, coba lagi',
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