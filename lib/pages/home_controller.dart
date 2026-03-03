import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  Future<void> logoutMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        var headers = {
          ...ApiEndpoints.headers,
          'Authorization': 'Bearer $token',
        };
        var url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.logoutPoint);
        final response = await http.post(url, headers: headers);
        print('Logout status: ${response.statusCode}');
        print('Logout body: ${response.body}');
      }

      await prefs.remove('token');
      Get.offAllNamed(AppPages.login);
    } catch (e) {
      print('Logout error: $e');
      // tetap logout meski API gagal
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Get.offAllNamed(AppPages.login);
    }
  }
}