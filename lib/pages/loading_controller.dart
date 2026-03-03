import 'package:get/get.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 5), () {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (token != null && token.isNotEmpty) {
      // sudah login → langsung home
      Get.offAllNamed(AppPages.home);
    } else if (!hasSeenOnboarding) {
      // belum pernah buka app → onboarding
      Get.offAllNamed(AppPages.onboarding);
    } else {
      // sudah lihat onboarding tapi belum login → login
      Get.offAllNamed(AppPages.login);
    }
  }
}