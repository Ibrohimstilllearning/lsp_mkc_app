import 'dart:convert';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:lsp_mkc_app/utils/api_helper.dart';

class ResetController extends GetxController {
  var isLoading = false.obs;
  var step = 1.obs;
  var email = ''.obs;
  var otp = ''.obs;
  var resetToken = ''.obs;

  Future<void> sendForgotPassword(String emailInput) async {
    if (emailInput.isEmpty) {
      ApiHelper.showErrorDialog('Email tidak boleh kosong');
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

      final data = ApiHelper.handleResponse(response);
      if (data != null) {
        step.value = 2;
        ApiHelper.showSuccess(
          data['metadata']?['message'] ?? 'Kode OTP telah dikirim ke email kamu',
        );
      }
    } catch (e) {
      ApiHelper.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String otpInput) async {
    if (otpInput.isEmpty) {
      ApiHelper.showErrorDialog('Kode OTP tidak boleh kosong');
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

      final data = ApiHelper.handleResponse(response);
      if (data != null) {
        resetToken.value = data['response']?['reset_token'] ?? '';
        step.value = 3;
        ApiHelper.showSuccess(
          data['metadata']?['message'] ?? 'OTP valid, silakan masukkan password baru',
        );
      }
    } catch (e) {
      ApiHelper.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ApiHelper.showErrorDialog('Password tidak boleh kosong');
      return;
    }
    if (newPassword.length < 8) {
      ApiHelper.showErrorDialog('Password minimal 8 karakter');
      return;
    }
    if (newPassword != confirmPassword) {
      ApiHelper.showErrorDialog('Konfirmasi password tidak cocok');
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/reset-password'),
        headers: ApiEndpoints.headers,
        body: jsonEncode({
          'email': email.value,
          'reset_token': resetToken.value,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      final data = ApiHelper.handleResponse(response);
      if (data != null) {
        ApiHelper.showSuccess(
          data['metadata']?['message'] ?? 'Password berhasil diubah, silakan login',
        );
        Get.offAllNamed(AppPages.login);
      }
    } catch (e) {
      ApiHelper.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }
}