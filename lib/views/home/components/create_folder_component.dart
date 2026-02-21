import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

void showCreateFolderSheet(BuildContext context) {
  TextEditingController folderController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Required to push sheet up with keyboard
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Moves sheet above keyboard
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
                const Text(
                  "Create Folder",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    if (folderController.text.isNotEmpty) {
                      // setState(() {
                      //   folders.insert(0, {
                      //     "icon": Icons.folder,
                      //     "title": folderController.text,
                      //     "count": "0",
                      //     "color": Colors.blue
                      //   });
                      // });
                      Get.back();
                    }
                  },
                  child:   Text("Done", style: TextStyle(color: AppColor().primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // Input Field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E9EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: folderController,
                autofocus: true, // Automatically opens keyboard
                decoration: const InputDecoration(
                  hintText: "Folder Name",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}