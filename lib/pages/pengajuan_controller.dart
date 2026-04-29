import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:lsp_mkc_app/utils/api_helper.dart';

class RegistrationForm {
  final String code;
  final String label;
  final String status;

  RegistrationForm({
    required this.code,
    required this.label,
    required this.status,
  });

  factory RegistrationForm.fromJson(Map<String, dynamic> json) =>
      RegistrationForm(
        code: json['code'] ?? '',
        label: json['label'] ?? '',
        status: json['status'] ?? 'draft',
      );
}

class RegistrationItem {
  final int registrationId;
  final int schemeId;
  final String schemeName;
  final String schemeCode;
  final String createdAt;
  final String? finalResult; // Tambahan untuk validasi
  final List<RegistrationForm> forms;

  RegistrationItem({
    required this.registrationId,
    required this.schemeId,
    required this.schemeName,
    required this.schemeCode,
    required this.createdAt,
    this.finalResult,
    required this.forms,
  });

  factory RegistrationItem.fromJson(Map<String, dynamic> json) =>
      RegistrationItem(
        registrationId: int.tryParse(json['registration_id']?.toString() ?? '') ??
            int.tryParse(json['id']?.toString() ?? '') ?? 0,
        schemeId: int.tryParse(json['scheme_id']?.toString() ?? '') ??
            int.tryParse(json['scheme']?['id']?.toString() ?? '') ?? 0,
        schemeName: json['scheme_name'] ?? json['scheme']?['name'] ?? '-',
        schemeCode: json['scheme_code'] ?? json['scheme']?['code'] ?? '-',
        createdAt: _formatDate(json['created_at']),
        finalResult: json['final_result']?.toString(),
        forms: (json['forms'] as List<dynamic>? ?? [])
            .map((f) => RegistrationForm.fromJson(f))
            .toList(),
      );

  static String _formatDate(String? dt) {
    if (dt == null || dt.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dt).toLocal();
      return DateFormat('dd MMM yyyy HH:mm').format(parsed);
    } catch (_) {
      return dt; // fallback ke string asli jika gagal parse
    }
  }

  bool get isActive {
    // Sesuai instruksi backend: jika final_result belum terisi berarti regis masih berjalan
    return finalResult == null || finalResult!.trim().isEmpty;
  }
}

class PengajuanController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final pengajuanList = <RegistrationItem>[].obs;

  bool get hasActiveRegistration {
    // Karena list pengajuan sekarang BANYA memuat pengajuan aktif, cek apakah kosong atau tidak
    return pengajuanList.isNotEmpty;
  }
  final isCancelling = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPengajuan();
  }

  Future<void> fetchPengajuan() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/registrations'),
        headers: ApiEndpoints.authHeaders(token),
      );

      debugPrint('[PENGAJUAN] Status: ${response.statusCode}');
      debugPrint('[PENGAJUAN] Body  : ${response.body}');

      final data = ApiHelper.handleResponse(response);
      if (data != null) {
        final List list = data['response'] ?? [];
        final allItems = list.map((e) => RegistrationItem.fromJson(e)).toList();
        
        // HANYA ambil yang masih aktif / belum kelar (final_result belum ada)
        pengajuanList.assignAll(allItems.where((item) => item.isActive).toList());
      } else {
        hasError.value = true;
      }
    } catch (e) {
      ApiHelper.handleException(e);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// CANCEL REGISTRATION (Saat ini backend belum support)
  Future<void> cancelRegistration(int registrationId) async {
    if (isCancelling.value) return;

    try {
      isCancelling.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}/registrations/$registrationId'),
        headers: ApiEndpoints.authHeaders(token),
      );

      debugPrint('[CANCEL] Status: ${response.statusCode}');
      debugPrint('[CANCEL] Body  : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        pengajuanList.removeWhere((e) => e.registrationId == registrationId);
        ApiHelper.showSuccess('Pengajuan berhasil dibatalkan');
      } else if (response.statusCode == 404) {
        ApiHelper.showError('Fitur batal pengajuan belum diaktifkan oleh backend.\nID: $registrationId');
        // Refresh list agar data tetap up-to-date
        await fetchPengajuan();
      } else {
        ApiHelper.handleResponse(response); // akan muncul error message dari ApiHelper
      }
    } catch (e) {
      ApiHelper.handleException(e);
    } finally {
      isCancelling.value = false;
    }
  }
}