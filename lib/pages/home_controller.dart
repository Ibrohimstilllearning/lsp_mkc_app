import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  // [PERUBAHAN 1] BARU - tambah variable displayName
  // .obs artinya reactive, kalau nilainya berubah
  // widget yang pakai Obx() otomatis ikut update
  var displayName = ''.obs;

  // [PERUBAHAN 2] BARU - override onInit()
  // onInit() dipanggil otomatis saat controller pertama kali dibuat
  // dipakai untuk fetch data awal
  @override
  void onInit() {
    super.onInit();
    fetchUser(); // langsung fetch nama user pas controller dibuat
  }

  // [PERUBAHAN 3] BARU - method fetchUser()
  // GET /api/user → ambil nama user yang lagi login
  // hasilnya disimpen ke displayName
  Future<void> fetchUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/user'),
        headers: ApiEndpoints.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ambil dari response/data/langsung tergantung struktur API
        final user = data['response'] ?? data['data'] ?? data;
        displayName.value = user['name'] ?? '';
      }
    } catch (e) {
      print('fetchUser error: $e');
    }
  }

  // tidak ada perubahan di logoutMethod()
  Future<void> logoutMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        var url = Uri.parse(
          ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.logoutPoint,
        );
        await http.post(url, headers: ApiEndpoints.authHeaders(token));
      }

      await prefs.remove('token');
      Get.offAllNamed(AppPages.login);
    } catch (e) {
      print('Logout error: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Get.offAllNamed(AppPages.login);
    }
  }
}