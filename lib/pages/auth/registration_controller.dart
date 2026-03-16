import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationController extends GetxController {
  String identityType = 'id';

  // roleController DIHAPUS — tidak dipakai, role langsung hardcode 'asesi'
  TextEditingController identityNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfController = TextEditingController();

  final isLoading = false.obs;

  String? _validateInputs() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final identityNumber = identityNumberController.text.trim();
    final password = passwordController.text;
    final passwordConf = passwordConfController.text;

    if (name.isEmpty) return 'Nama lengkap tidak boleh kosong';
    if (name.length < 3) return 'Nama minimal 3 karakter';

    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Format email tidak valid';
    }

    if (identityNumber.isEmpty) return 'Nomor identitas tidak boleh kosong';
    if (identityType == 'id') {
      if (identityNumber.length != 16) return 'NIK harus 16 digit';
      if (!RegExp(r'^\d+$').hasMatch(identityNumber)) return 'NIK hanya boleh angka';
    } else {
      if (identityNumber.length < 6) return 'Nomor passport minimal 6 karakter';
    }

    if (password.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (password.length < 6) return 'Kata sandi minimal 6 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Kata sandi harus mengandung huruf kapital';
    if (!RegExp(r'[a-z]').hasMatch(password)) return 'Kata sandi harus mengandung huruf kecil';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(password)) {
      return 'Kata sandi harus mengandung simbol (contoh: !@#\$)';
    }

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
      duration: const Duration(seconds: 4),
    );
  }

  void _showWarning(String message) {
    Get.snackbar(
      'Data Sudah Terdaftar', message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );
  }

  // _autoLogin() DIHAPUS — tidak pernah dipanggil

  void _clearForm() {
    identityType = 'id';
    identityNumberController.clear();
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    passwordConfController.clear();
  }

  Future<void> registerMethod() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    isLoading.value = true;
    try {
      var url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.registerPoint);

      Map<String, dynamic> body = {  // Add <String, dynamic> 
        'identity_type': identityType,
        'identity_number': identityNumberController.text.trim(),
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'password_confirmation': passwordConfController.text,
      };

      print('=== REQUEST ===');
      print('URL: $url');
      print('Headers: ${ApiEndpoints.headers}');
      print('Body: ${jsonEncode(body)}');

      http.Response response = await http.post(
        url,
        body: jsonEncode(body),
        headers: ApiEndpoints.headers,
      );

      print('=== RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      var bodyStr = response.body.trim();

// Guard body kosong
if (bodyStr.isEmpty) {
  if (response.statusCode == 200 || response.statusCode == 201) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_email', emailController.text.trim());
    await prefs.setString('temp_password', passwordController.text);
    _clearForm();
    Get.offAllNamed(AppPages.verify);
  } else {
    _showError('Server error (${response.statusCode}), coba lagi nanti');
  }
  return;
}

if (bodyStr.startsWith('"') && bodyStr.endsWith('"')) {
  bodyStr = jsonDecode(bodyStr);
}
final json = jsonDecode(bodyStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('temp_email', emailController.text.trim());
        await prefs.setString('temp_password', passwordController.text);

        _clearForm();
        Get.offAllNamed(AppPages.verify);

      } else if (response.statusCode == 422) {
        final metadata = json['metadata'] as Map?;
        final errors = json['errors'] as Map?;

        if (metadata != null) {
          final code = metadata['code']?.toString() ?? '';
          final message = metadata['message']?.toString() ?? 'Data Invalid';

          if (code == 'E2001') {
            _showWarning('Email Sudah Terdaftar, Silahkan Gunakan Email yang Lain.');
          } else if (code == 'E2002') {
            _showWarning('${identityType == 'id' ? 'NIK' : 'Nomor Passport'} sudah terdaftar');
          } else if (code == 'E2003') {
            _showWarning('Email dan ${identityType == 'id' ? 'NIK' : 'Nomor Passport'} sudah terdaftar');
          } else {
            _showError(message);
          }
        } else if (errors != null) {
            final emailErr = errors['email'];
            final nikErr = errors['identity_number'];
            final emailCode = emailErr is List ? emailErr.first : emailErr?.toString();
            final nikCode = nikErr is List ? nikErr.first : nikErr?.toString();

            if (emailCode == 'E2001' && nikCode == 'E2002') {
              _showWarning('Email dan ${identityType == 'id' ? 'NIK' : 'Nomor Passport'} sudah terdaftar');
              return;
            }
            if (emailCode == 'E2001') {
              _showWarning('Email sudah terdaftar, gunakan email lain');
              return;
            }
            if (nikCode == 'E2002') {
              _showWarning('${identityType == 'id' ? 'NIK' : 'Nomor Passport'} sudah terdaftar');
              return;
            }

            final firstError = errors.values.first;
            final msg = firstError is List ? firstError.first : firstError.toString();
            _showError(msg);
          } else {
            _showError('Data tidak valid');
        }

      } else if (response.statusCode == 409) {
        _showWarning('Email sudah terdaftar, gunakan email lain');

      } else if (response.statusCode == 500) {
        // Data kemungkinan sudah masuk DB, tetap arahkan ke verify
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('temp_email', emailController.text.trim());
        await prefs.setString('temp_password', passwordController.text);
        _clearForm();
        Get.offAllNamed(AppPages.verify);

      } else {
        // Ambil pesan dari metadata atau message
        final message = json['metadata']?['message'] 
            ?? json['message'] 
            ?? 'Terjadi kesalahan';
        _showError(message);
      }

    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');
      _showError('Terjadi kesalahan koneksi, coba lagi');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    identityNumberController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfController.dispose();
    super.onClose();
  }
}