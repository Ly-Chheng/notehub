import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/note/note_controller.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/multi_style.dart';
import 'package:project_structure/core/utils/app_color.dart';

class ShareNote {
  static void showShareOptions({
    required BuildContext context,
    required String title,
    required String content,
    required List<File> selectedImages,
    required NoteController noteController,
  }) {
    final bool hasImages = selectedImages.isNotEmpty;
    final bool hasText = title.trim().isNotEmpty || content.trim().isNotEmpty;

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
                  FolderItemTile(
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
                  FolderItemTile(
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
                  FolderItemTile(
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