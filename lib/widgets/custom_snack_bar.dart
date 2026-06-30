import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

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
      titleText: Text(title,
          style: text16(Get.context!).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColor().white,
          )),
      messageText: Text(message, style: text14(Get.context!).copyWith()),
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
      titleText: Text(title,
          style: text16(Get.context!).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColor().white,
          )),
      messageText: Text(message, style: text14(Get.context!).copyWith()),
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
