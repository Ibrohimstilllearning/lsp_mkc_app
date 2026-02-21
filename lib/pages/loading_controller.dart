import 'package:get/get.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart'; // Import ini

class LoadingController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 5), () {
      // Gunakan variabel dari AppPages agar sinkron dengan daftar route kamu
      Get.offAllNamed(AppPages.login); 
    });
  }
}