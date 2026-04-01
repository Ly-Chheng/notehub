import 'package:flutter/material.dart';
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
                title: "Note Background",
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      Colors.white,
                      const Color(0xFFFFF9C4),
                      const Color(0xFFF8BBD0),
                      const Color(0xFFE1F5FE),
                      const Color(0xFFE8F5E9),
                      const Color(0xFFFFE0B2),
                      const Color(0xFFEDE7F6),
                      const Color(0xFFD1C4E9),
                      const Color(0xFFF3E5F5),
                      const Color(0xFFFFEBEE),
                      const Color(0xFFFFF3E0),
                      const Color(0xFFE0F7FA),
                      const Color(0xFFF1F8E9),
                      const Color(0xFFFFFDE7),
                      const Color(0xFFECEFF1),
                      const Color(0xFFD7CCC8),
                      const Color(0xFFFFCDD2),
                      const Color(0xFFB2EBF2),
                      const Color(0xFFC8E6C9),
                      const Color(0xFFFFF59D),
                      const Color(0xFFCFD8DC),
                    ].map((color) {
                      // Check if this specific circle is the active one
                      bool isActive = selectedColor == color;

                      return GestureDetector(
                        onTap: () {
                          onColorSelected(color);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 100,
                          height: 60,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: isActive
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.blue,
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
