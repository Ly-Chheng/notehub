import 'dart:async';
import 'package:get/get.dart';

class StopwatchController extends GetxController {
  Timer? _timer;

  var milliseconds = 0.obs;
  var isRunning = false.obs;
  var laps = <String>[].obs;

  void startStopwatch() {
    if (isRunning.value) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        milliseconds.value += 10;
      });
    }
    isRunning.toggle();
  }

  void resetStopwatch() {
    _timer?.cancel();
    milliseconds.value = 0;
    isRunning.value = false;
    laps.clear();
  }

  void addLap() {
    laps.insert(0, formatTime(milliseconds.value));
  }

  String formatTime(int ms) {
    int hundreds = (ms % 1000) ~/ 10;
    int seconds = (ms ~/ 1000) % 60;
    int minutes = (ms ~/ 60000) % 60;

    return "${minutes.toString().padLeft(2, '0')}:"
           "${seconds.toString().padLeft(2, '0')}:"
           "${hundreds.toString().padLeft(2, '0')}";
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}