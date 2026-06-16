import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFonts {
  // English Fonts "Nunito"
  String fontEngRegular = 'EN-REGULAR';
  String fontEngMedium = 'EN-SEMIBOLD';
  String fontEngBold = 'EN-BOLD';
  String fontExBold = 'EN-BOLD';

  // Khmer Fonts "Battambang"
  String fontKhRegular = 'KH-REGULAR';
  String fontKhMedium = 'KH-SEMIBOLD';
  String fontKhBold = 'KH-BOLD';
  String fontkhExBold = 'KH-BOLD';

  String fontRegular = 'Regular-Font';
  String fontMedium = 'Medium-Font';
  String fontBold = 'Bold-Font';
  String fontEBold = 'Nunito-Extrabold';
}

// Font Family and font weight Custom
class AppFontStyle {
  String regularFont = AppFonts().fontRegular;
  String mediumFont = AppFonts().fontMedium;
  String boldFont = AppFonts().fontBold;
  String fontebold = AppFonts().fontEBold;

  String fontRegular = Get.locale == const Locale('km', 'KM') ? AppFonts().fontKhRegular : AppFonts().fontEngRegular;
  String fontMedium = Get.locale == const Locale('km', 'KM') ? AppFonts().fontKhMedium : AppFonts().fontEngMedium;
  String fontBold = Get.locale == const Locale('km', 'KM') ? AppFonts().fontKhBold : AppFonts().fontEngBold;
}

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


//Custom font 
titleTextSyle() {
  return TextStyle(
    fontFamily: AppFonts().fontEngRegular,
    fontSize: AppFontSize(Get.context!).subTitleSize,
  );
}

TextStyle text10 = TextStyle(
  fontSize: AppFontSize(Get.context!).subNormalSize,
  fontFamily: AppFontStyle().fontRegular,
);

TextStyle text12 = TextStyle(
  fontSize: AppFontSize(Get.context!).normalTextSize,
  fontFamily: AppFontStyle().fontRegular,
);

TextStyle text14(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(Get.context!).descriptionLargeSize,
    fontFamily: AppFontStyle().fontRegular,
  );
}

TextStyle text16(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(Get.context!).subTitleSize,
    fontFamily: AppFontStyle().fontRegular,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle text18(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(context).mediumLargeSize,
    fontFamily: AppFontStyle().fontBold,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle text20(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(Get.context!).titleSize,
    fontFamily: AppFontStyle().fontBold,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle text22(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(context).extraLargeSize,
    fontFamily: AppFontStyle().fontBold,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

Widget customHeader(String title, BuildContext context) {
  return Text(
    title,
    style: TextStyle(
      fontSize: AppFontSize(context).titleSize,
      fontFamily: AppFontStyle().fontBold,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    ),
  );
}

TextStyle font16(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(Get.context!).subTitleSize,
    fontFamily: AppFonts().fontEngBold,
    fontFamilyFallback: const ['KH-BOLD'],
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle font18(BuildContext context) {
  return TextStyle(
    fontSize: AppFontSize(Get.context!).mediumLargeSize,
    fontFamily: AppFonts().fontEngBold,
    fontFamilyFallback: const ['KH-BOLD'],
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}
