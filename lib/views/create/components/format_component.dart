import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
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
  required Function(String) onFontSizeChanged,
  required bool isJustifyAligned,
  required VoidCallback onJustifyAlignPressed,
}) {
  bool isColorPickerOpen = false;
  String activeSize = 'Normal';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHeader(
                title: "Format Text",
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildContainer(
                      context,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            _formatToggle(Icons.format_align_justify, isJustifyAligned, () {
                              onJustifyAlignPressed();
                              Navigator.pop(context);
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _buildContainer(
                    context,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Row(
                children: [
                  _buildContainer(
                    context,
                    SingleChildScrollView(
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _buildContainer(
                    context,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _formatToggle(Icons.format_color_text, isColorPickerOpen, () {
                            setSheetState(() {
                              isColorPickerOpen = !isColorPickerOpen;
                            });
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: isColorPickerOpen ? 80 : 0,
                curve: Curves.easeInOut,
                child: isColorPickerOpen
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: _buildContainer(
                          context,
                          SingleChildScrollView(
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
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: CircleAvatar(
                                      backgroundColor: color,
                                      radius: 20,
                                      child: selectedColor.value == color.value ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Font Size",
                style: TextStyle(
                  fontSize: context.isPhone ? 14 : 16,
                  fontFamily: 'EN-SEMIBOLD',
                ),
              ),
              _buildContainer(
                context,
                SizedBox(
                  height: 43,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: ['Small', 'Normal', 'Large', 'Huge'].map((size) {
                      bool isSelected = activeSize == size;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() => activeSize = size);
                          onFontSizeChanged(size.toLowerCase());
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          height: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColor().primaryColor : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColor().primaryColor : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                              fontFamily: 'EN-REGULAR',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }),
  );
}

Widget _buildContainer(BuildContext context, Widget child) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );
}

Widget _formatToggle(IconData icon, bool isActive, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? Colors.blue : Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey,
          size: 25,
        ),
      ),
    ),
  );
}
