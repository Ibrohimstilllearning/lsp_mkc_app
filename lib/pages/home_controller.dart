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
