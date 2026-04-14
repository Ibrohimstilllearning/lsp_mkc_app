import 'dart:convert';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class ResetController extends GetxController {
  var isLoading = false.obs;
  var step = 1.obs; // 1=email, 2=otp, 3=password baru

  var email = ''.obs;
  var otp = ''.obs;

  // ─────────────────────────────────────
  // Step 1 - POST /api/forgot-password
  // ─────────────────────────────────────
  Future<void> sendForgotPassword(String emailInput) async {
    if (emailInput.isEmpty) {
      Get.snackbar('Gagal', 'Email tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      email.value = emailInput;

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/forgot-password'),
        headers: ApiEndpoints.headers,
        body: jsonEncode({'email': emailInput}),
      );

      final data = jsonDecode(response.body);
      print('=== STATUS: ${response.statusCode}');
      print('=== BODY: ${response.body}');
      print('=== URL: ${ApiEndpoints.baseUrl}/forgot-password');
      print('=== HEADERS: ${ApiEndpoints.headers}');
      print('SENT: ${jsonEncode({'email': emailInput})}');
      print('=== FORGOT PASSWORD: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        step.value = 2;
        Get.snackbar(
          'Berhasil',
          data['message'] ?? 'Kode OTP telah dikirim ke email kamu',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3E8E41),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Email tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== FORGOT PASSWORD ERROR: $e');
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────
  // Step 2 - POST /api/verify-otp
  // ─────────────────────────────────────
  Future<void> verifyOtp(String otpInput) async {
    if (otpInput.isEmpty) {
      Get.snackbar('Gagal', 'Kode OTP tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      otp.value = otpInput;

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/verify-otp'),
        headers: ApiEndpoints.headers,
        body: jsonEncode({
          'email': email.value,
          'otp': otpInput,
        }),
      );

      final data = jsonDecode(response.body);
      print('=== VERIFY OTP: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        step.value = 3;
        Get.snackbar(
          'Berhasil',
          data['message'] ?? 'OTP valid, silakan masukkan password baru',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3E8E41),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Kode OTP salah atau sudah kadaluarsa',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== VERIFY OTP ERROR: $e');
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────
  // Step 3 - POST /api/reset-password
  // ─────────────────────────────────────
  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Gagal', 'Password tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPassword.length < 8) {
      Get.snackbar('Gagal', 'Password minimal 8 karakter',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar('Gagal', 'Konfirmasi password tidak cocok',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/reset-password'),
        headers: ApiEndpoints.headers,
        body: jsonEncode({
          'email': email.value,
          'otp': otp.value,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);
      print('=== RESET PASSWORD: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        Get.snackbar(
          'Berhasil',
          data['message'] ?? 'Password berhasil diubah, silakan login',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3E8E41),
          colorText: const Color(0xFFFFFFFF),
        );
        // Redirect ke login
        Get.offAllNamed(AppPages.login);
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal mengubah password',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== RESET PASSWORD ERROR: $e');
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}