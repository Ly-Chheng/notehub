import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  // Normalize date comparison points to avoid background millisecond mismatches
  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);
  final safeInitialDate = initialDate.isBefore(firstDate) ? todayMidnight : initialDate;

  return await showDatePicker(
    context: context,
    initialDate: safeInitialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    locale: Get.locale ?? const Locale('km', 'KM'),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColor().primaryColor,
            onPrimary: AppColor().white,
            surface: Theme.of(context).cardColor,
            onSurface: text16(context).color ?? Colors.black,
          ),
          // Action (OK / CANCEL)
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColor().primaryColor,
              textStyle: text16(context).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // Structure and border curvature specifications
          dialogTheme: DialogThemeData(
            backgroundColor: Theme.of(context).cardColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Individual text component mappings
          datePickerTheme: DatePickerThemeData(
            headerBackgroundColor: AppColor().primaryColor,
            headerForegroundColor: AppColor().white,
            surfaceTintColor: Colors.transparent,
            dayStyle: text14(context),
            weekdayStyle: text14(context).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        child: child!,
      );
    },
  );
}
