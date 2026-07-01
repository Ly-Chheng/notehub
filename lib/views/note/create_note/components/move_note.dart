import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/home/folder_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/widgets/custom_folder_list.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/action_button_bar.dart';

class MoveNote{
  static void showMoveSheet({
    required BuildContext context,
    required int currentNoteId,
    required int currentFolderId,
    required NoteController noteController,
    required FolderController folderController,
  }) {
    ConfirmBottomSheet.show(
      context: context,
      title: "move_to_folder".tr,
      showTopCancel: true,
      content: Flexible(
        child: Obx(() {
          final folders = folderController.folders.where((f) => f.id != currentFolderId).toList();

          if (folders.isEmpty) {
            return CustomNoData(message: "no_data".tr);
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return FolderListTile(
                title: folder.title,
                onTap: () async {
                  await noteController.moveNote(currentNoteId, folder.id!);
                  Get.back();
                  Get.back(result: true);
                },
              );
            },
          );
        }),
      ),
    );
  }
}