// import 'package:flutter/material.dart';

// void showFormatSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//     builder: (context) => Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(bottom: 10),
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           Row(children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red)))]),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     children: [
//                       _formatToggle(Icons.format_bold),
//                       _formatToggle(Icons.format_italic),
//                       _formatToggle(Icons.format_underlined),
//                     ],
//                   ),
//                 ),
//                 const VerticalDivider(),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     children: [
//                       _formatToggle(Icons.format_list_bulleted),
//                       _formatToggle(Icons.format_list_numbered),
//                       _formatToggle(Icons.format_align_left),
//                       _formatToggle(Icons.format_align_center),
//                       _formatToggle(Icons.format_align_right),
//                       _formatToggle(Icons.format_align_justify),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           // Color dots
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).cardColor,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [Color(0XFF00FB3F), Color(0XFF9500FF), Colors.red, Color(0XFF002AFC), Colors.blue, Colors.green, Colors.orange, Colors.black]
//                     .map((color) => CircleAvatar(backgroundColor: color, radius: 15))
//                     .toList(),
//               ),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }

// Widget _formatToggle(IconData icon) => IconButton(onPressed: () {}, icon: Icon(icon));
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
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                const VerticalDivider(),
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

// --- BACKGROUND PALETTE SHEET ---
void showPaletteSheet({
  required BuildContext context,
  required Color selectedColor, // Added this to track current selection
  required Function(Color) onColorSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Padding(
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
                Text("Note Background",
                    style: TextStyle(
                      fontSize: context.isPhone ? 16 : 18,
                      fontFamily: 'EN-BOLD',
                    )),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    Colors.white,
                    const Color(0xFFFFF9C4),
                    const Color(0xFFF8BBD0),
                    const Color(0xFFE1F5FE),
                    const Color(0xFFE8F5E9),
                    const Color(0xFFFFE0B2),

                    const Color(0xFFEDE7F6), // Light purple
                    const Color(0xFFD1C4E9), // Lavender
                    const Color(0xFFF3E5F5), // Soft violet
                    const Color(0xFFFFEBEE), // Very light red
                    const Color(0xFFFFF3E0), // Cream orange
                    const Color(0xFFE0F7FA), // Cyan light
                    const Color(0xFFF1F8E9), // Lime light
                    const Color(0xFFFFFDE7), // Very soft yellow
                    const Color(0xFFECEFF1), // Light grey
                    const Color(0xFFD7CCC8), // Light brown
                  ].map((color) {
                    // Check if this specific circle is the active one
                    bool isActive = selectedColor.value == color.value;

                    return GestureDetector(
                      onTap: () {
                        onColorSelected(color);
                        Navigator.pop(context);
                      },
                      // child: CircleAvatar(
                      //   backgroundColor: color,
                      //   radius: 25,
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       border: Border.all(color: Colors.black12),
                      //     ),
                      //     // --- YOUR REQUESTED ICON LOGIC ---
                      //     child: isActive ? const Icon(Icons.check, color: Colors.blue) : null,
                      //   ),
                      // ),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
