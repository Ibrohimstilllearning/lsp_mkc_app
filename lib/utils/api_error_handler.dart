import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiErrorHandler {
  static void handleError({
    required http.Response response,
    String defaultFallback = 'Terjadi kesalahan sistem, coba lagi nanti.',
  }) {
    String msg = defaultFallback;

    try {
      final bodyStr = response.body.trim();

      if (bodyStr.isNotEmpty) {
        final json = jsonDecode(bodyStr);

        // Cari pesan error berlapis
        msg = json['message'] ?? 
              json['metadata']?['message'] ?? 
              defaultFallback;

        // Tangkap Laravel 422 Validation Errors
        if (response.statusCode == 422 && json['errors'] != null) {
          final errors = json['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            } else {
              errorMessages.add(value.toString());
            }
          });
          if (errorMessages.isNotEmpty) {
            msg = errorMessages.join('\n');
          }
        }
      }

      // Override jika internal server error
      if (response.statusCode >= 500) {
        msg = 'Terjadi kendala pada peladen (Server Error ${response.statusCode}). Mohon coba beberapa saat lagi.';
      } else if (response.statusCode == 404) {
        msg = 'Data tidak ditemukan (404).';
      }

    } catch (e) {
      if (response.statusCode >= 500) {
        msg = 'Terjadi kendala pada peladen (Server Error ${response.statusCode}). Mohon coba beberapa saat lagi.';
      } else {
        msg = 'Gagal memproses data (${response.statusCode}).';
      }
    }

    _showError(msg);
  }

  static void _showError(String message) {
    Get.snackbar(
      'Informasi',
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  static void showNetworkError(dynamic exception) {
    _showError('Koneksi terputus atau gagal terhubung ke peladen. Silakan periksa jaringan Anda (\${exception.runtimeType}).');
  }
}
