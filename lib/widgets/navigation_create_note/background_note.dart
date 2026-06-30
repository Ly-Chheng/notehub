import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_sheet_header.dart';

void showPaletteSheet({
  required BuildContext context,
  required Color selectedColor,
  required Function(Color) onColorSelected,
}) {
  final size = context.isPhone ? 6.0 : 8.0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxWidth: double.infinity),
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(
              title: "backgrounds".tr,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: size,
              runSpacing: size,
              children: AppColor().backgroundColors(context).map((color) {
                bool isActive = selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: context.isPhone ? 80 : 100,
                    height: context.isPhone ? 60 : 80,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: isActive
                        ? Icon(
                            Icons.check,
                            color: AppColor().primaryColor,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
}
