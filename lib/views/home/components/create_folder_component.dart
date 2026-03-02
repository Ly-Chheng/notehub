import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/core/utils/app_color.dart';

void showFolderSheet(BuildContext context, {dynamic folderKey, dynamic existingData}) {
  TextEditingController folderController = TextEditingController(
    text: existingData != null ? existingData['title'] : "",
  );
  final Box folderBox = Hive.box('folders_box');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.red))),
                Text(existingData == null ? "Create Folder" : "Update Folder", 
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () async {
                    if (folderController.text.trim().isNotEmpty) {
                      final data = {
                        "title": folderController.text.trim(),
                        "colorValue": existingData != null ? existingData['colorValue'] : Colors.blue.value,
                        "date": DateTime.now().toString(),
                      };

                      if (existingData != null) {
                        // UPDATE: Same as Save Note
                        await folderBox.put(folderKey, data);
                      } else {
                        // CREATE: Same as Save Note
                        await folderBox.add(data);
                      }
                      Get.back();
                    }
                  },
                  child: Text("Done", style: TextStyle(color: AppColor().primaryColor)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: const Color(0xFFE9E9EB), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: folderController,
                autofocus: true,
                decoration: const InputDecoration(hintText: "Folder Name", border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}