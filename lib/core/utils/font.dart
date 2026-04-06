import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFont {
  // English Fonts "Roboto"
  String fontEngRegular = 'EN-REGULAR';
  String fontEngMedium = 'EN-SEMIBOLD';
  String fontEngBold = 'EN-BOLD';
  String fontExBold = 'EN-BOLD';

  // Khmer Fonts "Battambang"
  String fontKhRegular = 'KH-LIGHT';
  String fontKhMedium = 'KH-REGULAR';
  String fontKhBold = 'KH-BOLD';
  String fontkhExBold = 'KH-BOLD';

  String fontRegular = 'Regular-Font';
  String fontMedium = 'Medium-Font';
  String fontBold = 'Bold-Font';
  String fontEBold = 'Nunito-Extrabold';
}

// Font Family and font weight Custom
class AppFontStyle {
  String regularFont = AppFont().fontRegular;
  String mediumFont = AppFont().fontMedium;
  String boldFont = AppFont().fontBold;
  String fontebold = AppFont().fontEBold;

  String fontRegular = Get.locale == const Locale('km', 'KM')
      ? AppFont().fontKhRegular
      : AppFont().fontEngRegular;
  String fontMedium = Get.locale == const Locale('km', 'KM')
      ? AppFont().fontKhMedium
      : AppFont().fontEngMedium;
  String fontBold = Get.locale == const Locale('km', 'KM')
      ? AppFont().fontKhBold
      : AppFont().fontEngBold;
}

// Font Size Custom
class AppFontSize {
  late double titleSize;
  late double subTitleSize;
  late double descriptionLargeSize;
  late double normalTextSize;
  late double subNormalSize;
  late double smallSize;

  AppFontSize(BuildContext context) {
    titleSize = Get.context!.isPhone ? 20 : 22;
    subTitleSize = Get.context!.isPhone ? 16 : 18;
    descriptionLargeSize = Get.context!.isPhone ? 14 : 16;
    normalTextSize = Get.context!.isPhone ? 12 : 14;
    subNormalSize = Get.context!.isPhone ? 10 : 12;
    smallSize = Get.context!.isPhone ? 8 : 10;
  }
}

// Custom font all for use
class Style {
  // Header TextStyle
  static TextStyle headerTextStyleBold22_24(
      BuildContext context, {
        Color? color,
      }) {
    return TextStyle(
      fontFamily: AppFontStyle().fontebold,
      fontSize: context.isPhone ? 22 : 24,
      color: color,
    );
  }

  static TextStyle subHeaderTextStyleBold20_22(
      BuildContext context, {
        Color? color,
      }) {
    return TextStyle(
      fontFamily: AppFontStyle().fontebold,
      fontSize: AppFontSize(context).titleSize,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle subHeaderTextStyleGray22_24(
      BuildContext context, {
        Color? color ,
      }) {
    return TextStyle(
      fontFamily: AppFontStyle().fontebold,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle subHeaderMedim(
      BuildContext context, {
        Color? color,
      }) {
    return TextStyle(
      fontFamily: AppFontStyle().fontMedium,
      fontSize: AppFontSize(context).subTitleSize,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle subHeaderBold(
      BuildContext context, {
        Color? color,
      }) {
    return TextStyle(
      fontFamily: AppFontStyle().fontebold,
      fontSize: AppFontSize(context).subTitleSize,
      // color: color ?? AppTheme().iconTheme,
    );
  }

  static TextStyle bodyText16_18(
      BuildContext context, {
        Color? color,
      }) {
    return TextStyle(
      fontFamily: AppFontStyle().fontRegular,
      fontSize: AppFontSize(context).subTitleSize,
    );
  }

  static TextStyle bodyText14_16(BuildContext context) {
    return TextStyle(
      fontFamily: AppFontStyle().fontRegular,
      fontSize: AppFontSize(context).descriptionLargeSize,
    );
  }

  static TextStyle small(
      BuildContext context, {
        Color? color,
      }) {
    return TextStyle(
      fontFamily: AppFontStyle().fontRegular,
      fontSize: AppFontSize(context).smallSize,
      color: Colors.grey[600],
    );
  }

  static TextStyle button(
      BuildContext context, {
        Color? color,
      }) {
    return TextStyle(
      fontFamily: AppFontStyle().fontBold,
      fontSize: (Get.context?.isPhone ?? true) ? 16 : 18,
      color: color,
    );
  }
}

