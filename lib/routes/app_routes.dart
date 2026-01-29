import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/onboarding_controller.dart';
import 'package:lsp_mkc_app/pages/onboarding_page.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class AppRoutes {
  static getRoutes() => [
    GetPage(
      name: AppPages.onboarding, 
      page: () => const OnboardingPage(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }), 
    ),
  ];
}