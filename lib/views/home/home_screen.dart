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
import 'package:project_structure/widgets/custom_slidableasction.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/multi_style.dart';

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
            child: customHeader("folders".tr, context),
          ),
          Expanded(
            child: Obx(() {
              final displayedFolders = controller.filteredFolders;

              if (displayedFolders.isEmpty) {
                return Center(
                  child: Text(
                    controller.searchQuery.isEmpty ? "no_folders_yet".tr : "no_matching_folders".tr,
                    style: TextStyle(
                      fontSize: AppFontSize(context).normalTextSize,
                      fontFamily: Get.locale?.languageCode == 'km' ? 'KH-REGULAR' : 'EN-REGULAR',
                      color: AppColor().gray,
                    ),
                  ),
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
                              AppSlidableAction(
                                onPressed: () => _togglePin(folder),
                                icon: folder.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                                label: folder.isPinned ? 'unpin'.tr : 'pin'.tr,
                                iconSize: 20,
                                backgroundColor: AppColor().orange,
                              ),
                              AppSlidableAction(
                                onPressed: () => _toggleLock(folder),
                                icon: folder.isLocked ? Icons.lock_open : Icons.lock,
                                label: folder.isLocked ? 'unlock'.tr : 'lock'.tr,
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
                                label: 'edit'.tr,
                                iconSize: 20,
                                backgroundColor: AppColor().primaryColor,
                              ),
                              AppSlidableAction(
                                onPressed: () => _confirmDelete(context, folder),
                                icon: Icons.delete,
                                label: 'delete'.tr,
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
        title: "unlock_folder".tr,
        subTitle: "enter_password_unlock_folder".tr,
        confirmText: "unlock".tr,
        controller: verifyPassController,
        obscureText: true,
        hintText: "password".tr,
        onConfirm: () async {
          if (verifyPassController.text == storedPass) {
            await controller.toggleLock(folder.id!);
            Get.back();
          } else {
            AppSnackbar.showError(
              title: "verification_failed".tr,
              message: "incorrect_password".tr,
            );
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
      title: "verify_password".tr,
      subTitle: "enter_password_edit_folder".tr,
      confirmText: "verify".tr,
      controller: verifyPassController,
      obscureText: true,
      hintText: "password".tr,
      onConfirm: () {
        if (verifyPassController.text == storedPass) {
          Get.back();
          showFolderSheet(context, folder: folder);
        } else {
          AppSnackbar.showError(
            title: "verification_failed".tr,
            message: "incorrect_password".tr,
          );
        }
      },
    );
  }

  void _confirmDelete(BuildContext context, FolderModel folder) async {
    bool folderLocked = folder.isLocked;

    bool containsLockedNotes = await noteController.hasLockedNotesInFolder(folder.id!);

    if (folderLocked || containsLockedNotes) {
      final settings = await lockController.getSecuritySettings();
      String storedPass = settings?['master_password'] ?? "";
      final TextEditingController verifyPassController = TextEditingController();

      if (!context.mounted) return;

      showConfirmDialog(
        context: context,
        title: "locked_folder".tr,
        subTitle: containsLockedNotes ? "locked_folder_with_notes".tr : "locked_folder_no_notes".tr,
        confirmText: "unlock".tr,
        controller: verifyPassController,
        obscureText: true,
        hintText: "password".tr,
        onConfirm: () {
          if (verifyPassController.text == storedPass) {
            Get.back();
            _proceedWithDeletion(folder);
          } else {
            AppSnackbar.showError(
              title: "verification_failed".tr,
              message: "incorrect_password".tr,
            );
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
      title: "delete_folder".tr,
      subTitle: "delete_folder_confirm_subtitle".tr,
      confirmText: "delete".tr,
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
      onTap: () async {
        final settings = await lockController.getSecuritySettings();
        String storedPass = settings?['master_password'] ?? "";

        bool needsVerification = folder.isLocked && storedPass.isNotEmpty;

        if (needsVerification) {
          final TextEditingController verifyPassController = TextEditingController();

          if (!context.mounted) return;

          showConfirmDialog(
            context: Get.context!,
            title: "locked_folder".tr,
            subTitle: "enter_password_unlock_folder".tr,
            confirmText: "unlock".tr,
            controller: verifyPassController,
            obscureText: true,
            hintText: "password".tr,
            onConfirm: () {
              if (verifyPassController.text == storedPass) {
                Get.back();
                Get.to(() => FolderNoteListScreen(
                      folderId: folder.id!,
                      folderName: folder.title,
                    ));
                controller.folders.refresh();
              } else {
                AppSnackbar.showError(
                  title: "verification_failed".tr,
                  message: "incorrect_password".tr,
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
            color: AppColor().white,
          ),
      ],
    );
  }

  Widget _buildFolderSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 12),
      child: customTextField(
        "search".tr,
        false,
        null,
        controller: folderSearchController,
        onChanged: (v) => controller.searchFolders(v),
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
