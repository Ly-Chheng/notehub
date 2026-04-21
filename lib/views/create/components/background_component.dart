import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/sheet_header.dart';

void showPaletteSheet({
  required BuildContext context,
  required Color selectedColor,
  required Function(Color) onColorSelected,
}) {
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
              title: "Backgrounds",
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: AppColor().backgroundColors(context).map((color) {
                bool isActive = selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 80,
                    height: 60,
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
