import 'package:get/get.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), () {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppPages.home);
    } else if (!hasSeenOnboarding) {
      Get.offAllNamed(AppPages.onboarding);
    } else {
      Get.offAllNamed(AppPages.login);
    }
  }
}