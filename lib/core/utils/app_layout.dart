import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

class Layout {
  static Widget spacerH([double size = 0.01]) {
    return SizedBox(height: Get.height * size);
  }

  static Widget spacerW([double size = 0.01]) {
    return SizedBox(width: Get.height * size);
  }

  static double size(double phoneValue, double tabletValue) {
    return Get.context!.isPhone ? phoneValue : tabletValue;
  }

  static double get smallSize => size(40.0, 50.0);
  static double get mediumSize => size(55.0, 65.0);
  static double get largeSize => size(80.0, 100.0);

  static EdgeInsetsGeometry padding() {
    return EdgeInsets.symmetric(
      vertical: Get.height * 0.01,
      horizontal: Get.height * 0.02,
    );
  }

  static double responsive(double phoneValue, double tabletValue) {
    return Get.context!.isPhone ? phoneValue : tabletValue;
  }

  static BoxDecoration subtleDecoration({
    Color color = Colors.grey,
    double radius = 18.0,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(radius),
      // boxShadow: AppDecorations.subtleShadow,
    );
  }

  static BoxDecoration cardDecoration({
    double radius = 10.0,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: Theme.of(Get.context!).cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadows ?? AppDecorations.subtleShadow,
    );
  }

  static BoxDecoration defaultDecoration({
    double radius = 10.0,
    bool isBorder = false,
    bool isShadow = false,
    Color? color,
    Color? borderColor,
    List<BoxShadow>? customShadows,
  }) {
    return BoxDecoration(
      color: color ?? Theme.of(Get.context!).cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: isBorder ? Border.all(color: borderColor ?? Colors.grey.shade300) : null,
      boxShadow: isShadow
          ? (customShadows ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ])
          : [],
    );
  }
}
