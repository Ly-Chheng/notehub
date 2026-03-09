import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TimerController extends GetxController {
  final Box timerBox = Hive.box('timer_box');

  // Observable maps to track time and status in real-time
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
          _updateHiveSeconds(key, 0); // Mark as finished in database
        }
      }
    });
  }

  // Critical for Edit: Forces the UI to fetch fresh data from Hive
  void resetTimerMemory(dynamic key) {
    activeTimerKeys.remove(key);
    runningSeconds.remove(key);
  }

  void initTimerState(dynamic key, int currentSeconds) {
    if (!runningSeconds.containsKey(key)) {
      runningSeconds[key] = currentSeconds;
    }
  }

  void toggleTimer(dynamic key) {
    if (activeTimerKeys.contains(key)) {
      activeTimerKeys.remove(key);
      _updateHiveSeconds(key, runningSeconds[key]!); // Save pause state
    } else {
      // If restarting a finished timer
      if ((runningSeconds[key] ?? 0) <= 0) {
        final data = timerBox.get(key);
        runningSeconds[key] = data['totalSeconds'];
        _updateHiveSeconds(key, data['totalSeconds']); // <--- THIS MOVES IT IN HIVE
      }
      activeTimerKeys.add(key);
    }
  }

  void _updateHiveSeconds(dynamic key, int seconds) {
    var data = timerBox.get(key);
    if (data != null) {
      data['remainingSeconds'] = seconds;
      timerBox.put(key, data);
    }
  }

  void deleteTimer(dynamic key) {
    activeTimerKeys.remove(key);
    runningSeconds.remove(key);
    timerBox.delete(key);
  }

  // Converts seconds to 00:00:00 format
  String formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  // Converts seconds to "1h 5m 30s" format
  String formatToHMS(int totalSeconds) {
    if (totalSeconds <= 0) return "0s";
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    List<String> parts = [];
    if (h > 0) parts.add("${h}h");
    if (m > 0) parts.add("${m}m");
    if (s > 0 || parts.isEmpty) parts.add("${s}s");
    return parts.join(" ");
  }

  @override
  void onClose() {
    _globalTimer?.cancel();
    super.onClose();
  }
}
