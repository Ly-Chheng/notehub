import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_sheet_header.dart';

void formatNote({
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
  required Color selectedHighlightColor,
  required Function(Color) onHighlightColorChanged,
  required String initialFontSize,
}) {
  bool isColorPickerOpen = false;
  bool isHighlightPickerOpen = false;
  String activeSize = initialFontSize;

  final List<int> colorValues = [
    0XFF9500FF,
    0XFFFF0000,
    0XFF002AFC,
    0XFFFFFFFF,
    0XFF2196F3,
    0XFF4CAF50,
    0XFFFF9800,
    0XFF000000,
    0xFFFFC107,
    0xFF9C27B0,
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxWidth: double.infinity),
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
      Widget buildModernColorPicker(Color activeColor, Function(Color) onPicked) {
        return buildContainer(
          context,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: colorValues.map((val) {
                Color color = Color(val);
                bool isSelected = activeColor == color;
                return GestureDetector(
                  onTap: () {
                    onPicked(color);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedScale(
                      scale: isSelected ? 1.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: context.isPhone ? 16 : 20,
                        child: isSelected ? Icon(Icons.check, color: AppColor().white, size: context.isPhone ? 18 : 24) : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHeader(
                title: "format".tr,
              ),
              const SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.isPhone ? 10 : 20),
                child: Text(
                  "text_alignment".tr,
                  style: text14(context).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildContainer(
                      context,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            formatToggle(Icons.format_align_left, isLeftAligned, () {
                              onLeftAlignPressed();
                              Navigator.pop(context);
                            }, context),
                            formatToggle(Icons.format_align_center, isCenterAligned, () {
                              onCenterAlignPressed();
                              Navigator.pop(context);
                            }, context),
                            formatToggle(Icons.format_align_right, isRightAligned, () {
                              onRightAlignPressed();
                              Navigator.pop(context);
                            }, context),
                            formatToggle(Icons.format_align_justify, isJustifyAligned, () {
                              onJustifyAlignPressed();
                              Navigator.pop(context);
                            }, context),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: context.isPhone ? 15 : 25),
                    buildContainer(
                      context,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            formatToggle(Icons.format_list_bulleted, false, () {
                              onBulletPressed();
                              Navigator.pop(context);
                            }, context),
                            formatToggle(Icons.format_line_spacing_rounded, false, () {
                              onHyphenPressed();
                              Navigator.pop(context);
                            }, context),
                            formatToggle(Icons.format_list_numbered, false, () {
                              onNumberedPressed();
                              Navigator.pop(context);
                            }, context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.isPhone ? 15 : 25),
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.isPhone ? 10 : 20),
                child: Text(
                  "text_style".tr,
                  style: text14(context).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: [
                  buildContainer(
                    context,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          formatToggle(Icons.format_bold, isBold, () {
                            isBold = !isBold;
                            onBoldChanged(isBold);
                            setSheetState(() {});
                            Navigator.pop(context);
                          }, context),
                          formatToggle(Icons.format_italic, isItalic, () {
                            isItalic = !isItalic;
                            onItalicChanged(isItalic);
                            setSheetState(() {});
                            Navigator.pop(context);
                          }, context),
                          formatToggle(Icons.format_underlined, isUnderlined, () {
                            isUnderlined = !isUnderlined;
                            onUnderlineChanged(isUnderlined);
                            setSheetState(() {});
                            Navigator.pop(context);
                          }, context),
                          formatToggle(Icons.format_strikethrough, isStrikethrough, () {
                            isStrikethrough = !isStrikethrough;
                            onStrikethroughChanged(isStrikethrough);
                            setSheetState(() {});
                            Navigator.pop(context);
                          }, context),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: context.isPhone ? 15 : 25),
                  buildContainer(
                    context,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          formatToggle(Icons.format_color_text, isColorPickerOpen, () {
                            setSheetState(() {
                              isColorPickerOpen = !isColorPickerOpen;
                              isHighlightPickerOpen = false;
                            });
                          }, context),
                          formatToggle(Icons.border_color, isHighlightPickerOpen, () {
                            setSheetState(() {
                              isHighlightPickerOpen = !isHighlightPickerOpen;
                              isColorPickerOpen = false;
                            });
                          }, context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isColorPickerOpen
                      ? Padding(
                          key: const ValueKey('text_color'),
                          padding: const EdgeInsets.only(top: 15),
                          child: buildModernColorPicker(selectedColor, onColorChanged),
                        )
                      : isHighlightPickerOpen
                          ? Padding(
                              key: const ValueKey('highlight_color'),
                              padding: const EdgeInsets.only(top: 15),
                              child: buildModernColorPicker(selectedHighlightColor, onHighlightColorChanged),
                            )
                          : const SizedBox.shrink(key: ValueKey('none')),
                ),
              ),
              SizedBox(width: context.isPhone ? 15 : 25),
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.isPhone ? 10 : 20),
                child: Text(
                  "font_size".tr,
                  style: text14(context).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              buildContainer(
                context,
                SizedBox(
                  height: context.isPhone ? 40 : 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: ['Small', 'Normal', 'Large', 'Huge'].map((size) {
                      bool isSelected = activeSize.toLowerCase() == size.toLowerCase();

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 5 : 10),
                        child: GestureDetector(
                          onTap: () {
                            setSheetState(() => activeSize = size);
                            onFontSizeChanged(size.toLowerCase());
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 16 : 20),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColor().primaryColor : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppColor().primaryColor : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              size.toLowerCase().tr,
                              style: text14(context).copyWith(
                                color: isSelected ? AppColor().white : Colors.grey.shade700,
                              ),
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

Widget buildContainer(BuildContext context, Widget child) {
  return Container(
    padding: EdgeInsets.all(context.isPhone ? 6 : 11),
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );
}

Widget formatToggle(IconData icon, bool isActive, VoidCallback onTap, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 5 : 10),
      child: Container(
        padding: EdgeInsets.all(context.isPhone ? 5 : 10),
        decoration: BoxDecoration(
          color: isActive ? AppColor().primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppColor().primaryColor : Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          color: isActive ? AppColor().primaryColor : AppColor().gray,
          size: context.isPhone ? 25 : 35,
        ),
      ),
    ),
  );
}
