import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/app_color.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;
  final EdgeInsets? padding;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? borderColor;
  final double? borderWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.borderRadius,
    this.padding,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColor().primaryColor,
        padding: padding ??
            EdgeInsets.symmetric(
              vertical: context.isPhone ? 12 : 16,
            ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          side: borderColor != null
              ? BorderSide(
                  color: borderColor!,
                  width: borderWidth ?? 1,
                )
              : BorderSide.none,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: context.isPhone ? 16 : 18,
                    fontFamily: 'KH-SemiBold',
                  ),
                ),
              ],
            ),
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: button,
    );
  }
}
