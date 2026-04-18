import 'package:get/get.dart';

class BottomNavController extends GetxController {
  //Active index page, default 0 (HomePage)
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
