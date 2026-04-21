import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart'; // ← sesuaikan path import kamu

class ProfilController extends GetxController {
  // ── Ambil baseUrl dari ApiEndpoints (otomatis local/production) ──
  String get _baseUrl => ApiEndpoints.baseUrl;

  var isLoading = false.obs;
  var isSaving  = false.obs;

  // ── Data dari GET /api/user ──
  var displayName    = ''.obs;
  var email          = ''.obs;
  var role           = ''.obs;
  var status         = ''.obs;
  var identityType   = ''.obs;
  var identityNumber = ''.obs;
  var userId         = 0.obs;

  // ── Data tambahan ──
  var photoUrl = ''.obs;
  var username = ''.obs;

  // ── Ambil token dari SharedPreferences ──
  Future<String> get _token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // ── Header pakai ApiEndpoints.authHeaders (sudah include ngrok-skip-browser-warning) ──
  Future<Map<String, String>> get _headers async =>
      ApiEndpoints.authHeaders(await _token);

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  // ─────────────────────────────────────────
  // GET /api/user
  // ─────────────────────────────────────────
  Future<void> fetchAll() async => await fetchUser();

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
        final user = data['response'] ?? data['data'] ?? data;

        userId.value        = user['id']     ?? 0;
        displayName.value   = user['name']   ?? '';
        email.value         = user['email']  ?? '';
        role.value          = user['role']   ?? '';
        status.value        = user['status'] ?? '';

        final identity       = user['identity'] as Map<String, dynamic>?;
        identityType.value   = identity?['type']   ?? '';
        identityNumber.value = identity?['number'] ?? '';

        photoUrl.value = user['photo']    ?? '';
        username.value = user['username'] ?? '';
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
  // PUT /api/profile/{id}
  // ✅ Handles: name, job_title, phone, address, dll.
  //    Dikonfirmasi dari Postman — field 'name' diterima di endpoint ini
  //    URL terbentuk: https://ujikomp.lspmkc.or.id/api/profile/{userId}
  //    Contoh:        https://ujikomp.lspmkc.or.id/api/profile/2
  // ─────────────────────────────────────────
  Future<void> _putProfile(Map<String, dynamic> payload) async {
    if (userId.value == 0) {
      Get.snackbar('Error', 'User ID tidak ditemukan, coba login ulang');
      return;
    }
    try {
      isSaving.value = true;

      // userId.value diambil dari GET /api/user → response.id
      final url = Uri.parse('$_baseUrl/profile/${userId.value}');
      print('=== PUT PROFILE URL: $url');
      print('=== PUT PROFILE PAYLOAD: ${jsonEncode(payload)}');

      final response = await http.put(
        url,
        headers: await _headers,
        body: jsonEncode(payload),
      );
      print('=== PUT PROFILE STATUS: ${response.statusCode}');
      print('=== PUT PROFILE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update UI langsung (optimistic), lalu fetch ulang dari server
        _applyPayloadToObservables(payload);
        await fetchUser();
        Get.back();
        Get.snackbar(
          'Berhasil',
          data['metadata']?['message'] ?? data['message'] ?? 'Profil berhasil diperbarui',
          snackPosition:   SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3E8E41),
          colorText:       const Color(0xFFFFFFFF),
        );
      } else if (response.statusCode == 422) {
        final errors  = data['errors'] as Map<String, dynamic>?;
        final first   = errors?.values.first;
        final message = first is List
            ? first.first.toString()
            : data['message'] ?? 'Validasi gagal';
        Get.snackbar('Validasi Gagal', message,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal memperbarui profil',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== PUT PROFILE ERROR: $e');
      Get.snackbar('Error', 'Tidak dapat terhubung ke server');
    } finally {
      isSaving.value = false;
    }
  }

  // ─────────────────────────────────────────
  // PUT /api/user — khusus update EMAIL
  // (name sudah dipindah ke _putProfile karena
  //  terbukti dari Postman bahwa name ada di /api/profile/{id})
  // ─────────────────────────────────────────
  Future<void> _putUser(Map<String, dynamic> payload) async {
    try {
      isSaving.value = true;

      final url = Uri.parse('$_baseUrl/user');
      print('=== PUT USER URL: $url');
      print('=== PUT USER PAYLOAD: ${jsonEncode(payload)}');

      final response = await http.put(
        url,
        headers: await _headers,
        body: jsonEncode(payload),
      );
      print('=== PUT USER STATUS: ${response.statusCode}');
      print('=== PUT USER BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _applyPayloadToObservables(payload);
        await fetchUser();
        Get.back();
        Get.snackbar(
          'Berhasil',
          data['metadata']?['message'] ?? data['message'] ?? 'Data berhasil diperbarui',
          snackPosition:   SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3E8E41),
          colorText:       const Color(0xFFFFFFFF),
        );
      } else if (response.statusCode == 405) {
        // PUT /api/user belum tersedia di backend — tidak ada fallback
        Get.snackbar(
          'Gagal',
          'Fitur ini belum tersedia, hubungi admin',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (response.statusCode == 422) {
        final errors  = data['errors'] as Map<String, dynamic>?;
        final first   = errors?.values.first;
        final message = first is List
            ? first.first.toString()
            : data['message'] ?? 'Validasi gagal';
        Get.snackbar('Validasi Gagal', message,
            snackPosition: SnackPosition.BOTTOM);
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

  // ─────────────────────────────────────────
  // Helper: update observable langsung dari payload
  // supaya UI berubah REALTIME tanpa nunggu GET response
  // ─────────────────────────────────────────
  void _applyPayloadToObservables(Map<String, dynamic> payload) {
    if (payload.containsKey('name'))     displayName.value = payload['name'];
    if (payload.containsKey('email'))    email.value       = payload['email'];
    if (payload.containsKey('username')) username.value    = payload['username'];
    if (payload.containsKey('photo'))    photoUrl.value    = payload['photo'];
  }

  // ─────────────────────────────────────────
  // Wrapper Publik
  //
  // ✅ updateName     → _putProfile  (PUT /api/profile/{id})
  //    Terbukti dari Postman: field 'name' diterima di /api/profile/{id}
  //
  // ✅ updateEmail    → _putUser     (PUT /api/user)
  //    Email ada di tabel users, bukan profiles
  //
  // ✅ updateUsername → _putProfile  (PUT /api/profile/{id})
  // ─────────────────────────────────────────
  Future<void> updateName(String v)     => _putProfile({'name': v});
  Future<void> updateEmail(String v)    => _putUser({'email': v});
  Future<void> updateUsername(String v) => _putProfile({'username': v});

  // ─────────────────────────────────────────
  // POST /api/change-password
  // ─────────────────────────────────────────
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
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
      isSaving.value = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/change-password'),
        headers: await _headers,
        body: jsonEncode({
          'current_password':      currentPassword,
          'password':              newPassword,
          'password_confirmation': confirmPassword,
        }),
      );
      print('=== CHANGE PASSWORD STATUS: ${response.statusCode}');
      print('=== CHANGE PASSWORD BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar(
          'Berhasil', 'Password berhasil diperbarui',
          snackPosition:   SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3E8E41),
          colorText:       const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal mengubah password',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== CHANGE PASSWORD ERROR: $e');
      Get.snackbar('Error', 'Tidak dapat terhubung ke server');
    } finally {
      isSaving.value = false;
    }
  }
}