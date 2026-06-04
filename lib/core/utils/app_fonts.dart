import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String rengular = 'EN-REGULAR';
const String sumibold = 'EN-SEMIBOLD';
const String bold = 'EN-BOLD';

// Font Size Custom
class AppFontSize {
  late double extraLargeSize;
  late double titleSize;
  late double subTitleSize;
  late double mediumLargeSize;
  late double largeSize;
  late double descriptionLargeSize;
  late double normalTextSize;
  late double subNormalSize;
  late double smallSize;

  AppFontSize(BuildContext context) {
    extraLargeSize = Get.context!.isPhone ? 22 : 24;
    titleSize = Get.context!.isPhone ? 20 : 22;
    mediumLargeSize = Get.context!.isPhone ? 18 : 20;
    subTitleSize = Get.context!.isPhone ? 16 : 18;
    descriptionLargeSize = Get.context!.isPhone ? 14 : 16;
    normalTextSize = Get.context!.isPhone ? 12 : 14;
    subNormalSize = Get.context!.isPhone ? 10 : 12;
    smallSize = Get.context!.isPhone ? 8 : 10;
  }
}

titleTextSyle() {
  return TextStyle(
    fontFamily: rengular,
    fontSize: AppFontSize(Get.context!).subTitleSize,
  );
}

TextStyle text10 = TextStyle(
  fontSize: AppFontSize(Get.context!).subNormalSize,
  // fontFamily: rengular,
  fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-BOLD' : 'EN-BOLD',
);

TextStyle text12 = TextStyle(
  fontSize: AppFontSize(Get.context!).normalTextSize,
  fontFamily: rengular,
);

TextStyle text14(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(Get.context!).descriptionLargeSize,
    fontFamily: rengular,
    fontFamilyFallback: const ['KH-REGULAR'],
  );
}

TextStyle text16(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(Get.context!).subTitleSize,
    fontFamily: rengular,
    fontFamilyFallback: const ['KH-REGULAR'],
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle text18(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(context).mediumLargeSize,
    fontFamily: bold,
    fontFamilyFallback: const ['KH-BOLD'],
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle text20(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(Get.context!).titleSize,
    fontFamily: bold,
    fontFamilyFallback: const ['KH-BOLD'],
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle text22(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(context).extraLargeSize,
    fontFamily: bold,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle custom({
  required BuildContext context,
  required double phone,
  required double tablet,
  String fontFamily = rengular,
  FontWeight? weight,
  Color? color,
}) {
  final isPhone = Get.context!.isPhone;
  final size = isPhone ? phone : tablet;

  return TextStyle(
    fontSize: size,
    fontFamily: fontFamily,
    fontWeight: weight,
    color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
  );
}

Widget customHeader(String title, BuildContext context) {
  return Text(
    title,
    style: TextStyle(
      fontSize: AppFontSize(context).titleSize,
      // fontFamily: 'EN-BOLD',
      fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-BOLD' : 'EN-BOLD',
      color: Theme.of(context).textTheme.bodyLarge?.color,
    ),
  );
}
