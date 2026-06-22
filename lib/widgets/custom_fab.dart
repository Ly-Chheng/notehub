import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

class CustomFab extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFab({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColor().primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.isPhone ? 12 : 16),
      ),
      onPressed: onPressed,
      child: Icon(Icons.add, size: context.isPhone ? 30 : 40, color: AppColor().white),
    );
  }
}
