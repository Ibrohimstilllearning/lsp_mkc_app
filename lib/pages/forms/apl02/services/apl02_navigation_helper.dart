import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/api_endpoints.dart';

Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); // token login user
}

/// Ambil userId dari API /api/user
Future<int?> fetchCurrentUserId() async {
  final token = await _getToken();
  if (token == null) return null;

  final url = Uri.parse('${ApiEndpoints.baseUrl}/api/user');
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    return decoded['response']['id'] as int;
  }
  return null;
}

/// Ambil registrationId valid dari backend
Future<int?> fetchLatestRegistrationIdForUser(int userId) async {
  final token = await _getToken();
  if (token == null) return null;

  // Ganti endpoint sesuai backend yang ada, contoh:
  final url = Uri.parse('${ApiEndpoints.baseUrl}/api/registrations?user_id=$userId');
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body)['response'] as List;
    final latest = list.firstWhere(
      (r) => r['status_apl01'] == 'approved' && r['status_apl02'] == 'not_started',
      orElse: () => null,
    );
    if (latest != null) return latest['id'] as int;
  }
  return null;
}

/// Navigasi ke FormApl02
Future<void> goToFormApl02() async {
  final userId = await fetchCurrentUserId();
  if (userId == null) {
    Get.snackbar('Error', 'User belum login');
    return;
  }

  final registrationId = await fetchLatestRegistrationIdForUser(userId);
  if (registrationId == null) {
    Get.snackbar('Info', 'Belum ada registration APL-02 yang valid untuk user ini');
    return;
  }

  // Navigasi dengan Map arguments
  Get.toNamed('/apl02', arguments: {
    'registrationId': registrationId,
    'userId': userId,
  });
}