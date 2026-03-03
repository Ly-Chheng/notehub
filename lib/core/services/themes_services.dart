// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  // // light mode color
  // final lightTheme = ThemeData.light().copyWith(
  //   hoverColor: AppColor().black,
  //   scaffoldBackgroundColor: AppColor().white,
  //   primaryColor: AppColor().primaryColor,
  // );

  // // dark mode color
  // final darkTheme = ThemeData.dark().copyWith(
  //   hoverColor: AppColor().white,
  //   scaffoldBackgroundColor: AppColor().darkPrimaryColor,
  //   primaryColor: AppColor().darkPrimaryColor,
  // );
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FB), // background
    cardColor: Colors.white, // card background in light mode
    primaryColor: const Color(0xFF3D5DFF), // primary app color
    iconTheme: const IconThemeData(color: Colors.black87),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
    ),
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212), // background
    cardColor: const Color(0xFF1E1E1E), // card background in dark mode
    primaryColor: const Color(0xFF3D5DFF), // primary app color
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
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
