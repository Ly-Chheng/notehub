import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AppSlidableAction extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;

  const AppSlidableAction({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.textStyle,
    this.borderRadius,
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
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'EN-REGULAR',
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
