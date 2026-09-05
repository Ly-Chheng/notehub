import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

Future<TimeOfDay?> customTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  final appColors = AppColor();
  final primaryColor = appColors.primaryColor;
  final whiteColor = appColors.white;
  final cardColor = Theme.of(context).cardColor;
  final surfaceTextColor = text16(context).color ?? AppColor().black;

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
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              textStyle: text16(context).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: cardColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            dayPeriodColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return primaryColor.withValues(alpha: 0.15);
              }
              return AppColor().gray.withValues(alpha: 0.15);
            }),
            dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return primaryColor;
              }
              return surfaceTextColor.withValues(alpha: 0.6);
            }),
            dayPeriodBorderSide: BorderSide(
              color: primaryColor.withValues(alpha: 0.5),
              width: 1,
            ),
            dialBackgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(179, 50, 50, 50) : const Color.fromARGB(179, 245, 245, 245),
            dialHandColor: primaryColor,
            dialTextColor: surfaceTextColor,
            entryModeIconColor: primaryColor,
          ),
        ),
        child: Localizations.override(
          context: context,
          locale: Get.locale ?? const Locale('km', 'KM'),
          child: child!,
        ),
      );
    },
  );
}
