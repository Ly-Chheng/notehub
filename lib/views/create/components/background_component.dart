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
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => SizedBox(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetHeader(
                title: "Backgrounds",
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    // children: [
                    //   // Colors.white,
                    //   Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : Colors.white,
                    //   const Color(0xFFBCAAA4),
                    //   const Color(0xFFA5D6A7),
                    //   const Color(0xFFFFCC80),
                    //   const Color(0xFFB2EBF2),
                    //   const Color(0xFF81D4FA),
                    //   const Color(0xFF90CAF9),
                    //   const Color(0xFF9FA8DA),
                    //   const Color(0xFFFFF59D),
                    //   const Color(0xFFFFAB91),
                    //   const Color(0xFFF48FB1),
                    //   const Color(0xFFCE93D8),
                    //   const Color(0xFFD5F5E3),
                    //   const Color(0xFFFCF3CF),
                    //   const Color(0xFFEBDEF0),
                    //   const Color(0xFFFAD7A0),
                    //   const Color(0xFFF5B7B1),
                    //   const Color(0xFFAEB6BF),
                    //   const Color(0xFFD6DBDF),
                    //   const Color(0xFFE5E8E8),
                    //   const Color(0xFFEDBB99),
                    //   const Color(0xFF85C1E9),
                    //   const Color(0xFF7DCEA0),
                    //   const Color(0xFFF7DC6F),
                    //   const Color(0xFFBB8FCE),
                    // ].map((color) {
                    //   // Check if this specific circle is the active one
                    //   bool isActive = selectedColor == color;

                    //   return GestureDetector(
                    //     onTap: () {
                    //       onColorSelected(color);
                    //       Navigator.pop(context);
                    //     },
                    //     child: Container(
                    //       width: 80,
                    //       height: 60,
                    //       decoration: BoxDecoration(
                    //         color: color,
                    //         borderRadius: BorderRadius.circular(15),
                    //         border: Border.all(color: Colors.black12),
                    //       ),
                    //       child: isActive
                    //           ? Icon(
                    //               Icons.check,
                    //               color: AppColor().primaryColor,
                    //             )
                    //           : null,
                    //     ),
                    //   );
                    // }).toList(),
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
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
