import 'dart:async';
import 'package:get/get.dart';
import 'package:project_structure/views/BottomNavigationBar/navigationbar.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Timer(
      const Duration(seconds: 5),
      () => Get.off(
        const BottomNavigationBarScreen(),
      ),
    );
  }
}
