// --- BACKGROUND PALETTE SHEET ---
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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