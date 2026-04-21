import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/sheet_header.dart';

void showFolderSheet(BuildContext context, {dynamic folderKey, dynamic existingData}) {
  TextEditingController folderController = TextEditingController(
    text: existingData != null ? existingData['title'] : "",
  );
  final Box folderBox = Hive.box('folders_box');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxWidth: double.infinity),
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: SheetHeader(
                title: existingData == null ? "Create Folder" : "Update Folder",
                saveText: "Save",
                onSave: () async {
                  String newName = folderController.text.trim();

                  if (newName.isNotEmpty) {
                    bool isDuplicate = folderBox.values.any((folder) {
                      bool nameExists = folder['title'].toString().toLowerCase() == newName.toLowerCase();

                      if (existingData != null) {
                        return nameExists && folder['date'] != existingData['date'];
                      }
                      return nameExists;
                    });

                    if (isDuplicate) {
                      Get.snackbar(
                        "Duplicate Name",
                        "A folder with this name already exists.",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: AppColor().red,
                        colorText: AppColor().white,
                      );
                      return;
                    }

                    final data = {
                      "title": newName,
                      "date": existingData != null ? existingData['date'] : DateTime.now().toString(),
                    };

                    if (existingData != null) {
                      await folderBox.put(folderKey, data);
                    } else {
                      await folderBox.add(data);
                    }
                    Get.back();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              child: customTextField(
                "Folder Name",
                false,
                null,
                controller: folderController,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
