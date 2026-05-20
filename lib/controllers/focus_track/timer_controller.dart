import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/models/focus_track/timer_model.dart';

class TimerController extends GetxController {
  Box<TimerModel> get timerBox => Hive.box<TimerModel>('timer_box');

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
        if ((runningSeconds[key] ?? 0) > 0) {
          runningSeconds[key] = runningSeconds[key]! - 1;

          if (runningSeconds[key]! % 10 == 0) {
            _updateHiveSeconds(key, runningSeconds[key]!);
          }
        } else {
          activeTimerKeys.remove(key);
          _updateHiveSeconds(key, 0);
        }
      }
    });
  }

  void initTimerState(dynamic key, int remainingSeconds) {
    if (!runningSeconds.containsKey(key)) {
      runningSeconds[key] = remainingSeconds;
    }
  }

  void resetTimerMemory(dynamic key) {
    activeTimerKeys.remove(key);
    runningSeconds.remove(key);
  }

  // void toggleTimer(dynamic key) {
  //   if (activeTimerKeys.contains(key)) {
  //     activeTimerKeys.remove(key);
  //     _updateHiveSeconds(key, runningSeconds[key]!);
  //   } else {
  //     TimerModel? timer = timerBox.get(key);
  //     if (timer != null) {
  //       if (runningSeconds[key] == null || runningSeconds[key]! <= 0) {
  //         runningSeconds[key] = timer.totalSeconds;
  //       }
  //       activeTimerKeys.add(key);
  //     }
  //   }
  // }
  void toggleTimer(dynamic timerKey) {
    // Find the original timer from your Hive box
    final timer = timerBox.get(timerKey);
    if (timer == null) return;

    if (activeTimerKeys.contains(timerKey)) {
      // If it's running, pause it
      activeTimerKeys.remove(timerKey);
    } else {
      // If it's finished or canceled (0 seconds remaining), reset its time before starting!
      int currentSec = runningSeconds[timerKey] ?? timer.remainingSeconds;
      if (currentSec <= 0) {
        runningSeconds[timerKey] = timer.totalSeconds;
        timer.remainingSeconds = timer.totalSeconds;
        timer.save();
      }

      // Add to active keys to start the tick loop
      activeTimerKeys.add(timerKey);
    }
  }

  void _updateHiveSeconds(dynamic key, int seconds) {
    TimerModel? timer = timerBox.get(key);
    if (timer != null) {
      timer.remainingSeconds = seconds;
      if (seconds <= 0) timer.completedAt = DateTime.now();
      timer.save();
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
    return h > 0 ? "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}" : "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String formatToHMS(int totalSeconds) {
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
