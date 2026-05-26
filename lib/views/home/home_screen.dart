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
import 'package:project_structure/widgets/custom_slidableasction.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FolderController controller = Get.put(FolderController());
  final NoteController noteController = Get.put(NoteController());
  final LockController lockController = Get.put(LockController());
  final TextEditingController folderSearchController = TextEditingController();

  @override
  void dispose() {
    folderSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFolderSearchBar(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: customHeader("Folders", context),
          ),
          Expanded(
            child: Obx(() {
              // Read from the filtered list in your controller instead of raw folders
              final displayedFolders = controller.filteredFolders;

              if (displayedFolders.isEmpty) {
                return Center(
                  child: Text(controller.searchQuery.isEmpty ? "No folders yet" : "No matching folders found"),
                );
              }
              // if (controller.folders.isEmpty) {
              //   return const Center(
              //     child: Text("No folders yet"),
              //   );
              // }
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
                              // CustomSlidableAction(
                              //   onPressed: (c) => _togglePin(folder),
                              //   backgroundColor: AppColor().orange,
                              //   autoClose: true,
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Icon(
                              //         folder.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                              //         color: Colors.white,
                              //         size: 20,
                              //       ),
                              //       const SizedBox(height: 4),
                              //       Text(
                              //         folder.isPinned ? 'Unpin' : 'Pin',
                              //         style: text14(context).copyWith(
                              //           color: Colors.white,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              AppSlidableAction(
                                onPressed: () => _togglePin(folder),
                                icon: folder.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                                label: folder.isPinned ? 'Unpin' : 'Pin',
                                iconSize: 20,
                                backgroundColor: AppColor().orange,
                              ),
                              AppSlidableAction(
                                onPressed: () => _toggleLock(folder),
                                icon: folder.isLocked ? Icons.lock_open : Icons.lock,
                                label: folder.isLocked ? 'Unlock' : 'Lock',
                                iconSize: 20,
                                backgroundColor: AppColor().green,
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              AppSlidableAction(
                                onPressed: () => _handleEditFolder(context, folder),
                                icon: Icons.edit,
                                label: 'Edit',
                                iconSize: 20,
                                backgroundColor: AppColor().primaryColor,
                              ),
                              AppSlidableAction(
                                onPressed: () => _confirmDelete(context, folder),
                                icon: Icons.delete,
                                label: 'Delete',
                                iconSize: 20,
                                backgroundColor: AppColor().red,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(16),
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
      subTitle: "Are you sure you want to delete ${folder.title}? All notes inside will be moved directly to Recently Deleted.",
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
            buildFolderIcon(folder, isDefault),
            const SizedBox(width: 12),
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

  Widget _buildFolderSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 12),
      child: customTextField(
        "Search",
        false,
        null,
        controller: folderSearchController,
        onChanged: (v) => controller.searchFolders(v),
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
