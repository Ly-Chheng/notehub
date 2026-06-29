import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

class SelectionModeToggle extends StatelessWidget {
  final bool hasNoData;
  final bool isSelectionMode;
  final VoidCallback? onToggle;

  const SelectionModeToggle({
    super.key,
    required this.hasNoData,
    required this.isSelectionMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColor().white;
    final Color disabledColor = AppColor().gray;
    final Color currentColor = hasNoData ? disabledColor : activeColor;

    return InkWell(
      onTap: hasNoData ? null : onToggle,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        height: context.isPhone ? 24 : 30,
        width: context.isPhone ? 24 : 30,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: currentColor, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Icon(
            isSelectionMode ? Icons.close : Icons.more_vert_outlined,
            size: 18,
            color: currentColor,
          ),
        ),
      ),
    );
  }
}
