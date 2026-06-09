import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/core/services/firebase_services.dart';
import 'package:project_structure/core/services/sound_servies.dart';
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
          if (runningSeconds[key] == 0) {
            final timerData = timerBox.get(key);
            if (timerData != null) {
              SoundService.playTimerSound(timerData.sound);

              FirebaseServices.showTimerFinishedNotification(
                title: "timer_finished".tr,
                body: "${timerData.title} ${'has_completed'.tr}",
              );
            }

            activeTimerKeys.remove(key);
            _updateHiveSeconds(key, 0);
          } else if (runningSeconds[key]! % 10 == 0) {
            _updateHiveSeconds(key, runningSeconds[key]!);
          }
        } else {
          activeTimerKeys.remove(key);
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

  void toggleTimer(dynamic timerKey) {
    final timer = timerBox.get(timerKey);
    if (timer == null) return;

    if (activeTimerKeys.contains(timerKey)) {
      activeTimerKeys.remove(timerKey);
    } else {
      int currentSec = runningSeconds[timerKey] ?? timer.remainingSeconds;
      if (currentSec <= 0) {
        runningSeconds[timerKey] = timer.totalSeconds;
        timer.remainingSeconds = timer.totalSeconds;
        timer.save();
      }

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
    if (h > 0) parts.add("$h ${'h'.tr}");
    if (m > 0) parts.add("$m ${'m'.tr}");
    if (s > 0 || parts.isEmpty) parts.add("$s ${'s'.tr}");

    return parts.join(" ");
  }

  @override
  void onClose() {
    _globalTimer?.cancel();
    super.onClose();
  }
}
