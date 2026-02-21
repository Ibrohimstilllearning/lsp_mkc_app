import 'package:get/get.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  // var currentPage = 0.obs;
  var isLastPage = false.obs;

  void onPageChanged(int index) {
    isLastPage.value = index == 2;
  }

  void loadingScreen() {
    Get.offAllNamed(AppPages.loading);
  }
}
