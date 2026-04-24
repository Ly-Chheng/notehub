import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

class AnimatedFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isVisible;

  const AnimatedFab({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: isVisible ? Offset.zero : const Offset(0, 2),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1 : 0,
        child: FloatingActionButton(
          backgroundColor: AppColor().primaryColor,
          onPressed: isVisible ? onPressed : null,
          child: Icon(
            icon,
            color: AppColor().white,
            size: context.isPhone ? 30 : 40,
          ),
        ),
      ),
    );
  }
}
