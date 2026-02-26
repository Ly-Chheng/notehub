// import 'package:flutter/material.dart';
// import 'package:project_structure/core/utils/app_color.dart';

// void chooseFolderSheet({
//   required BuildContext context,
//   required Function(String folderName, Color color) onSelected,
// }) {
//   // Temporary state inside the bottom sheet
//   String selectedFolder = "General";
//   Color selectedColor = const Color(0XFF00FB3F);

//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) => StatefulBuilder(
//       builder: (context, setSheetState) {
//         return Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Grab Handle
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(bottom: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),

//               // Header Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Cancel", style: TextStyle(color: Colors.red)),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text("Done", style: TextStyle(color: AppColor().primaryColor)),
//                   ),
//                 ],
//               ),

//               // 1. Folder Selection (Horizontal)
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: ["Work", "Personal", "General", "Ideas", "Travel"].map((folder) {
//                     bool isSelected = selectedFolder == folder;
//                     return GestureDetector(
//                       onTap: () => setSheetState(() => selectedFolder = folder),
//                       child: Container(
//                         margin: const EdgeInsets.only(right: 10),
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: isSelected ? Colors.blue.withOpacity(0.1) : const Color(0xffE9E9EB),
//                           borderRadius: BorderRadius.circular(10),
//                           border: isSelected ? Border.all(color: Colors.blue) : null,
//                         ),
//                         child: Text(folder, style: TextStyle(color: isSelected ? Colors.blue : Colors.black)),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // 2. Color Selection
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xffE9E9EB),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [const Color(0XFF00FB3F), const Color(0XFF9500FF), Colors.red, const Color(0XFF002AFC), Colors.blue, Colors.green, Colors.orange, Colors.black].map((color) {
//                     return GestureDetector(
//                       onTap: () => setSheetState(() => selectedColor = color),
//                       child: CircleAvatar(
//                         backgroundColor: color,
//                         radius: 15,
//                         child: selectedColor == color ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // 3. Confirm Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   onPressed: () {
//                     onSelected(selectedFolder, selectedColor);
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Move Folder", style: TextStyle(color: Colors.white)),
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }

import 'package:flutter/material.dart';

void showChooseFolderSheet({
  required BuildContext context,
  required Function(String folder) onDone,
}) {
  String selectedFolder = "Person";

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red, fontSize: 16, fontFamily: 'EN-REGULAR'),
                      ),
                    ),
                    const Text(
                      "Choose Folder",
                      style: TextStyle(fontSize: 16, fontFamily: 'EN-Bold'),
                    ),
                    GestureDetector(
                      onTap: () {
                        onDone(selectedFolder);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(color: Colors.blue, fontSize: 16,fontFamily: 'EN-REGULAR'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// Folder List
                _folderItem(
                  title: "My notes",
                  isSelected: selectedFolder == "My notes",
                  iconColor: Colors.grey,
                  onTap: () => setState(() => selectedFolder = "My notes"),
                ),

                _folderItem(
                  title: "Person",
                  isSelected: selectedFolder == "Person",
                  iconColor: Colors.blue,
                  onTap: () => setState(() => selectedFolder = "Person"),
                ),

                _folderItem(
                  title: "Work",
                  isSelected: selectedFolder == "Work",
                  iconColor: Colors.blue,
                  onTap: () => setState(() => selectedFolder = "Work"),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _folderItem({
  required String title,
  required bool isSelected,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffE5E5E5))),
      ),
      child: Row(
        children: [
          Icon(Icons.folder, color: iconColor),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
