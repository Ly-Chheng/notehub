import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class FolderListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const FolderListTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.folder,
        color: AppColor().primaryColor,
      ),
      title: Text(
        title,
        style: text16(context),
      ),
      onTap: onTap,
    );
  }
}
