import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String rengular = 'EN-REGULAR';
const String sumibold = 'EN-SEMIBOLD';
const String bold = 'EN-BOLD';
const String khRengular = 'KH-REGULAR';
const String khSemibold = 'KH-SEMIBOLD';
const String khBold = 'KH-BOLD';

appbarTextSyle() {
  return TextStyle(
    fontFamily: rengular,
    fontSize: 18,
  );
}

dashboardTextStyle() {
  return const TextStyle(
    fontFamily: rengular,
    fontSize: 14,
  );
}

titleTextSyle() {
  return const TextStyle(
    fontFamily: rengular,
    fontSize: 16,
  );
}

TextStyle text10 = const TextStyle(
  fontSize: 10,
  fontFamily: rengular,
);

TextStyle text12 = const TextStyle(
  fontSize: 12,
  fontFamily: rengular,
);

TextStyle text14(BuildContext context) {
  return TextStyle(
    fontSize: context.isPhone ? 14 : 16,
    fontFamily: rengular,
    fontFamilyFallback: const ['KH-REGULAR'],
  );
}

TextStyle text16(BuildContext context) {
  return TextStyle(
    fontSize: context.isPhone ? 16 : 18,
    fontFamily: rengular,
    fontFamilyFallback: const ['KH-REGULAR'],
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle text18(BuildContext context) {
  return TextStyle(
    fontSize: context.isPhone ? 18 : 20,
    fontFamily: bold,
    fontFamilyFallback: const ['KH-BOLD'],
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle text20(BuildContext context) {
  return TextStyle(
    fontSize: context.isPhone ? 20 : 22,
    fontFamily: bold,
    fontFamilyFallback: const ['KH-BOLD'],
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}

TextStyle text22(BuildContext context) {
  return TextStyle(
    fontSize: context.isPhone ? 22 : 25,
    fontFamily: bold,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
}
