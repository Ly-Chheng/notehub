import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';


class FolderListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;

  const FolderListTile({
    super.key,
    required this.title,
    required this.onTap,
    this.icon = Icons.folder,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColor().primaryColor,
        size: iconSize ?? (context.isPhone ? 20 : 25),
      ),
      title: Text(
        title,
        style: text16(context),
      ),
      onTap: onTap,
    );
  }
}
