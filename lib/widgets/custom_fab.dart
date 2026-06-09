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
      onPressed: onPressed,
      child: Icon(Icons.add, color: AppColor().white),
    );
  }
}
