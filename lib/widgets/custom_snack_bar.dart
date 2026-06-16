import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

class AppSnackbar {
  static void showError({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      "",
      "",
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor().red,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
      titleText: Text(
        title,
        style: TextStyle(
          fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
          color: AppColor().white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
          color: AppColor().white,
          fontSize: 14,
        ),
      ),
    );
  }

  static void showSuccess({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      "",
      "",
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor().green,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
      titleText: Text(
        title,
        style: TextStyle(
          fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
          color: AppColor().white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
          color: AppColor().white,
          fontSize: 14,
        ),
      ),
    );
  }

  static void showWarning({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor().orange,
      colorText: AppColor().white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      icon: Icon(
        Icons.warning,
        color: AppColor().white,
      ),
      duration: const Duration(seconds: 2),
    );
  }
}