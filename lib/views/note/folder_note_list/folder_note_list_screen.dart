import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/controllers/home/folder_controller.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/note/note_model.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/note/create_note/create_note_screen.dart';
import 'package:project_structure/views/note/folder_note_list/components/note_card.dart';
import 'package:project_structure/views/note/folder_note_list/components/note_search.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/selection_bottom_bar.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
import 'package:project_structure/widgets/custom_fab.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/custom_folder_list.dart';
import 'package:project_structure/widgets/selection_mode_toggle.dart';

class FolderNoteListScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  const FolderNoteListScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<FolderNoteListScreen> createState() => _FolderNoteListScreenState();
}

class _FolderNoteListScreenState extends State<FolderNoteListScreen> {
  final NoteController controller = Get.find<NoteController>();
  final FolderController folderController = Get.find<FolderController>();
  final TextEditingController searchController = TextEditingController();
  final LockController lockController = Get.put(LockController());

  bool isSelectionMode = false;
  Set<int> selectedNoteIds = {};

  @override
  void initState() {
    super.initState();
    controller.fetchNotesByFolder(widget.folderId);
  }

  void _handleNoteTap(NoteModel note) async {
    if (isSelectionMode) {
      setState(() {
        if (selectedNoteIds.contains(note.id)) {
          selectedNoteIds.remove(note.id!);
        } else {
          selectedNoteIds.add(note.id!);
        }
      });
    } else {
      if (note.isLocked == true) {
        _showUnlockDialog(note);
      } else {
        _navigateToCreateNote(note);
      }
    }
  }

  void _showUnlockDialog(NoteModel note) async {
    final TextEditingController verifyPassController = TextEditingController();

    final settings = await lockController.getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (!mounted) return;

    showConfirmDialog(
      context: context,
      title: "locked_note".tr,
      subTitle: "view_note_locked_desc".tr,
      confirmText: "unlock".tr,
      controller: verifyPassController,
      obscureText: true,
      hintText: "password".tr,
      onConfirm: () {
        if (verifyPassController.text == storedPass) {
          _navigateToCreateNote(note);
        } else {
          AppSnackbar.showError(
            title: "error".tr,
            message: "incorrect_password".tr,
          );
        }
      },
    );
  }

  void _showUnlockBeforeDelete(NoteModel note) async {
    final TextEditingController verifyPassController = TextEditingController();
    final settings = await lockController.getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (!mounted) return;

    showConfirmDialog(
      context: context,
      title: "locked_note",
      subTitle: "delete_locked_note_desc".tr,
      confirmText: "unlock".tr,
      controller: verifyPassController,
      obscureText: true,
      hintText: "password".tr,
      onConfirm: () async {
        if (verifyPassController.text == storedPass) {
          await controller.moveToTrash(note.id!, widget.folderId);
        } else {
          AppSnackbar.showError(
            title: "access_denied".tr,
            message: "incorrect_password".tr,
          );
        }
      },
    );
  }

