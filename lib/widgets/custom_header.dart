import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

Widget customHeader(String title, BuildContext context) {
  return Text(
    title,
    style: TextStyle(
      fontSize: AppFontSize(context).titleSize,
      fontFamily: 'EN-BOLD',
      color: Theme.of(context).textTheme.bodyLarge?.color,
    ),
  );
}
