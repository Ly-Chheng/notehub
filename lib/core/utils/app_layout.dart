import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Layout {
  static Widget spacerH([double size = 0.01]) {
    return SizedBox(height: Get.height * size);
  }

  static Widget spacerW([double size = 0.01]) {
    return SizedBox(width: Get.height * size);
  }

  static EdgeInsetsGeometry padding() {
    return EdgeInsets.symmetric(
      vertical: Get.height * 0.01,
      horizontal: Get.height * 0.02,
    );
  }

  static double responsive(double phoneValue, double tabletValue) {
    return Get.context!.isPhone ? phoneValue : tabletValue;
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ])
          : [],
    );
  }
}
