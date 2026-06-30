import 'package:flutter/material.dart';
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
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColor().primaryColor,
            onPrimary: AppColor().white,
            surface: Theme.of(context).cardColor,
            onSurface: text16(context).color ?? Colors.black,
          ),
          // Action button styling overrides (OK / CANCEL buttons)
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

 // onTap: () async {
                    //   final DateTime? picked = await showDatePicker(
                    //     context: context,
                    //     //  initialDate: _selectedDate.isBefore(DateTime.now()) ? DateTime.now() : _selectedDate,
                    //     initialDate: _selectedDate.isBefore(DateTime.now()) ? DateTime.now() : _selectedDate,
                    //     firstDate: DateTime.now(),
                    //     lastDate: DateTime(2035),
                    //     builder: (BuildContext context, Widget? child) {
                    //       return Theme(
                    //         data: Theme.of(context).copyWith(
                    //           colorScheme: ColorScheme.light(
                    //             primary: AppColor().primaryColor,
                    //             onPrimary: AppColor().white,
                    //             surface: AppColor().white,
                    //             onSurface: text16(context).color ?? Colors.black,
                    //           ),
                    //           textButtonTheme: TextButtonThemeData(
                    //             style: TextButton.styleFrom(
                    //               foregroundColor: AppColor().primaryColor,
                    //               textStyle: text16(context).copyWith(fontWeight: FontWeight.bold),
                    //             ),
                    //           ),
                    //           dialogTheme: DialogThemeData(
                    //             backgroundColor: AppColor().white,
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(20),
                    //             ),
                    //           ),
                    //           datePickerTheme: DatePickerThemeData(
                    //             headerBackgroundColor: AppColor().primaryColor,
                    //             headerForegroundColor: AppColor().white,
                    //             surfaceTintColor: Colors.transparent,
                    //           ),
                    //         ),
                    //         child: child!,
                    //       );
                    //     },
                    //   );

                    //   if (picked != null) {
                    //     setState(() {
                    //       _selectedDate = picked;
                    //       if (_reminderDate.isAfter(_selectedDate)) {
                    //         _reminderDate = _selectedDate;
                    //       }
                    //     });
                    //   }
                    //   //   if (picked != null) {
                    //   //     setState(() {
                    //   //       _selectedDate = picked;
                    //   //       // Automatically pull reminder date back to event date if it exceeds it
                    //   //       if (_reminderDate.isAfter(_selectedDate)) {
                    //   //         _reminderDate = _selectedDate;
                    //   //       }
                    //   //     });
                    // },