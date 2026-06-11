import 'package:flutter/material.dart';
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
        borderRadius: BorderRadius.circular(12),
      ),
      onPressed: onPressed,
      child: Icon(Icons.add, size: 30, color: AppColor().white),
    );
  }
}
