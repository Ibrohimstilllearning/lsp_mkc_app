import 'package:get/get.dart';
import 'package:lsp_mkc_app/controller/bottom_nav_controller.dart';
import 'package:lsp_mkc_app/pages/auth/login_controller.dart';
import 'package:lsp_mkc_app/pages/auth/login_page.dart';
import 'package:lsp_mkc_app/pages/auth/register_page.dart';
import 'package:lsp_mkc_app/pages/auth/registration_controller.dart';
import 'package:lsp_mkc_app/pages/auth/reset_controller.dart';
import 'package:lsp_mkc_app/pages/auth/reset_page.dart';
import 'package:lsp_mkc_app/pages/auth/verify_controller.dart';
import 'package:lsp_mkc_app/pages/auth/verify_page.dart';
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01.dart';
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01_controller.dart';
import 'package:lsp_mkc_app/pages/forms/ak/form_ak01.dart';
import 'package:lsp_mkc_app/pages/forms/ak/form_ak01_controller.dart';
import 'package:lsp_mkc_app/pages/forms/ak/form_ak04.dart';
import 'package:lsp_mkc_app/pages/forms/ak/form_ak04_controller.dart';
import 'package:lsp_mkc_app/pages/forms/ak/form_ak07.dart';
import 'package:lsp_mkc_app/pages/forms/ak/form_ak07_controller.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/apl02_controller.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/apl_02.dart';
import 'package:lsp_mkc_app/pages/home_controller.dart';
import 'package:lsp_mkc_app/pages/home_page.dart';
import 'package:lsp_mkc_app/pages/loading_controller.dart';
import 'package:lsp_mkc_app/pages/loading_page.dart';
import 'package:lsp_mkc_app/pages/onboarding_controller.dart';
import 'package:lsp_mkc_app/pages/onboarding_page.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';
import 'package:lsp_mkc_app/pages/profil_controller.dart';
import 'package:lsp_mkc_app/pages/riwayat_controller.dart';
import 'package:lsp_mkc_app/pages/document_controller.dart';
import 'package:lsp_mkc_app/pages/document_page.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class AppRoutes {
  static List<GetPage<dynamic>> getRoutes() => [
    GetPage(
      name: AppPages.onboarding,
      page: () => OnboardingPage(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: AppPages.loading,
      page: () => LoadingPage(),
      binding: BindingsBuilder(() {
        Get.put(LoadingController());
      }),
    ),
    GetPage(
      name: AppPages.login,
      page: () => LoginPage(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    GetPage(
      name: AppPages.register,
      page: () => const RegisterPage(),
      binding: BindingsBuilder(() {
        Get.put(RegistrationController());
      }),
    ),
    GetPage(
      name: AppPages.verify,
      page: () => VerifyPage(),
      binding: BindingsBuilder(() {
        Get.put(VerifyController());
      }),
    ),
    GetPage(
      name: AppPages.home,
      page: () => HomePage(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
        Get.put(BottomNavController());
        Get.lazyPut(() => PengajuanController());
        Get.lazyPut(() => RiwayatController());
        Get.lazyPut(() => ProfilController());
        Get.lazyPut(() => DocumentController());
      }),
    ),
    GetPage(
      name: AppPages.reset,
      page: () => ResetPage(),
      binding: BindingsBuilder(() {
        Get.put(ResetController());
      }),
    ),

    // ✅ FIX: baca arguments di binding, set selectedSchemeId setelah controller dibuat
    GetPage(
      name: AppPages.apl01,
      page: () => const FormApl01(),
      binding: BindingsBuilder(() {
        // ✅ Buat controller dulu
        final controller = Get.put(FormApl01Controller());

        // ✅ Baca arguments DI SINI — saat binding jalan, arguments sudah tersedia
        final args = Get.arguments;
        if (args != null && args is Map<String, dynamic>) {
          final scheme = args['selectedScheme'];
          if (scheme != null) {
            controller.selectedSchemeId = scheme.id as int?;
            print('[APL01] selectedSchemeId dari binding: ${controller.selectedSchemeId}');
          }
        }
      }),
    ),

    GetPage(
      name: AppPages.apl02,
      page: () {
        final args = (Get.arguments is Map<String, dynamic>)
            ? Get.arguments as Map<String, dynamic>
            : <String, dynamic>{};
        final registrationId = args['registrationId'] as int? ?? 0;
        return FormApl02(registrationId: registrationId);
      },
      binding: BindingsBuilder(() {
        Get.put(Apl02Controller(), tag: 'apl02');
      }),
    ),
    GetPage(
      name: AppPages.ak01,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final registrationId = args['registrationId'] as int? ?? 0;
        return FormAk01(registrationId: registrationId);
      },
      binding: BindingsBuilder(() {
        Get.put(FormAk01Controller());
      }),
    ),
    GetPage(
      name: AppPages.ak04,
      page: () => const FormAk04(),
      binding: BindingsBuilder(() {
        Get.put(FormAk04Controller());
      }),
    ),
    GetPage(
      name: AppPages.ak07,
      page: () => const FormAk07(),
      binding: BindingsBuilder(() {
        Get.put(FormAk07Controller());
      }),
    ),
    GetPage(
      name: AppPages.document,
      page: () => const DocumentPage(),
      binding: BindingsBuilder(() {
        Get.put(DocumentController());
      }),
    ),
  ];
}