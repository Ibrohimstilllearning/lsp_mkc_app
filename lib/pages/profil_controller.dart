import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilController extends GetxController {
  static const String _baseUrl = 'https://ujikomp.lspmkc.or.id/api';

  var isLoading = false.obs;
  var isSaving = false.obs;

  // ── Data dari GET /api/user ──
  var displayName = ''.obs;
  var email = ''.obs;
  var role = ''.obs;
  var status = ''.obs;
  var identityType = ''.obs;
  var identityNumber = ''.obs;
  var userId = 0.obs; // simpan id untuk endpoint profile/{id}

  // ── Data dari GET /api/profile/{id} ──
  var username = ''.obs;
  var photoUrl = ''.obs;

  // ── Ambil token dari SharedPreferences ──
  // Sama persis dengan login_controller.dart:
  // await prefs.setString('token', token)
  Future<String> get _token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // ── Header dengan Bearer token ──
  Future<Map<String, String>> get _headers async => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${await _token}',
  };

  @override
  void onInit() {
    super.onInit();
    fetchAll(); // ambil user dan profil sekaligus
  }

  // ─────────────────────────────────────────
  // Ambil semua data — user dulu, lalu profil
  // ─────────────────────────────────────────
  Future<void> fetchAll() async {
    await fetchUser(); // GET /api/user → nama, email, role, status, id
    await fetchProfile(); // GET /api/profile/{id} → data profil tambahan
  }

  // ─────────────────────────────────────────
  // GET /api/user
  // Mengembalikan data user yang sedang login
  // (nama, email, role, status, identity_type, identity_number)
  // ─────────────────────────────────────────
  Future<void> fetchUser() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: await _headers,
      );

      print('=== USER STATUS: ${response.statusCode}');
      print('=== USER BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Struktur response aktual:
        // {"response": {"id":3,"name":"...","identity":{"type":"id","number":"..."}}, "metadata":{...}}
        final user = data['response'] ?? data['data'] ?? data;

        userId.value = user['id'] ?? 0;
        displayName.value = user['name'] ?? '';
        email.value = user['email'] ?? '';
        role.value = user['role'] ?? '';
        status.value = user['status'] ?? '';

        // identity ada di dalam object nested: {"type": "id", "number": "..."}
        final identity = user['identity'] as Map<String, dynamic>?;
        identityType.value = identity?['type'] ?? '';
        identityNumber.value = identity?['number'] ?? '';
      } else {
        Get.snackbar('Error', data['message'] ?? 'Gagal memuat data user');
      }
    } catch (e) {
      print('=== USER ERROR: $e');
      Get.snackbar('Error', 'Tidak dapat terhubung ke server');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────
  // GET /api/profile/{id}
  // apiResource 'show' butuh {id} di URL
  // Dipanggil setelah fetchUser() agar userId sudah terisi
  // ─────────────────────────────────────────
  Future<void> fetchProfile() async {
    // Jika userId belum ada, skip — tidak bisa hit endpoint tanpa id
    if (userId.value == 0) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/${userId.value}'),
        headers: await _headers,
      );

      print('=== PROFILE STATUS: ${response.statusCode}');
      print('=== PROFILE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final profile = data['data'] ?? data;
        // Data tambahan dari tabel profiles (jika ada)
        photoUrl.value = profile['photo'] ?? '';
        username.value = profile['username'] ?? '';
      }
      // 404 = profil belum dibuat, itu normal — tidak perlu snackbar error
    } catch (e) {
      print('=== PROFILE ERROR: $e');
    }
  }

  // ─────────────────────────────────────────
  // PUT /api/profile/{id}
  // Update data profil (field dari tabel profiles)
  // ─────────────────────────────────────────
  Future<void> _putProfile(Map<String, dynamic> payload) async {
    if (userId.value == 0) return;

    try {
      isSaving.value = true;

      final response = await http.put(
        Uri.parse('$_baseUrl/profile/${userId.value}'),
        headers: await _headers,
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await fetchAll(); // refresh semua data
        Get.back();
        Get.snackbar(
          'Berhasil',
          data['message'] ?? 'Profil berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3E8E41),
          colorText: const Color(0xFFFFFFFF),
        );
      } else if (response.statusCode == 422) {
        final errors = data['errors'] as Map<String, dynamic>?;
        final first = errors?.values.first;
        final message = first is List
            ? first.first.toString()
            : data['message'] ?? 'Validasi gagal';
        Get.snackbar(
          'Validasi Gagal',
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal memperbarui profil',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== PUT ERROR: $e');
      Get.snackbar('Error', 'Tidak dapat terhubung ke server');
    } finally {
      isSaving.value = false;
    }
  }

  // ─────────────────────────────────────────
  // PUT /api/user — update nama & email
  // Nama dan email ada di tabel users, bukan profiles
  // Gunakan endpoint /user bukan /profile
  // ─────────────────────────────────────────
  Future<void> _putUser(Map<String, dynamic> payload) async {
    try {
      isSaving.value = true;

      final response = await http.put(
        Uri.parse('$_baseUrl/user'),
        headers: await _headers,
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await fetchUser();
        Get.back();
        Get.snackbar(
          'Berhasil',
          data['message'] ?? 'Data berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3E8E41),
          colorText: const Color(0xFFFFFFFF),
        );
      } else if (response.statusCode == 422) {
        final errors = data['errors'] as Map<String, dynamic>?;
        final first = errors?.values.first;
        final message = first is List
            ? first.first.toString()
            : data['message'] ?? 'Validasi gagal';
        Get.snackbar(
          'Validasi Gagal',
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal memperbarui data',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== PUT USER ERROR: $e');
      Get.snackbar('Error', 'Tidak dapat terhubung ke server');
    } finally {
      isSaving.value = false;
    }
  }

  // ── Wrapper publik ──
  // Nama & email → PUT /api/user (tabel users)
  Future<void> updateName(String v) => _putUser({'name': v});
  Future<void> updateEmail(String v) => _putUser({'email': v});
  // Username → PUT /api/profile/{id} (tabel profiles, jika ada kolom username)
  Future<void> updateUsername(String v) => _putProfile({'username': v});

  // ── Update password ──
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.length < 8) {
      Get.snackbar('Gagal', 'Password minimal 8 karakter');
      return;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar('Gagal', 'Konfirmasi password tidak cocok');
      return;
    }

    try {
      isSaving.value = true;

      // POST /api/change-password — sesuai routes/api.php
      final response = await http.post(
        Uri.parse('$_baseUrl/change-password'),
        headers: await _headers,
        body: jsonEncode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar(
          'Berhasil',
          'Password berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3E8E41),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal mengubah password',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server');
    } finally {
      isSaving.value = false;
    }
  }
}
