// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_structure/core/utils/app_color.dart';

class ThemeService {
  // light mode color
  final lightTheme = ThemeData.light().copyWith(
    hoverColor: AppColor().black,
    scaffoldBackgroundColor: AppColor().white,
    primaryColor: AppColor().primaryColor,
  );

  // dark mode color
  final darkTheme = ThemeData.dark().copyWith(
    hoverColor: AppColor().white,
    scaffoldBackgroundColor: AppColor().darkPrimaryColor,
    primaryColor: AppColor().darkPrimaryColor,
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
