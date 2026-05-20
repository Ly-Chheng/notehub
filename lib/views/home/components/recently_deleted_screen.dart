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
import 'package:project_structure/widgets/custom_slidableasction.dart';
import 'package:project_structure/widgets/custome_no_data.dart';

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

            return InkWell(
              onTap: hasNoData
                  ? null
                  : () {
                      setState(() {
                        isSelectionMode = !isSelectionMode;
                        selectedNoteIds.clear();
                      });
                    },
              borderRadius: BorderRadius.circular(5),
              child: Container(
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
                child: Center(
                  child: Icon(
                    isSelectionMode ? Icons.close : Icons.more_vert_outlined,
                    size: 18,
                    color: hasNoData ? AppColor().gray : AppColor().primaryColor,
                  ),
                ),
              ),
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
                return const CustomNoData(message: "Trash is empty");
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
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                              label: 'Move',
                              backgroundColor: AppColor().primaryColor,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                            ),
                            AppSlidableAction(
                              onPressed: () async {
                                await controller.restoreNote(note.id!);
                              },
                              icon: Icons.restore_from_trash,
                              label: 'Restore',
                              backgroundColor: AppColor().green,
                            ),
                            AppSlidableAction(
                              onPressed: () {
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
                              icon: Icons.delete,
                              label: 'Delete',
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
                                          displayTitle,
                                          style: text18(context),
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

  // void _handleBulkRestore() {
  //   showConfirmDialog(
  //     context: context,
  //     title: "Restore Notes",
  //     subTitle: "Restore ${selectedNoteIds.length} selected items back to active notes?",
  //     confirmText: "Restore",
  //     onConfirm: () async {
  //       for (var id in selectedNoteIds) {
  //         await controller.restoreNote(id);
  //       }
  //       setState(() {
  //         isSelectionMode = false;
  //         selectedNoteIds.clear();
  //       });
  //     },
  //   );
  // }

  void _handleBulkPermanentDelete() {
    ConfirmBottomSheet.show(
      context: context,
      title: "Delete Permanently",
      subtitle: "Are you sure you want to delete ${selectedNoteIds.length} selected items forever? This cannot be undone.",
      confirmText: "Delete",
      confirmColor: Colors.red,
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
      title: "Restore to Folder",
      showTopCancel: true,
      content: Flexible(
        child: Obx(() {
          if (folderController.folders.isEmpty) {
            return const CustomNoData(
              message: "No data",
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
                  Get.snackbar("Success", "Note restored to ${folder.title}");
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
      title: "Restore to Folder",
      showTopCancel: true,
      content: Flexible(
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
    );
  }
}
