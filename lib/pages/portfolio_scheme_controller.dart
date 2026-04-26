import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/scheme.dart';

class PortfolioSchemeController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final schemeList = <Scheme>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSchemes();
  }

  Future<void> fetchSchemes() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${ApiEndpoints.baseUrl}/schemes');
      debugPrint('[SCHEME] GET $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint('[SCHEME] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['response'] ?? json['data'] ?? [];
        schemeList.assignAll(
          data.map((e) {
            // Karena model Scheme mewajibkan 'units', namun endpoint /schemes
            // mungkin tidak mengembalikannya. Kita siapkan penanganan aman.
            if (e is Map<String, dynamic>) {
               e['units'] ??= [];
            }
            return Scheme.fromJson(e);
          }).toList(),
        );
      } else {
        hasError.value = true;
      }
    } catch (e) {
      debugPrint('[SCHEME] Error: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
