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
                        style: TextStyle(color: Colors.blue, fontSize: 16, fontFamily: 'EN-REGULAR'),
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
