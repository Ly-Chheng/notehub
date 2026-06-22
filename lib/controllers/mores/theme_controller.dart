
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DarkModeController extends GetxController {
  bool darkStatus = false;

  final _getStorage = GetStorage();
  final _toggleKey = 'isToggle';

  DarkModeController() {
    if (_getStorage.read(_toggleKey) != null) {
      darkStatus = _getStorage.read(_toggleKey);
    }
    update();
  }

  darkToggle(darkValue) {
    darkStatus = darkValue;
    _getStorage.write(_toggleKey, darkValue);
    update();
  }
}
