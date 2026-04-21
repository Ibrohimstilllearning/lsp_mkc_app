import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

class FormAk01Controller extends GetxController {
  // ── Data dari GET (read-only) ─────────────────────────────────────────────
  final isLoadingData = true.obs;
  final fetchError = ''.obs;
  final fetchErrorCode = ''.obs;

  final certificationName = ''.obs;
  final certificationCode = ''.obs;
  final tuk = ''.obs;
  final asesorName = ''.obs;
  final asesiName = ''.obs;
  final evidenceMethods = <Map<String, dynamic>>[].obs;
  final agreementDate = ''.obs;
  final agreementTime = ''.obs;
  final agreementTuk = ''.obs;

  // ── TTD Asesi ─────────────────────────────────────────────────────────────
  final ttdAsesiBytes = Rx<Uint8List?>(null);

  // ── Loading & error submit ────────────────────────────────────────────────
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ── Fetch GET ─────────────────────────────────────────────────────────────
  Future<void> fetchData({required int registrationId}) async {
    isLoadingData.value = true;
    fetchError.value = '';
    fetchErrorCode.value = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
          '${ApiEndpoints.baseUrl}/registrations/$registrationId/ak01');

      debugPrint('[AK01 GET] URL: $url');

      final response = await http.get(
        url,
        headers: ApiEndpoints.authHeaders(token), // ✅ pakai ini
      );

      debugPrint('[AK01 GET] Status: ${response.statusCode}');
      debugPrint('[AK01 GET] Body  : ${response.body}');

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final data = json['response'] ?? {};

        final scheme = data['certification_scheme'] ?? {};
        certificationName.value = scheme['name'] ?? '';
        certificationCode.value = scheme['code'] ?? '';
        tuk.value = data['tuk'] ?? '';
        asesorName.value = data['asesor_name'] ?? '';
        asesiName.value = data['asesi_name'] ?? '';

        final methods = data['evidence_methods'];
        if (methods != null && methods is List) {
          evidenceMethods.value = List<Map<String, dynamic>>.from(methods);
        }

        final agreement = data['agreement_time'] ?? {};
        agreementDate.value = agreement['date'] ?? '';
        agreementTime.value = agreement['time'] ?? '';
        agreementTuk.value = agreement['tuk'] ?? '';
      } else {
        fetchErrorCode.value =
            json['metadata']?['code']?.toString() ??
            response.statusCode.toString();
        fetchError.value =
            json['metadata']?['message'] ??
            json['message'] ??
            'Terjadi kesalahan';
      }
    } catch (e) {
      debugPrint('[AK01 GET] Error: $e');
      fetchErrorCode.value = 'NETWORK';
      fetchError.value = 'Koneksi bermasalah, coba lagi.';
    } finally {
      isLoadingData.value = false;
    }
  }

  // ── Submit POST ───────────────────────────────────────────────────────────
  Future<bool> submit({required int registrationId}) async {
    if (ttdAsesiBytes.value == null) {
      Get.snackbar(
        'Perhatian',
        'Tanda tangan belum diisi',
        backgroundColor: const Color(0xFFFFF3CD),
        colorText: const Color(0xFF856404),
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        Get.snackbar('Sesi Habis', 'Silakan login ulang',
            backgroundColor: const Color(0xFFFFEDED),
            colorText: const Color(0xFF991B1B),
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      final signatureB64 =
          'data:image/png;base64,${base64Encode(ttdAsesiBytes.value!)}';

      final payload = {
        'name': asesiName.value.isNotEmpty ? asesiName.value : 'Asesi',
        'date': dateStr,
        'signature': signatureB64,
      };

      final url = Uri.parse(
          '${ApiEndpoints.baseUrl}/registrations/$registrationId/ak01');

      debugPrint('[AK01 POST] URL    : $url');
      debugPrint('[AK01 POST] name   : ${payload['name']}');
      debugPrint('[AK01 POST] date   : ${payload['date']}');
      debugPrint('[AK01 POST] sig len: ${signatureB64.length}');

      final response = await http.post(
        url,
        headers: ApiEndpoints.authHeaders(token), // ✅ pakai ini
        body: jsonEncode(payload),
      );

      debugPrint('[AK01 POST] Status : ${response.statusCode}');
      debugPrint('[AK01 POST] Body   : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
  // Auto refresh pengajuan list
  try {
    Get.find<PengajuanController>().fetchPengajuan();
  } catch (_) {}
  return true;
} else {
        final body = jsonDecode(response.body);
        if (response.statusCode == 422) {
          final errors = body['errors'];
          if (errors != null) {
            final firstError = (errors as Map).values.first;
            errorMessage.value = firstError is List
                ? firstError.first
                : firstError.toString();
          } else {
            errorMessage.value = body['message'] ?? 'Data tidak valid';
          }
        } else {
          errorMessage.value =
              body['message'] ?? 'Terjadi kesalahan, coba lagi.';
        }
        Get.snackbar('Gagal', errorMessage.value,
            backgroundColor: const Color(0xFFFFEDED),
            colorText: const Color(0xFF991B1B),
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      debugPrint('[AK01 POST] Error: $e');
      errorMessage.value = 'Koneksi bermasalah, coba lagi.';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: const Color(0xFFFFEDED),
          colorText: const Color(0xFF991B1B),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}