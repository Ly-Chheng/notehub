import 'package:get/get.dart';

class FontSizeController extends GetxController {
  // Global observable font size
  var fontSize = 18.0.obs;

  void updateFontSize(double newSize) {
    fontSize.value = newSize;
  }
}