import 'package:get/get.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  var isLastPage = false.obs;

  void onPageChanged(int index) {
    isLastPage.value = index == 2;
  }

  Future<void> loadingScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Get.offAllNamed(AppPages.loading);
  }
}