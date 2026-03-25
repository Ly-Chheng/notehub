import 'package:flutter/material.dart';
import 'package:project_structure/widgets/sheet_header.dart';

void showFormatSheet({
  required BuildContext context,
  required bool isBold,
  required bool isItalic,
  required bool isUnderlined,
  required Function(bool) onStrikethroughChanged,
  required bool isStrikethrough,
  required Color selectedColor,
  required Function(bool) onBoldChanged,
  required Function(bool) onItalicChanged,
  required Function(bool) onUnderlineChanged,
  required Function(Color) onColorChanged,
  required VoidCallback onBulletPressed,
  required VoidCallback onNumberedPressed,
  required VoidCallback onHyphenPressed,
  required bool isLeftAligned,
  required bool isCenterAligned,
  required bool isRightAligned,
  required VoidCallback onLeftAlignPressed,
  required VoidCallback onCenterAlignPressed,
  required VoidCallback onRightAlignPressed,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetHeader(
                title: "Format Text",
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _formatToggle(Icons.format_bold, isBold, () {
                                isBold = !isBold;
                                onBoldChanged(isBold);
                                setSheetState(() {});
                              }),
                              _formatToggle(Icons.format_italic, isItalic, () {
                                isItalic = !isItalic;
                                onItalicChanged(isItalic);
                                setSheetState(() {});
                              }),
                              _formatToggle(Icons.format_underlined, isUnderlined, () {
                                isUnderlined = !isUnderlined;
                                onUnderlineChanged(isUnderlined);
                                setSheetState(() {});
                              }),
                              _formatToggle(Icons.format_strikethrough, isStrikethrough, () {
                                isStrikethrough = !isStrikethrough;
                                onStrikethroughChanged(isStrikethrough);
                                setSheetState(() {});
                              }),
                              _formatToggle(Icons.format_align_left, isLeftAligned, () {
                                onLeftAlignPressed();
                                Navigator.pop(context);
                              }),
                              _formatToggle(Icons.format_align_center, isCenterAligned, () {
                                onCenterAlignPressed();
                                Navigator.pop(context);
                              }),
                              _formatToggle(Icons.format_align_right, isRightAligned, () {
                                onRightAlignPressed();
                                Navigator.pop(context);
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          _formatToggle(Icons.format_list_bulleted, false, () {
                            onBulletPressed();
                            Navigator.pop(context);
                          }),
                          _formatToggle(Icons.format_line_spacing_rounded, false, () {
                            onHyphenPressed();
                            Navigator.pop(context);
                          }),
                          _formatToggle(Icons.format_list_numbered, false, () {
                            onNumberedPressed();
                            Navigator.pop(context);
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      0XFF9500FF,
                      0XFFFF0000,
                      0XFF002AFC,
                      0XFF2196F3,
                      0XFF4CAF50,
                      0XFFFF9800,
                      0XFF000000,
                      0xFFFFC107,
                      0xFF9C27B0,
                      0xFFE91E63,
                      0xFF00BCD4,
                      0xFF8BC34A,
                      0xFFFF5722,
                      0xFF607D8B,
                      0xFF795548,
                    ].map((colorValue) {
                      Color color = Color(colorValue);
                      return GestureDetector(
                        onTap: () {
                          onColorChanged(color);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 15,
                            //child: selectedColor == color ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }),
  );
}

Widget _formatToggle(IconData icon, bool isActive, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? Colors.blue : Colors.grey.shade300),
        ),
        child: Icon(icon, color: isActive ? Colors.blue : Colors.grey,size: 23,),
      ),
    ),
  );
}
