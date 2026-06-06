import 'package:get/get.dart';

class FontSizeController extends GetxController {
  var fontSize = 18.0.obs;

  void updateFontSize(double newSize) {
    fontSize.value = newSize;
  }
}
