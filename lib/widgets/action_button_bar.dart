import 'package:flutter/cupertino.dart';
import 'package:project_structure/core/utils/app_color.dart';

Widget actionButton({required String asset, required bool isEnabled, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: isEnabled ? onTap : null,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Image.asset(
        asset,
        width: 22,
        height: 22,
        color: isEnabled ? AppColor().white : AppColor().gray,
      ),
    ),
  );
}