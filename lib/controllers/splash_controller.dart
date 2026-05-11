import 'dart:async';
import 'package:get/get.dart';
import 'package:project_structure/views/bottom_navigation_bar/navigationbar.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Timer(
      const Duration(seconds: 4),
      () => Get.off(
        const BottomNavigationBarScreen(),
      ),
    );
  }
}
