import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/api_endpoints.dart';

Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); // kunci token standar
}

/// Fetch userId dari /api/user (baseUrl sudah include /api)
Future<int?> fetchCurrentUserId() async {
  final token = await _getToken();
  if (token == null) return null;

  final url = Uri.parse('${ApiEndpoints.baseUrl}/user');
  final response = await http.get(url,
      headers: ApiEndpoints.authHeaders(token));

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final user = json['response'] ?? json['data'] ?? json;
    return user['id'] as int?;
  }
  return null;
}

/// Fetch registration_id terbaru yang valid untuk user ini
Future<int?> fetchLatestRegistrationIdForUser(int userId) async {
  final token = await _getToken();
  if (token == null) return null;

  // baseUrl sudah include /api, jadi cukup /registrations
  final url = Uri.parse('${ApiEndpoints.baseUrl}/registrations');
  final response = await http.get(url,
      headers: ApiEndpoints.authHeaders(token));

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final list = (decoded['response'] ?? decoded['data'] ?? []) as List;
    if (list.isEmpty) return null;

    // Cari registrasi yang APL01 sudah approved dan APL02 belum selesai
    final valid = list.firstWhere(
      (r) =>
          (r['status_apl01'] == 'approved') &&
          (r['status_apl02'] == 'not_started' ||
              r['status_apl02'] == 'draft' ||
              r['status_apl02'] == 'pending'),
      orElse: () => null,
    );

    if (valid != null) {
      return valid['registration_id'] as int? ??
          valid['id'] as int?;
    }

    // Fallback: ambil registration terbaru saja
    final latest = list.last;
    return latest['registration_id'] as int? ?? latest['id'] as int?;
  }
  return null;
}

/// Navigasi ke FormApl02 dengan registrationId yang benar
Future<void> goToFormApl02() async {
  final token = await _getToken();
  if (token == null) {
    Get.snackbar('Error', 'Sesi habis, silakan login kembali.');
    return;
  }

  final userId = await fetchCurrentUserId();
  if (userId == null) {
    Get.snackbar('Error', 'Gagal mendapatkan data user.');
    return;
  }

  final registrationId = await fetchLatestRegistrationIdForUser(userId);
  if (registrationId == null) {
    Get.snackbar(
      'Info',
      'Belum ada registrasi APL-02 yang dapat diakses. Pastikan APL-01 sudah disetujui.',
      duration: const Duration(seconds: 4),
    );
    return;
  }

  Get.toNamed('/apl02', arguments: {'registrationId': registrationId});
}