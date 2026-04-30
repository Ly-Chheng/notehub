import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/notes/folder_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/note/folder_model.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/views/create/folder_note_list_screen.dart';
import 'package:project_structure/views/home/components/create_folder_component.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/custom_header.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FolderController controller = Get.put(FolderController());
  final NoteController noteController = Get.put(NoteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: customHeader("Folders", context),
          ),
          Expanded(
            child: Obx(() {
              if (controller.folders.isEmpty) {
                return const Center(
                  child: Text("No folders yet"),
                );
              }
              return ListView.builder(
                itemCount: controller.folders.length,
                padding: const EdgeInsets.only(bottom: 100),
                itemBuilder: (context, index) {
                  final folder = controller.folders[index];
                  final isDefault = controller.isDefaultFolder(folder);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Slidable(
                        enabled: !isDefault,
                        key: ValueKey(folder.id),
                        startActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (c) => _togglePin(folder),
                              backgroundColor: AppColor().orange,
                              foregroundColor: AppColor().white,
                              icon: folder.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                              label: folder.isPinned ? 'Unpin' : 'Pin',
                            ),
                            SlidableAction(
                              onPressed: (c) => _toggleLock(folder),
                              backgroundColor: AppColor().green,
                              icon: folder.isLocked ? Icons.lock : Icons.lock_open,
                              label: folder.isLocked ? 'Unlock' : 'Lock',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (c) => showFolderSheet(context, folder: folder),
                              backgroundColor: AppColor().primaryColor,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (c) => _confirmDelete(context, folder),
                              backgroundColor: AppColor().red,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: folderTile(folder, isDefault),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor().primaryColor,
        onPressed: () {
          final int targetFolderId = controller.defaultFolderId;

          Get.to(() => CreateNoteScreen(
                isEditing: false,
                folderId: targetFolderId,
              ));
        },
        child: Icon(
          Icons.add,
          color: AppColor().white,
        ),
      ),
    );
  }

  void _togglePin(FolderModel folder) async {
    await controller.togglePin(folder.id!);
  }

  void _toggleLock(FolderModel folder) async {
    await controller.toggleLock(folder.id!);
  }

  void _confirmDelete(BuildContext context, FolderModel folder) {
    showConfirmDialog(
      context: context,
      title: "Delete Folder?",
      subTitle: "This folder contains ${folder.title} notes. All data inside will be permanently lost.",
      confirmText: "Delete",
      onConfirm: () async {
        await controller.deleteFolder(folder.id!);
      },
    );
  }

  Widget folderTile(FolderModel folder, bool isDefault) {
    return GestureDetector(
      onTap: () {
        Get.to(() => FolderNoteListScreen(
              folderId: folder.id!,
              folderName: folder.title,
            ));
        controller.folders.refresh();
      },
      child: Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(Icons.folder, color: AppColor().primaryColor, size: 35),
            const SizedBox(width: 12),
            if (folder.isLocked)
              Padding(
                padding: EdgeInsets.only(
                  right: context.isPhone ? 2 : 5,
                ),
                child: Icon(Icons.lock, size: 18, color: AppColor().primaryColor),
              ),
            Expanded(
              child: Text(
                folder.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'EN-SEMIBOLD',
                  fontFamilyFallback: const ['KH-BOLD'],
                  fontSize: context.isPhone ? 16 : 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (folder.isPinned)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.push_pin, size: 18, color: AppColor().orange),
              ),
            FutureBuilder<int>(
              future: noteController.getCountForFolder(folder.id!),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Text(
                  "$count",
                  style: text16(context).copyWith(color: AppColor().gray),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
