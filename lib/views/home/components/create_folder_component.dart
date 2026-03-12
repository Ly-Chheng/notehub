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
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            color: Theme.of(context).cardColor,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.red, fontFamily: 'EN-ENGINEER', fontSize: 16))),
                Text(existingData == null ? "Create Folder" : "Update Folder", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'EN-ENGINEER')),
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
                  child: Text("Done",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor().primaryColor,
                        fontFamily: 'EN-ENGINEER',
                      )),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: folderController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Folder Name",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontFamily: 'EN-ENGINEER', fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
