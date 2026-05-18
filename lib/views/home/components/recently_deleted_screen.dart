import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/notes/folder_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/sheet_header.dart';

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
        title: "Recently Deleted",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          Obx(() {
            final bool hasNoData = controller.trashNotes.isEmpty;

            return Container(
              height: 24,
              width: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasNoData ? AppColor().gray : AppColor().primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                constraints: const BoxConstraints(),
                iconSize: 18,
                color: hasNoData ? AppColor().gray : AppColor().primaryColor,
                onPressed: hasNoData
                    ? null
                    : () {
                        setState(() {
                          isSelectionMode = !isSelectionMode;
                          selectedNoteIds.clear();
                        });
                      },
                icon: Icon(isSelectionMode ? Icons.close : Icons.more_vert_outlined),
              ),
            );
          }),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Deleted Notes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor().primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${controller.trashNotes.length} items",
                    style: TextStyle(
                      color: AppColor().primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: AppColor().primaryColor));
              }

              if (controller.trashNotes.isEmpty) {
                return const CustomNoData(message: "Trash is empty");
              }

              return SlidableAutoCloseBehavior(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: controller.trashNotes.length,
                  itemBuilder: (context, index) {
                    final note = controller.trashNotes[index];
                    final String titleText = note.title.trim().isNotEmpty ? note.title : controller.getPlainTextFromNote(note.content ?? "").trim();

                    bool isSelected = selectedNoteIds.contains(note.id);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                      child: Slidable(
                        key: ValueKey(note.id),
                        enabled: !isSelectionMode,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.7,
                          children: [
                            SlidableAction(
                              onPressed: (context) => _showMoveRestoreSheet(note.id!),
                              backgroundColor: AppColor().primaryColor,
                              foregroundColor: AppColor().white,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                              icon: Icons.folder,
                              label: 'Move',
                            ),
                            SlidableAction(
                              onPressed: (context) async {
                                await controller.restoreNote(note.id!);
                                Get.snackbar("Restored", "Note moved back to its folder");
                              },
                              backgroundColor: Colors.green,
                              foregroundColor: AppColor().white,
                              icon: Icons.restore_from_trash,
                              label: 'Restore',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                showConfirmDialog(
                                  context: context,
                                  title: "Delete Permanently",
                                  subTitle: "Are you sure you want to permanently delete this note? This action cannot be undone.",
                                  confirmText: "Delete",
                                  onConfirm: () async {
                                    await controller.permanentDeleteNote(note.id!);
                                  },
                                );
                              },
                              backgroundColor: AppColor().red,
                              foregroundColor: AppColor().white,
                              icon: Icons.delete,
                              label: 'Delete',
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
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.04),
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                )
                              ],
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
                                          titleText.isNotEmpty ? titleText : "Untitled Note",
                                          style: text18(context).copyWith(
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                            decoration: TextDecoration.lineThrough,
                                            decorationColor: AppColor().gray,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          "Deleted on: ${note.date}",
                                          style: text14(context).copyWith(color: AppColor().gray),
                                        ),
                                        trailing: note.imagePaths.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.file(
                                                  File(note.imagePaths[0]),
                                                  width: context.isPhone ? 60 : 80,
                                                  height: context.isPhone ? 60 : 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Container(
                                                    width: context.isPhone ? 60 : 80,
                                                    height: context.isPhone ? 60 : 80,
                                                    color: Colors.grey[200],
                                                    child: Icon(Icons.broken_image, size: context.isPhone ? 20 : 26, color: Colors.grey),
                                                  ),
                                                ),
                                              )
                                            : null),
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
      bottomNavigationBar: isSelectionMode ? _buildSelectionBottomBar() : null,
    );
  }

  Widget _buildSelectionBottomBar() {
    return BottomAppBar(
      height: 55,
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // IconButton(
          //   icon: Icon(Icons.restore_from_trash, color: AppColor().primaryColor, size: context.isPhone ? 25 : 30),
          //   onPressed: selectedNoteIds.isEmpty ? null : _handleBulkRestore,
          // ),
          IconButton(
            icon: Icon(Icons.folder, color: AppColor().primaryColor, size: context.isPhone ? 25 : 30),
            onPressed: selectedNoteIds.isEmpty ? null : _handleBulkMoveRestore,
          ),
          Text(
            "${selectedNoteIds.length} selected",
            style: TextStyle(
              fontSize: AppFontSize(context).normalTextSize,
              fontFamily: 'EN-ENGULAR',
              color: AppColor().gray,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: AppColor().red, size: context.isPhone ? 25 : 30),
            onPressed: selectedNoteIds.isEmpty ? null : _handleBulkPermanentDelete,
          ),
        ],
      ),
    );
  }

  void _handleBulkRestore() {
    showConfirmDialog(
      context: context,
      title: "Restore Notes",
      subTitle: "Restore ${selectedNoteIds.length} selected items back to active notes?",
      confirmText: "Restore",
      onConfirm: () async {
        for (var id in selectedNoteIds) {
          await controller.restoreNote(id);
        }
        setState(() {
          isSelectionMode = false;
          selectedNoteIds.clear();
        });
      },
    );
  }

  void _handleBulkPermanentDelete() {
    ConfirmBottomSheet.show(
      context: context,
      title: "Delete Permanently",
      subtitle: "Are you sure you want to delete ${selectedNoteIds.length} selected items forever? This cannot be undone.",
      confirmText: "Purge",
      confirmColor: Colors.red,
      icon: Icons.delete_forever,
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

  // void _handleBulkPermanentDelete() {
  //   showConfirmDialog(
  //     context: context,
  //     title: "Delete Permanently",
  //     subTitle: "Permanently purge ${selectedNoteIds.length} selected items? This cannot be undone.",
  //     confirmText: "Purge",
  //     onConfirm: () async {
  //       for (var id in selectedNoteIds) {
  //         await controller.permanentDeleteNote(id);
  //       }
  //       setState(() {
  //         isSelectionMode = false;
  //         selectedNoteIds.clear();
  //       });
  //     },
  //   );
  // }

  void _showMoveRestoreSheet(int noteId) {
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(title: "Restore Note to Folder"),
            const SizedBox(height: 10),
            Flexible(
              child: Obx(() {
                if (folderController.folders.isEmpty) {
                  return const CustomNoData(message: "No folders available");
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
                        Get.snackbar("Success", "Note restored to ${folder.title}");
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBulkMoveRestore() {
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(title: "Restore to Folder"),
            const SizedBox(height: 10),
            Flexible(
              child: Obx(() {
                if (folderController.folders.isEmpty) {
                  return const CustomNoData(message: "No folders available");
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

                        Get.snackbar("Success", "${idsToMove.length} notes restored to ${folder.title}");
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
