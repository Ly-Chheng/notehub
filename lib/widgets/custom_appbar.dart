import 'dart:io';
import 'package:flutter/material.dart';

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
    centerTitle: false,
    titleSpacing: 10,
    // backgroundColor:
    //     backgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
    backgroundColor: backgroundColor ?? Color(0xFFF8F9FB),
    title: Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: titleColor ?? Colors.black,
        fontSize: 20,
        fontFamily: 'EN-BOLD',
      ),
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
    // actions: actions,
    /// Actions
    actions: actions?.map((action) {
      return action;
    }).toList(),
  );
}
