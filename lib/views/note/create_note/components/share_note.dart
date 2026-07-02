import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/widgets/folder_list_title.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';
import 'package:project_structure/core/utils/app_color.dart';

class ShareNote {
  static void showShareOptions({
    required BuildContext context,
    required String title,
    required String content,
    required List<File> selectedImages,
    required NoteController noteController,
    required QuillController quillController,
  }) {
    bool hasActualText() {
      for (final operation in quillController.document.toDelta().toJson()) {
        if (operation.containsKey('insert') && operation['insert'] is String) {
          if (operation['insert'].toString().trim().isNotEmpty) return true;
        }
      }
      return false;
    }

    final bool hasImages = selectedImages.isNotEmpty;
    final bool hasText = title.trim().isNotEmpty || hasActualText();

    ConfirmBottomSheet.show(
      context: context,
      title: "",
      showTopCancel: true,
      content: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              children: [
                if (hasText)
                  FolderListTile(
                    title: "text".tr,
                    icon: Icons.text_fields,
                    iconColor: AppColor().primaryColor,
                    onTap: () {
                      Get.back();
                      noteController.shareNote(
                        title: title,
                        content: content,
                        selectedImages: selectedImages,
                        mode: ShareMode.text,
                      );
                    },
                  ),
                if (hasImages)
                  FolderListTile(
                    title: "photos".tr,
                    icon: Icons.image,
                    iconColor: AppColor().green,
                    onTap: () {
                      Get.back();
                      noteController.shareNote(
                        title: title,
                        content: content,
                        selectedImages: selectedImages,
                        mode: ShareMode.photo,
                      );
                    },
                  ),
                if (hasText)
                  FolderListTile(
                    title: "file_txt".tr,
                    icon: Icons.insert_drive_file,
                    iconColor: AppColor().orange,
                    onTap: () {
                      Get.back();
                      noteController.shareNote(
                        title: title,
                        content: content,
                        selectedImages: selectedImages,
                        mode: ShareMode.file,
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
