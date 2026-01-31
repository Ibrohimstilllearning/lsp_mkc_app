import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/auth/login_controller.dart';
import 'package:lsp_mkc_app/pages/auth/login_page.dart';
import 'package:lsp_mkc_app/pages/loading_controller.dart';
import 'package:lsp_mkc_app/pages/loading_page.dart';
import 'package:lsp_mkc_app/pages/onboarding_controller.dart';
import 'package:lsp_mkc_app/pages/onboarding_page.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class AppRoutes {
  static List<GetPage<dynamic>> getRoutes() => [
    GetPage(
      name: AppPages.onboarding, 
      page: () =>  OnboardingPage(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }), 
    ),
    GetPage(
      name: AppPages.loading, 
      page: () =>  LoadingPage(),
      binding: BindingsBuilder(() {
        Get.put(LoadingController());
      }), 
    ),
    GetPage(
      name: AppPages.login, 
      page: () =>  LoginPage(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }), 
    ),
  ];
}