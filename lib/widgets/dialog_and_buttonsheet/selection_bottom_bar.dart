import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/multi_style.dart';

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
      height: 50,
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
