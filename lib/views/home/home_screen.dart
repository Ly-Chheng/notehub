import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
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
  final LockController lockController = Get.put(LockController());

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
              return SlidableAutoCloseBehavior(
                child: ListView.builder(
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
                              CustomSlidableAction(
                                onPressed: (c) => _togglePin(folder),
                                backgroundColor: AppColor().orange,
                                autoClose: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      folder.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      folder.isPinned ? 'Unpin' : 'Pin',
                                      style: text14(context).copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CustomSlidableAction(
                                onPressed: (c) => _toggleLock(folder),
                                backgroundColor: AppColor().green,
                                autoClose: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      folder.isLocked ? Icons.lock_open : Icons.lock,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      folder.isLocked ? 'Unlock' : 'Lock',
                                      style: text14(context).copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              CustomSlidableAction(
                                onPressed: (c) => _handleEditFolder(context, folder),
                                backgroundColor: AppColor().primaryColor,
                                autoClose: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.edit, color: Colors.white),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Edit',
                                      style: text14(context).copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CustomSlidableAction(
                                onPressed: (c) => _confirmDelete(context, folder),
                                backgroundColor: AppColor().red,
                                autoClose: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.delete, color: Colors.white),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Delete',
                                      style: text14(context).copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          child: folderTile(folder, isDefault),
                        ),
                      ),
                    );
                  },
                ),
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
    final settings = await lockController.getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (storedPass.isEmpty) {
      Get.toNamed('/createPassword');
      return;
    }

    if (folder.isLocked) {
      final TextEditingController verifyPassController = TextEditingController();

      if (!mounted) return;

      showConfirmDialog(
        context: context,
        title: "Unlock Folder",
        subTitle: "Enter your password to unlock ${folder.title}.",
        confirmText: "Unlock",
        controller: verifyPassController,
        obscureText: true,
        hintText: "Password",
        onConfirm: () async {
          if (verifyPassController.text == storedPass) {
            await controller.toggleLock(folder.id!);
            Get.back();
          } else {
            Get.snackbar("Verification Failed", "Incorrect Password", backgroundColor: AppColor().red, colorText: Colors.white);
          }
        },
      );
    } else {
      await controller.toggleLock(folder.id!);
    }
  }

  void _handleEditFolder(BuildContext context, FolderModel folder) async {
    if (!folder.isLocked) {
      showFolderSheet(context, folder: folder);
      return;
    }
    final settings = await lockController.getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";
    final TextEditingController verifyPassController = TextEditingController();

    if (!mounted) return;

    showConfirmDialog(
      context: Get.context!,
      title: "Verify Password",
      subTitle: "Enter your password to edit ${folder.title}.",
      confirmText: "Verify",
      controller: verifyPassController,
      obscureText: true,
      hintText: "Password",
      onConfirm: () {
        if (verifyPassController.text == storedPass) {
          Get.back();
          showFolderSheet(context, folder: folder);
        } else {
          Get.snackbar("Verification Failed", "Incorrect Password", backgroundColor: AppColor().red, colorText: AppColor().white);
        }
      },
    );
  }

  void _confirmDelete(BuildContext context, FolderModel folder) async {
    // Check if folder itself is locked
    bool folderLocked = folder.isLocked;

    // Check if there are any locked notes inside
    bool containsLockedNotes = await noteController.hasLockedNotesInFolder(folder.id!);

    if (folderLocked || containsLockedNotes) {
      final settings = await lockController.getSecuritySettings();
      String storedPass = settings?['master_password'] ?? "";
      final TextEditingController verifyPassController = TextEditingController();

      if (!context.mounted) return;

      showConfirmDialog(
        context: context,
        title: "Locked Folder",
        subTitle: containsLockedNotes ? "This folder contains locked notes. Enter password to delete everything." : "This folder is locked. Enter password to delete.",
        confirmText: "Unlock",
        controller: verifyPassController,
        obscureText: true,
        hintText: "Password",
        onConfirm: () {
          if (verifyPassController.text == storedPass) {
            Get.back();
            _proceedWithDeletion(folder);
          } else {
            Get.snackbar("Verification Failed", "Incorrect Password", backgroundColor: AppColor().red, colorText: AppColor().white);
          }
        },
      );
    } else {
      _proceedWithDeletion(folder);
    }
  }

  void _proceedWithDeletion(FolderModel folder) {
    showConfirmDialog(
      context: context,
      title: "Delete Folder",
      subTitle: "Are you sure you want to delete '${folder.title}'? All notes inside will be moved directly to Recently Deleted.",
      confirmText: "Delete",
      onConfirm: () async {
        await noteController.bulkMoveToTrashByFolder(folder.id!, controller.defaultFolderId);
        await controller.deleteFolder(folder.id!);
        await noteController.fetchTrashNotes();

        Get.back();
      },
    );
  }

  Widget folderTile(FolderModel folder, bool isDefault) {
    return GestureDetector(
      // onTap: () {
      //   Get.to(() => FolderNoteListScreen(
      //         folderId: folder.id!,
      //         folderName: folder.title,
      //       ));
      //   controller.folders.refresh();
      // },

      onTap: () async {
        final settings = await lockController.getSecuritySettings();
        String storedPass = settings?['master_password'] ?? "";

        bool needsVerification = folder.isLocked && storedPass.isNotEmpty;

        if (needsVerification) {
          final TextEditingController verifyPassController = TextEditingController();

          if (!context.mounted) return;

          showConfirmDialog(
            context: Get.context!,
            title: "Locked Folder",
            subTitle: "Please enter your password to access ${folder.title}.",
            confirmText: "Unlock",
            controller: verifyPassController,
            obscureText: true,
            hintText: "Passwor",
            onConfirm: () {
              if (verifyPassController.text == storedPass) {
                Get.back();
                Get.to(() => FolderNoteListScreen(
                      folderId: folder.id!,
                      folderName: folder.title,
                    ));
                controller.folders.refresh();
              } else {
                Get.snackbar(
                  "Verification Failed",
                  "Incorrect Password",
                  backgroundColor: AppColor().red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
          );
        } else {
          Get.to(() => FolderNoteListScreen(
                folderId: folder.id!,
                folderName: folder.title,
              ));
          controller.folders.refresh();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon(Icons.folder, color: AppColor().primaryColor, size: 35),
            buildFolderIcon(folder, isDefault),
            const SizedBox(width: 12),
            // if (folder.isLocked == true)
            //   Padding(
            //     padding: EdgeInsets.only(
            //       right: context.isPhone ? 2 : 5,
            //     ),
            //     child: Icon(Icons.lock, size: 18, color: AppColor().primaryColor),
            //   ),
            Expanded(
              child: Text(folder.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: text16(context).copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            if (folder.isPinned)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.push_pin, size: 18, color: AppColor().orange),
              ),

            Obx(() {
              noteController.notes.length;

              return FutureBuilder<int>(
                future: noteController.getCountForFolder(folder.id!),
                builder: (context, snapshot) {
                  return Text(
                    "${snapshot.data ?? 0}",
                    style: text16(context).copyWith(color: AppColor().gray),
                  );
                },
              );
            })
          ],
        ),
      ),
    );
  }

  Widget buildFolderIcon(FolderModel folder, bool isDefault) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.folder,
          color: isDefault ? AppColor().primaryColor : AppColor().primaryColor,
          size: 35,
        ),
        if (!isDefault && folder.isLocked)
          Icon(
            Icons.lock,
            size: 16,
            color: Colors.white,
          ),
      ],
    );
  }
}
