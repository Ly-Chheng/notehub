import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_structure/core/services/sound_servies.dart';
import 'package:project_structure/core/utils/app_color.dart';
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
    centerTitle: false,
    titleSpacing: 15,
    scrolledUnderElevation: 0,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    title: Text(title,
        overflow: TextOverflow.ellipsis,
        style: text20(context).copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        )),
    automaticallyImplyLeading: false,
    leading: isLeading
        ? Platform.isAndroid
            ? GestureDetector(
                onTap: onTap ??
                    () {
                      SoundService.stopSound();
                      Navigator.pop(context);
                    },
                child: Icon(
                  Icons.arrow_back,
                  color: leadingColor ?? AppColor().primaryColor,
                ),
              )
            : GestureDetector(
                onTap: onTap ??
                    () {
                      Navigator.pop(context);
                    },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: leadingColor ?? AppColor().primaryColor,
                ),
              )
        : leading,
    actions: actions?.map((action) {
      return action;
    }).toList(),
  );
}