  void _navigateToCreateNote(NoteModel note) async {
    final result = await Get.to(() => CreateNoteScreen(
          isEditing: true,
          existingNote: note,
          folderId: widget.folderId,
        ));

    if (result == true) {
      controller.fetchNotesByFolder(widget.folderId);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: folderController.isDefaultName(widget.folderName) ? folderController.displayDefaultFolderName : widget.folderName,
        titleColor: AppColor().primaryColor,
        context: context,
        actions: [
          Obx(() {
            final bool hasNoData = controller.notes.isEmpty;

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
          NoteSearch(
            controller: searchController,
            onChanged: (value) {
              controller.searchNotes(value, widget.folderId);
            },
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColor().primaryColor,
                  ),
                );
              }

              if (controller.notes.isEmpty) {
                return CustomNoData(message: "no_data".tr);
              }

              final sortedNotes = [...controller.notes]..sort((a, b) => b.date.compareTo(a.date));

              final pinnedNotes = sortedNotes.where((n) => n.isPinned).toList();
              final otherNotes = sortedNotes.where((n) => !n.isPinned).toList();

              final Map<String, List<NoteModel>> groupedNotes = {};

              for (var note in otherNotes) {
                String dateKey = controller.getDateHeader(note.date.toString());

                groupedNotes.putIfAbsent(dateKey, () => []);
                groupedNotes[dateKey]!.add(note);
              }

              return SlidableAutoCloseBehavior(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    if (pinnedNotes.isNotEmpty) ...[
                      _buildSectionHeader("pinned_header".tr),
                      ...pinnedNotes.map(
                        (note) => NoteCard(
                          note: note,
                          controller: controller,
                          folderId: widget.folderId,
                          isSelectionMode: isSelectionMode,
                          isSelected: selectedNoteIds.contains(note.id),
                          onTap: () => _handleNoteTap(note),
                          onMove: () {
                            if (note.isLocked) {
                              _verifyAndMove([note.id!]);
                            } else {
                              _showMoveSheet([note.id!]);
                            }
                          },
                          onDelete: () {
                            note.isLocked ? _showUnlockBeforeDelete(note) : _showDeleteConfirmation(note);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ...groupedNotes.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(entry.key),
                          ...entry.value.map(
                            (note) => NoteCard(
                              note: note,
                              controller: controller,
                              folderId: widget.folderId,
                              isSelectionMode: isSelectionMode,
                              isSelected: selectedNoteIds.contains(note.id),
                              onTap: () => _handleNoteTap(note),
                              onMove: () {
                                if (note.isLocked) {
                                  _verifyAndMove([note.id!]);
                                } else {
                                  _showMoveSheet([note.id!]);
                                }
                              },
                              onDelete: () {
                                note.isLocked ? _showUnlockBeforeDelete(note) : _showDeleteConfirmation(note);
                              },
                            ),
                          ),
                        ],
                      );
                      // }).toList(),
                    }),
                  ],
                ),
              );
            }),
          )
        ],
      ),
      floatingActionButton: isSelectionMode
          ? null
          : CustomFab(
              onPressed: () async {
                final result = await Get.to(() => CreateNoteScreen(folderId: widget.folderId));
                if (result == true) controller.fetchNotesByFolder(widget.folderId);
              },
            ),
      bottomNavigationBar: isSelectionMode
          ? SelectionBottomBar(
              selectedCount: selectedNoteIds.length,
              onMove: () {
                if (selectedNoteIds.isNotEmpty) {
                  _handleMoveWithLock();
                }
              },
              onDelete: () {
                if (selectedNoteIds.isNotEmpty) {
                  _handleBulkDeleteProtection();
                }
              },
            )
          : null,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Text(
            title,
            style: text20(context),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _handleBulkDeleteProtection() async {
    bool containsLockedNotes = controller.notes.where((n) => selectedNoteIds.contains(n.id)).any((n) => n.isLocked == true);

    if (containsLockedNotes) {
      final TextEditingController verifyPassController = TextEditingController();
      final settings = await lockController.getSecuritySettings();
      String storedPass = settings?['master_password'] ?? "";

      if (!mounted) return;

      showConfirmDialog(
        context: context,
        title: "verify_password",
        subTitle: "locked_notes_bulk_delete_warning".tr,
        confirmText: "verify".tr,
        controller: verifyPassController,
        obscureText: true,
        hintText: "password".tr,
        onConfirm: () {
          if (verifyPassController.text == storedPass) {
            _showBulkDeleteConfirm();
          } else {
            AppSnackbar.showError(
              title: "error".tr,
              message: "incorrect_password".tr,
            );
          }
        },
      );
    } else {
      _showBulkDeleteConfirm();
    }
  }

  void _handleMoveWithLock() async {
    final List<NoteModel> selectedNotes = controller.notes.where((n) => selectedNoteIds.contains(n.id)).toList();

    bool hasLockedNote = selectedNotes.any((n) => n.isLocked == true);

    if (hasLockedNote) {
      final TextEditingController verifyPassController = TextEditingController();
      final settings = await lockController.getSecuritySettings();
      String storedPass = settings?['master_password'] ?? "";

      if (!mounted) return;

      showConfirmDialog(
        context: context,
        title: "locked_notes",
        subTitle: "locked_notes_bulk_move_warning".tr,
        confirmText: "unlock".tr,
        controller: verifyPassController,
        obscureText: true,
        onConfirm: () {
          if (verifyPassController.text == storedPass) {
            _showMoveSheet(selectedNoteIds.toList());
          } else {
            AppSnackbar.showError(
              title: "access_denied".tr,
              message: "incorrect_password".tr,
            );
          }
        },
      );
    } else {
      _showMoveSheet(selectedNoteIds.toList());
    }
  }

  void _verifyAndMove(List<int> noteIds) async {
    final TextEditingController verifyPassController = TextEditingController();
    final settings = await lockController.getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (!mounted) return;

    showConfirmDialog(
      context: context,
      title: "locked_note".tr,
      subTitle: "enter_password_move_note".tr,
      confirmText: "unlock".tr,
      controller: verifyPassController,
      obscureText: true,
      hintText: "password".tr,
      onConfirm: () {
        if (verifyPassController.text == storedPass) {
          _showMoveSheet(noteIds);
        } else {
          AppSnackbar.showError(
            title: "access_denied".tr,
            message: "incorrect_password".tr,
          );
        }
      },
    );
  }

  void _showMoveSheet(List<int> noteIds) {
    ConfirmBottomSheet.show(
      context: context,
      title: "move_to_folder".tr,
      showTopCancel: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Obx(() {
              final otherFolders = folderController.folders.where((f) => f.id != widget.folderId).toList();
              if (otherFolders.isEmpty) {
                return CustomNoData(
                  message: "no_data".tr,
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: otherFolders.length,
                itemBuilder: (context, index) {
                  final folder = otherFolders[index];
                  return FolderListTile(
                    title: folder.title,
                    onTap: () async {
                      await controller.bulkMoveNotes(noteIds, folder.id!);
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
        ],
      ),
    );
  }

  void _showBulkDeleteConfirm() {
    showConfirmDialog(
      context: context,
      title: "delete_note".tr,
      subTitle: selectedNoteIds.length > 1 ? 'delete_notes_bulk_confirm'.tr : 'delete_note_confirm'.tr,
      confirmText: "delete".tr,
      onConfirm: () async {
        await controller.bulkMoveToTrash(selectedNoteIds.toList(), widget.folderId);
        setState(() {
          isSelectionMode = false;
          selectedNoteIds.clear();
        });
      },
    );
  }

  void _showDeleteConfirmation(NoteModel note) {
    showConfirmDialog(
      context: context,
      title: "delete_note".tr,
      subTitle: "delete_note_confirm".tr,
      confirmText: "delete".tr,
      onConfirm: () async {
        await controller.moveToTrash(note.id!, widget.folderId);
      },
    );
  }
}
