import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:project_structure/models/focus_track/lap_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StopwatchController extends GetxController {
  Timer? _timer;
  var milliseconds = 0.obs;
  var isRunning = false.obs;
  var laps = <LapModel>[].obs;

  final String _prefKeyStartTime = "start_time";
  final String _prefKeyElapsed = "elapsed_ms";
  final String _keyLaps = "saved_laps";

  @override
  void onInit() {
    super.onInit();
    _loadStoredState();
    _loadLaps();
  }

  Future<void> _loadStoredState() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString(_prefKeyStartTime);
    final savedElapsed = prefs.getInt(_prefKeyElapsed) ?? 0;

    if (startTimeString != null) {
      final startTime = DateTime.parse(startTimeString);
      final now = DateTime.now();
      final diff = now.difference(startTime).inMilliseconds;
      milliseconds.value = savedElapsed + diff;
      startStopwatch();
    } else {
      milliseconds.value = savedElapsed;
    }
  }

  void startStopwatch() async {
    final prefs = await SharedPreferences.getInstance();

    if (isRunning.value) {
      _timer?.cancel();

      await prefs.setInt(_prefKeyElapsed, milliseconds.value);
      await prefs.remove(_prefKeyStartTime);
    } else {
      final now = DateTime.now();
      await prefs.setString(_prefKeyStartTime, now.toIso8601String());

      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        milliseconds.value += 10;
      });
    }
    isRunning.toggle();
  }

  // void resetStopwatch() {
  //   _timer?.cancel();
  //   milliseconds.value = 0;
  //   isRunning.value = false;
  //   laps.clear();
  // }
  Future<void> resetStopwatch() async {
    _timer?.cancel();
    milliseconds.value = 0;
    isRunning.value = false;
    laps.clear();

    // Erase persistent data from disk
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyStartTime);
    await prefs.remove(_prefKeyElapsed);
    await prefs.remove(_keyLaps);
  }

  void addLap() async {
    final newLap = LapModel(
      lapNumber: laps.length + 1,
      totalTimeMs: milliseconds.value,
      formattedTime: formatTime(milliseconds.value),
    );

    laps.insert(0, newLap);

    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = laps.map((lap) => jsonEncode(lap.toJson())).toList();
    await prefs.setStringList(_keyLaps, jsonList);
  }

  Future<void> _loadLaps() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedLaps = prefs.getStringList(_keyLaps);

    if (savedLaps != null) {
      laps.value = savedLaps.map((item) => LapModel.fromJson(jsonDecode(item))).toList();
    }
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
