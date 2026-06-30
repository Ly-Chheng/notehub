import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class AppSlidableAction extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final double? iconSize;

  const AppSlidableAction({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.textStyle,
    this.borderRadius,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (_) => onPressed(),
      backgroundColor: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: iconSize ?? 24,
          ),
          const SizedBox(height: 4),
          Text(label,
              style: textStyle ??
                  text16(context).copyWith(
                    color: AppColor().white,
                  )),
        ],
      ),
    );
  }
}
