import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

customAppBar({
  required String title,
  final Color? backgroundColor,
  final Color? leadingColor,
  final Color? titleColor,
  final Widget? leading,
  List<Widget>? actions,
  required BuildContext context,
  final bool isLeading = true,
  void Function()? onTap,
}) {
  return AppBar(
    elevation: 0,
    centerTitle: true,
    backgroundColor:
        backgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
    title: Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: appbarTextSyle(),
    ),
    automaticallyImplyLeading: false,
    leading: isLeading
        ? Platform.isAndroid
            ? GestureDetector(
                onTap: onTap ??
                    () {
                      Navigator.pop(context);
                    },
                child: Icon(
                  Icons.arrow_back,
                  color: leadingColor ?? Colors.white,
                ),
              )
            : GestureDetector(
                onTap: onTap ??
                    () {
                      Navigator.pop(context);
                    },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: leadingColor ?? Colors.white,
                ),
              )
        : leading,
    actions: actions,
  );
}
