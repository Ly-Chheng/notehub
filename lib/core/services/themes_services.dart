// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_structure/core/utils/app_color.dart';

class ThemeService {
  // light mode color
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FB), // background
    cardColor: AppColor().white, // card background in light mode
    primaryColor: AppColor().primaryColor,
    iconTheme: const IconThemeData(color: Colors.black87),
    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: Colors.black),
      bodyMedium: const TextStyle(color: Colors.black87),
      bodySmall: const TextStyle(color: Colors.black54),
      titleLarge: TextStyle(
        color: AppColor().black,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: const TextStyle(color: Colors.black87),
      titleSmall: const TextStyle(color: Colors.black54),
      labelLarge: const TextStyle(color: Colors.black),
    ),
  );

  // dark mode color
  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212), // background
    cardColor: const Color(0xFF1E1E1E), // card background in dark mode
    primaryColor: AppColor().primaryColor,
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColor().white),
      bodyMedium: const TextStyle(color: Colors.white70),
      bodySmall: const TextStyle(color: Colors.white60),
      titleLarge: TextStyle(
        color: AppColor().white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: const TextStyle(color: Colors.white70),
      titleSmall: const TextStyle(color: Colors.white60),
      labelLarge: TextStyle(color: AppColor().white),
    ),
  );

  final _getStorage = GetStorage();
  final _darkThemeKey = 'isDarkTheme';

  void saveThemeData(bool isDarkMode) {
    _getStorage.write(_darkThemeKey, isDarkMode);
  }

  bool isSavedDarkMode() {
    return _getStorage.read(_darkThemeKey) ?? false;
  }

  ThemeMode getThemeMode() {
    return isSavedDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  void changeTheme() {
    Get.changeThemeMode(isSavedDarkMode() ? ThemeMode.light : ThemeMode.dark);
    saveThemeData(!isSavedDarkMode());
  }
}
