import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/response.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/submit.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

class ResponseProvider {
  final String baseUrl = ApiEndpoints.baseUrl;

  // Ambil token spesifik user
  Future<String?> _getToken(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token_user_$userId');
  }

  Future<ResponseRegistration?> getDatabyId(int registrationId, int userId) async {
    try {
      final token = await _getToken(userId);
      final headers = token != null ? ApiEndpoints.authHeaders(token) : ApiEndpoints.headers;

      final url = Uri.parse('$baseUrl/registrations/$registrationId/apl02');
      print('APL02 Fetch URL: $url');
      final response = await http.get(url, headers: headers);
      print('APL02 Fetch Status: ${response.statusCode}');
      print('APL02 Fetch Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final dataKey = decoded['response'] ?? decoded['data'] ?? decoded;
        return ResponseRegistration.fromJson(dataKey);
      }
      return null;
    } catch (e) {
      print('Error fetching APL02: $e');
      return null;
    }
  }

  Future<bool> postDatabyId(int registrationId, int userId, SubmitApl02Request payload) async {
    try {
      final token = await _getToken(userId);
      final headers = token != null ? ApiEndpoints.authHeaders(token) : ApiEndpoints.headers;

      final url = Uri.parse('$baseUrl/registrations/$registrationId/apl02');
      final response = await http.post(url, headers: headers, body: jsonEncode(payload.toJson()));
      print('APL02 Post Status: ${response.statusCode}');
      print('APL02 Post Body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error posting APL02: $e');
      return false;
    }
  }
}