import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import '../../core/utils/app_color.dart';

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
        shadowColor: Colors.transparent,
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
          ? SizedBox(
              height: context.isPhone ? 25 : 30,
              width: context.isPhone ? 25 : 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor().white,
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? AppColor().white,
                    fontSize: AppFontSize(context).subTitleSize,
                    fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
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

class GrobleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final IconData icon;
  final Color? color;

  const GrobleButton({
    super.key,
    required this.onPressed,
    this.size = 30.0,
    this.icon = Icons.delete,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: color ?? AppColor().red,
        size: size,
      ),
      onPressed: onPressed,
    );
  }
}
