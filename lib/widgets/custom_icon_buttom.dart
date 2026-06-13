import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

Widget formatToggle(IconData icon, bool isActive, VoidCallback onTap, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 5 : 10),
      child: Container(
        padding: EdgeInsets.all(context.isPhone ? 5 : 10),
        decoration: BoxDecoration(
          color: isActive ? AppColor().primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppColor().primaryColor : Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          color: isActive ? AppColor().primaryColor : AppColor().gray,
          size: context.isPhone ? 25 : 35,
        ),
      ),
    ),
  );
}

Widget toolBtn(String label, bool sel, VoidCallback tap, {String? imagePath, IconData? icon, BuildContext? context}) {
  return InkWell(
    onTap: tap,
    borderRadius: BorderRadius.circular(8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imagePath != null)
          Image.asset(
            imagePath,
            width: sel ? 60 : 40,
            height: sel ? 60 : 40,
            colorBlendMode: BlendMode.srcIn,
          )
        else if (icon != null)
          Icon(
            icon,
            size: context!.isPhone ? 24 : 30,
          ),
      ],
    ),
  );
}
