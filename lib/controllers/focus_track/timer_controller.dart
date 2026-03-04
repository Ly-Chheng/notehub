import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TimerController extends GetxController {
  final Box timerBox = Hive.box('timer_box');
  
  // Observables for real-time UI updates
  var runningSeconds = <dynamic, int>{}.obs; 
  var activeTimerKeys = <dynamic>{}.obs;
  
  Timer? _globalTimer;

  @override
  void onInit() {
    super.onInit();
    _startGlobalTimer();
  }

  void _startGlobalTimer() {
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      for (var key in activeTimerKeys.toList()) {
        if (runningSeconds.containsKey(key) && runningSeconds[key]! > 0) {
          runningSeconds[key] = runningSeconds[key]! - 1;
        } else {
          activeTimerKeys.remove(key);
          // You can add a notification or vibration trigger here
        }
      }
    });
  }

  // Initialize the local state for a specific timer
  void initTimerState(dynamic key, int totalSeconds) {
    if (!runningSeconds.containsKey(key)) {
      runningSeconds[key] = totalSeconds;
    }
  }

  void toggleTimer(dynamic key) {
    if (activeTimerKeys.contains(key)) {
      activeTimerKeys.remove(key);
    } else {
      if (runningSeconds[key]! > 0) {
        activeTimerKeys.add(key);
      } else {
        // Reset and Play if it was at zero
        final data = timerBox.get(key);
        runningSeconds[key] = data['totalSeconds'];
        activeTimerKeys.add(key);
      }
    }
  }

  void deleteTimer(dynamic key) {
    activeTimerKeys.remove(key);
    runningSeconds.remove(key);
    timerBox.delete(key);
  }

  String formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void onClose() {
    _globalTimer?.cancel();
    super.onClose();
  }
}