import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/pages/forms/apl02/model/response.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

class Apl02Controller extends GetxController {
  var isLoading = false.obs;
  var registrationData = Rxn<ResponseRegistration>();
  var errorMessage = ''.obs;

  Future<void> fetchRegistrationInfo(int registrationId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}/registrations/$registrationId/apl02',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // API wraps data inside "response" key
        final data = body['response'] as Map<String, dynamic>;
        registrationData.value = ResponseRegistration.fromJson(data);
      } else {
        errorMessage.value =
            'Gagal memuat data (${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }
}