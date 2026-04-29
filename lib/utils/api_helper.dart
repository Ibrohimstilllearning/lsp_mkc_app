import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  // ── Handle response dari API ──
  // Dipanggil setelah setiap http request
  static Map<String, dynamic>? handleResponse(http.Response response) {
    final body = response.body;

    // Cek kalau response kosong
    if (body.isEmpty) {
      showError('Server tidak mengembalikan data');
      return null;
    }

    // Cek kalau response bukan JSON (misal HTML error Laravel)
    if (body.trimLeft().startsWith('<')) {
      showError('Terjadi kesalahan pada server. Silakan coba lagi.');
      return null;
    }

    try {
      final json = jsonDecode(body);

      switch (response.statusCode) {
        case 200:
        case 201:
          return json;

        case 422:
          // Validation error dari Laravel
          final errors = json['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            final firstError = errors.values.first;
            final message = firstError is List
                ? firstError.first.toString()
                : firstError.toString();
            showError(message);
          } else {
            showError(json['message'] ?? 'Data yang dimasukkan tidak valid');
          }
          return null;

        case 401:
          showError('Sesi kamu telah berakhir. Silakan login ulang.');
          return null;

        case 403:
          showError('Kamu tidak memiliki akses ke halaman ini.');
          return null;

        case 404:
          showError('Data tidak ditemukan.');
          return null;

        case 500:
          showError('Terjadi kesalahan pada server. Silakan coba lagi nanti.');
          return null;

        default:
          showError(
            json['message'] ?? 'Terjadi kesalahan. Silakan coba lagi.',
          );
          return null;
      }
    } catch (e) {
      debugPrint('ApiHelper parse error: $e');
      showError('Terjadi kesalahan. Silakan coba lagi.');
      return null;
    }
  }

  // ── Handle network/connection error ──
  static void handleException(dynamic e) {
    debugPrint('ApiHelper exception: $e');
    final message = e.toString().toLowerCase();

    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network')) {
      showError('Tidak ada koneksi internet. Periksa jaringan kamu.');
    } else if (message.contains('timeout')) {
      showError('Koneksi timeout. Silakan coba lagi.');
    } else {
      showError('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  // ── Tampilkan snackbar error ──
  static void showError(String message) {
    // Tutup snackbar yang sedang tampil dulu
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      'Terjadi Kesalahan',
      message,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  // ── Tampilkan snackbar sukses ──
  static void showSuccess(String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  // ── Tampilkan dialog error (untuk error kritis) ──
  static void showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 8),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Get.back(),
            child: const Text(
              'Mengerti',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}