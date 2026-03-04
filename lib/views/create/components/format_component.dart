import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: context.isPhone ? 16 : 18,
                          fontFamily: 'EN-REGULAR',
                        ))),
                Text("Format Text",
                    style: TextStyle(
                      fontSize: context.isPhone ? 16 : 18,
                      fontFamily: 'EN-BOLD',
                    )),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _formatToggle(Icons.format_bold, isBold, () {
                              isBold = !isBold;
                              onBoldChanged(isBold);
                              setSheetState(() {});
                            }),
                            const SizedBox(width: 20),
                            _formatToggle(Icons.format_italic, isItalic, () {
                              isItalic = !isItalic;
                              onItalicChanged(isItalic);
                              setSheetState(() {});
                            }),
                            const SizedBox(width: 20),
                            _formatToggle(Icons.format_underlined, isUnderlined, () {
                              isUnderlined = !isUnderlined;
                              onUnderlineChanged(isUnderlined);
                              setSheetState(() {});
                            }),
                            const SizedBox(width: 20),
                            _formatToggle(Icons.format_strikethrough, isStrikethrough, () {
                              isStrikethrough = !isStrikethrough;
                              onStrikethroughChanged(isStrikethrough);
                              setSheetState(() {});
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      children: [
                        _formatToggle(Icons.format_list_bulleted, false, () {
                          onBulletPressed();
                          Navigator.pop(context); // Close sheet after inserting
                        }),
                        const SizedBox(width: 20),
                        _formatToggle(Icons.format_list_numbered, false, () {
                          onNumberedPressed();
                          Navigator.pop(context); // Close sheet after action
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [0XFF00FB3F, 0XFF9500FF, 0XFFFF0000, 0XFF002AFC, 0XFF2196F3, 0XFF4CAF50, 0XFFFF9800, 0XFF000000].map((colorValue) {
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
                          radius: 20,
                          child: selectedColor == color ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }),
  );
}

Widget _formatToggle(IconData icon, bool isActive, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? Colors.blue : Colors.grey.shade300),
      ),
      child: Icon(icon, color: isActive ? Colors.blue : Colors.black54),
    ),
  );
}
