import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class SelectionBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  const SelectionBottomBar({
    super.key,
    required this.selectedCount,
    required this.onMove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: context.isPhone ? 50 : 60,
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildBottomAction(
            Icons.folder,
            AppColor().primaryColor,
            onMove,
            context,
          ),
          Text(
            '$selectedCount ${'selected'.tr}',
            style: text10,
          ),
          buildBottomAction(
            Icons.delete,
            AppColor().red,
            onDelete,
            context,
          ),
        ],
      ),
    );
  }
}

Widget buildBottomAction(IconData icon, Color color, VoidCallback onTap, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: context.isPhone ? 25 : 30,
        ),
      ],
    ),
  );
}
