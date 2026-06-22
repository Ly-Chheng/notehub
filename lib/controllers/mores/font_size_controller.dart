import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeController extends GetxController {
  static const _key = 'font_scale';
  final RxDouble fontScale = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadFontScale();
  }

  Future<void> loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    fontScale.value = prefs.getDouble(_key) ?? 1.0;
  }

  Future<void> setFontScale(double value) async {
    fontScale.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, value);
  }
}
