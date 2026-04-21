import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/pages/forms/apl02/model/response.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/submit.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResponseProvider {
  final String baseUrl = ApiEndpoints.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<ResponseRegistration?> getDatabyId(int registrationId) async {
    final url = Uri.parse('$baseUrl/registrations/$registrationId/apl02');
    try {
      final token = await _getToken();
      final headers = token != null ? ApiEndpoints.authHeaders(token) : ApiEndpoints.headers;
      
      print('APL02 Fetch URL: $url');
      final response = await http.get(url, headers: headers);
      print('APL02 Fetch Status: ${response.statusCode}');
      print('APL02 Fetch Body: ${response.body}');
      
      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);
        // Sometimes backend returns 'data' instead of 'response'
        var dataKey = decoded.containsKey('response') ? decoded['response'] : (decoded.containsKey('data') ? decoded['data'] : decoded);
        return ResponseRegistration.fromJson(dataKey);
      }
      return null;
    } catch (e) {
      print('error fetchin APL02: $e');
      return null;
    }
  }

  Future<bool> postDatabyId(int registrationId, SubmitApl02Request payload) async {
    final url = Uri.parse("$baseUrl/registrations/$registrationId/apl02");
    try {
      final token = await _getToken();
      final headers = token != null ? ApiEndpoints.authHeaders(token) : ApiEndpoints.headers;
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload.toJson())
      );
      print('APL02 Post Status: ${response.statusCode}');
      print('APL02 Post Body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('error post APL02: $e');
      return false;
    }
  } 
}
