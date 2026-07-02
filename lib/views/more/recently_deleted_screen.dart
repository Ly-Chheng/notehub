import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/home/folder_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/functions/fomat_date.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/selection_bottom_bar.dart';
import 'package:project_structure/widgets/selection_mode_toggle.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
import 'package:project_structure/widgets/app_slidable_asction.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/folder_list_title.dart';
import 'package:project_structure/widgets/rounded_file_image.dart';

class RecentlyDeletedScreen extends StatefulWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  State<RecentlyDeletedScreen> createState() => _RecentlyDeletedScreenState();
}

class _RecentlyDeletedScreenState extends State<RecentlyDeletedScreen> {
  final NoteController controller = Get.find<NoteController>();
  final FolderController folderController = Get.find<FolderController>();

  bool isSelectionMode = false;
  Set<int> selectedNoteIds = {};

  @override
  void initState() {
    super.initState();
    controller.fetchTrashNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "recently_deleted".tr,
        context: context,
        actions: [
          Obx(() {
            final bool hasNoData = controller.trashNotes.isEmpty;
            return SelectionModeToggle(
              hasNoData: hasNoData,
              isSelectionMode: isSelectionMode,
              onToggle: () {
                setState(() {
                  isSelectionMode = !isSelectionMode;
                  selectedNoteIds.clear();
                });
              },
            );
          }),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: AppColor().primaryColor));
              }

              if (controller.trashNotes.isEmpty) {
                return CustomNoData(message: "no_data".tr);
              }

              return SlidableAutoCloseBehavior(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: controller.trashNotes.length,
                  itemBuilder: (context, index) {
                    final note = controller.trashNotes[index];
                    final String plainContent = controller.getPlainTextFromNote(note.content).trim();
                    final String displayTitle = (note.title.trim().isNotEmpty) ? note.title : (plainContent.isNotEmpty ? plainContent : "Untitled");

                    bool isSelected = selectedNoteIds.contains(note.id);

                    return Padding(
                      padding: Layout.padding(),
                      child: Slidable(
                        key: ValueKey(note.id),
                        enabled: !isSelectionMode,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.7,
                          children: [
                            AppSlidableAction(
                              onPressed: () {
                                _showMoveRestoreSheet(note.id!);
                              },
                              icon: Icons.folder,
                              label: 'move'.tr,
                              backgroundColor: AppColor().primaryColor,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                            ),
                            AppSlidableAction(
                              onPressed: () async {
                                await controller.restoreNote(note.id!);
                              },
                              icon: Icons.restore_from_trash,
                              label: 'restore'.tr,
                              backgroundColor: AppColor().green,
                            ),
                            AppSlidableAction(
                              onPressed: () {
                                showConfirmDialog(
                                  context: context,
                                  title: "delete_permanently".tr,
                                  subTitle: "perm_delete_confirm".tr,
                                  confirmText: "delete".tr,
                                  onConfirm: () async {
                                    await controller.permanentDeleteNote(note.id!);
                                  },
                                );
                              },
                              icon: Icons.delete,
                              label: 'delete'.tr,
                              backgroundColor: AppColor().red,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (isSelectionMode) {
                              setState(() {
                                if (isSelected) {
                                  selectedNoteIds.remove(note.id!);
                                } else {
                                  selectedNoteIds.add(note.id!);
                                }
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: isSelected ? Border.all(color: AppColor().primaryColor, width: 1.5) : null,
                              boxShadow: AppDecorations.subtleShadow,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                children: [
                                  if (isSelectionMode) ...[
                                    const SizedBox(width: 12),
                                    Icon(
                                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: AppColor().primaryColor,
                                      size: 24,
                                    ),
                                  ],
                                  Expanded(
                                    child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        title: Text(
                                          displayTitle,
                                          style: fix18(context).copyWith(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          '${'deleted_on'.tr} ${formatDateForLocale(note.date)}',
                                          style: text14(context).copyWith(color: AppColor().gray),
                                        ),
                                        trailing: note.imagePaths.isNotEmpty ? RoundedFileImage(path: note.imagePaths[0]) : null),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
      bottomNavigationBar: isSelectionMode
          ? SelectionBottomBar(
              selectedCount: selectedNoteIds.length,
              onMove: _handleBulkMoveRestore,
              onDelete: _handleBulkPermanentDelete,
            )
          : null,
    );
  }

  void _handleBulkPermanentDelete() {
    ConfirmBottomSheet.show(
      context: context,
      title: "delete_permanently".tr,
      subtitle: 'delete_bulk_confirm_subtitle'.tr,
      confirmText: "delete".tr,
      confirmColor: AppColor().red,
      itemCount: selectedNoteIds.length,
      onConfirm: () async {
        for (var id in selectedNoteIds) {
          await controller.permanentDeleteNote(id);
        }

        setState(() {
          isSelectionMode = false;
          selectedNoteIds.clear();
        });
      },
    );
  }

  void _showMoveRestoreSheet(int noteId) {
    ConfirmBottomSheet.show(
      context: context,
      title: "restore_to_folder".tr,
      showTopCancel: true,
      content: Flexible(
        child: Obx(() {
          if (folderController.folders.isEmpty) {
            return CustomNoData(
              message: "no_data".tr,
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: folderController.folders.length,
            itemBuilder: (context, index) {
              final folder = folderController.folders[index];
              return ListTile(
                leading: Icon(Icons.folder, color: AppColor().primaryColor),
                title: Text(folder.title, style: text16(context)),
                onTap: () async {
                  await controller.bulkMoveNotes([noteId], folder.id!);

                  await controller.restoreNote(noteId);

                  if (!mounted) return;
                  Get.back();
                  Get.snackbar("success".tr, "Note restored to ${folder.title}");
                },
              );
            },
          );
        }),
      ),
    );
  }

  void _handleBulkMoveRestore() {
    ConfirmBottomSheet.show(
      context: context,
      title: "restore_to_folder".tr,
      showTopCancel: true,
      content: Flexible(
        child: Obx(() {
          if (folderController.folders.isEmpty) {
            return CustomNoData(message: "no_data".tr);
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: folderController.folders.length,
            itemBuilder: (context, index) {
              final folder = folderController.folders[index];
              return FolderListTile(
                title: folder.title,
                onTap: () async {
                  final List<int> idsToMove = selectedNoteIds.toList();
                  await controller.bulkMoveNotes(idsToMove, folder.id!);

                  for (var id in idsToMove) {
                    await controller.restoreNote(id);
                  }

                  if (!mounted) return;
                  Get.back();
                  setState(() {
                    isSelectionMode = false;
                    selectedNoteIds.clear();
                  });
                },
              );
            },
          );
        }),
      ),
    );
  }
}
