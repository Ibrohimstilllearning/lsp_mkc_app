import 'package:get/get.dart';

  
  class LoadingController extends GetxController {
  
  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(seconds: 5), () {
      Get.offAllNamed('/login');
    });
  }
  }