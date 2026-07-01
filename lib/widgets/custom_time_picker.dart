import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  // Cache theme values to prevent multiple class instantiations inside the builder
  final appColors = AppColor();
  final primaryColor = appColors.primaryColor;
  final whiteColor = appColors.white;
  final cardColor = Theme.of(context).cardColor;
  final surfaceTextColor = text16(context).color ?? Colors.black;

  return await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: whiteColor,
            surface: cardColor,
            onSurface: surfaceTextColor,
          ),
          // Action buttons styling overrides (OK / CANCEL)
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              textStyle: text16(context).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // Dialog border curvature matching the date picker
          dialogTheme: DialogThemeData(
            backgroundColor: cardColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Individual time picker structural stylings
          timePickerTheme: TimePickerThemeData(
            dayPeriodColor: primaryColor.withValues(alpha: 0.15),
            dayPeriodTextColor: primaryColor,
            dialBackgroundColor: const Color.fromARGB(179, 245, 245, 245),
            dialHandColor: primaryColor,
            dialTextColor: surfaceTextColor,
            entryModeIconColor: primaryColor,
          ),
        ),
        // child: child!,
        child: Localizations.override(
          context: context,
          locale: Get.locale ?? const Locale('km', 'KM'),
          child: child!,
        ),
      );
    },
  );
}
