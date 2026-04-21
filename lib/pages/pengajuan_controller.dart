import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

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
  final String schemeName;
  final String schemeCode;
  final String createdAt;
  final List<RegistrationForm> forms;

  RegistrationItem({
    required this.registrationId,
    required this.schemeName,
    required this.schemeCode,
    required this.createdAt,
    required this.forms,
  });

  factory RegistrationItem.fromJson(Map<String, dynamic> json) =>
      RegistrationItem(
        registrationId: json['registration_id'] ?? 0,
        schemeName: json['scheme_name'] ?? '-',
        schemeCode: json['scheme_code'] ?? '-',
        createdAt: json['created_at'] ?? '',
        forms: (json['forms'] as List<dynamic>? ?? [])
            .map((f) => RegistrationForm.fromJson(f))
            .toList(),
      );
}

class PengajuanController extends GetxController {

}