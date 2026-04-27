import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/notes/test_folder_controller.dart';

import 'package:project_structure/models/note/folder_model.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/sheet_header.dart';
import 'package:project_structure/core/utils/app_color.dart';

void showFolderSheet(BuildContext context, {FolderModel? folder}) {
  // Use Get.find to get the existing controller instance
  final FolderController controller = Get.find<FolderController>();

  TextEditingController folderController = TextEditingController(
    text: folder != null ? folder.title : "",
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: SheetHeader(
                title: folder == null ? "Create Folder" : "Update Folder",
                saveText: "Save",
                onSave: () async {
                  String newName = folderController.text.trim();

                  if (newName.isNotEmpty) {
                    // Duplicate Check
                    bool isDuplicate = controller.folders.any((f) => f.title.toLowerCase() == newName.toLowerCase() && f.id != folder?.id);

                    if (isDuplicate) {
                      Get.snackbar(
                        "Duplicate Name",
                        "A folder with this name already exists.",
                        backgroundColor: AppColor().red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    if (folder != null) {
                      // Logic for Update (SQLite)
                      await controller.updateFolder(folder.id!, newName);
                    } else {
                      // Logic for Create (SQLite)
                      await controller.addFolder(newName);
                    }
                    Get.back(); // Close sheet
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
