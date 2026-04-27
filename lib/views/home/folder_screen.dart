import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/notes/test_folder_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/models/note/folder_model.dart';
import 'package:project_structure/views/create/test_folder_note_list_screen.dart';
import 'package:project_structure/views/home/components/show_folder_sheet.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/custom_header.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialize the controller
  final FolderController controller = Get.put(FolderController());

  @override
  void initState() {
    super.initState();
    // Fetch folders from SQLite on startup
    controller.loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: customHeader("Folders", context),
          ),
          Expanded(
            child: Obx(() {
              // 1. Empty State
              if (controller.folders.isEmpty) {
                return const Center(
                  child: Text("No folders yet. Tap + to create one."),
                );
              }

              // 2. Main List View
              return ListView.builder(
                itemCount: controller.folders.length,
                padding: const EdgeInsets.only(bottom: 100),
                itemBuilder: (context, index) {
                  final folder = controller.folders[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Slidable(
                        key: ValueKey(folder.id),
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
                        child: folderTile(folder),
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
        onPressed: () => showFolderSheet(context),  
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Helper method for deletion
  void _confirmDelete(BuildContext context, FolderModel folder) {
    showConfirmDialog(
      context: context,
      title: "Delete Folder?",
      subTitle: "All notes inside '${folder.title}' will be permanently lost.",
      confirmText: "Delete",
      onConfirm: () async {
        await controller.deleteFolder(folder.id!);
      },
    );
  }

  // The Folder Row Component
  Widget folderTile(FolderModel folder) {
    return GestureDetector(
      onTap: () {
        // Navigate to Note List using SQLite ID
        Get.to(() => FolderNoteListScreen(
              folderId: folder.id!,
              folderName: folder.title,
            ));
      },
      child: Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.folder, color: AppColor().primaryColor, size: 32),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                folder.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
