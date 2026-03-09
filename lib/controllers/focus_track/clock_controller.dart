import 'dart:async';

import 'package:get/get.dart';

class ClockController extends GetxController {
  var dateTime = DateTime.now().obs;
  var isAnalog = true.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Update every 100ms for smooth second hand
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      dateTime.value = DateTime.now();
    });
  }

  void toggleClockType() => isAnalog.value = !isAnalog.value;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
