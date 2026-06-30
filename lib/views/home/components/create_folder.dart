import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/home/folder_controller.dart';
import 'package:project_structure/models/home/folder_model.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_sheet_header.dart';

void createFolder(BuildContext context, {FolderModel? folder}) {
  final FolderController controller = Get.find<FolderController>();

  TextEditingController folderController = TextEditingController(
    text: folder != null ? folder.title : "",
  );
  void showDuplicateNameDialog(BuildContext context) {
    Get.back();
    showConfirmDialog(
      context: context,
      title: "Duplicate Name",
      subTitle: "A folder with this name already exists.",
      confirmText: "OK",
      onConfirm: () {
        Navigator.pop(context);
      },
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxWidth: double.infinity),
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
                title: folder == null ? "create_folder".tr : "update_folder".tr,
                saveText: "save".tr,
                onSave: () async {
                  String newName = folderController.text.trim();

                  if (newName.isNotEmpty) {
                    bool isDuplicate = controller.folders.any((f) => f.title.toLowerCase() == newName.toLowerCase() && f.id != folder?.id);

                    if (isDuplicate) {
                      showDuplicateNameDialog(context);
                      return;
                    }

                    if (folder != null) {
                      await controller.updateFolder(folder.id!, newName);
                    } else {
                      await controller.addFolder(newName);
                    }
                    Get.back();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              child: customTextField(
                "folder_name".tr,
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
