import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

PopupMenuItem<String> buildPopupItem(BuildContext context, String title, IconData icon, {Color? color}) {
  return PopupMenuItem<String>(
    value: title,
    child: Row(
      children: [
        Icon(icon, size: context.isPhone ? 20 : 25),
        SizedBox(width: context.isPhone ? 20 : 25),
        Text(
          title,
          style: text14(context),
        ),
      ],
    ),
  );
}
