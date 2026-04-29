import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  final List<RegistrationForm> forms;

  RegistrationItem({
    required this.registrationId,
    required this.schemeId,
    required this.schemeName,
    required this.schemeCode,
    required this.createdAt,
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
        createdAt: json['created_at'] ?? '',
        forms: (json['forms'] as List<dynamic>? ?? [])
            .map((f) => RegistrationForm.fromJson(f))
            .toList(),
      );
}

class PengajuanController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final pengajuanList = <RegistrationItem>[].obs;

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

      final data = ApiHelper.handleResponse(response);
      if (data != null) {
        final List list = data['response'] ?? [];
        pengajuanList.assignAll(
          list.map((e) => RegistrationItem.fromJson(e)).toList(),
        );
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
}