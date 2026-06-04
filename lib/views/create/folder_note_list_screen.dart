import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/controllers/notes/folder_controller.dart';
import 'package:project_structure/core/functions/fomat_date.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/note/note_model.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/custom_slidableasction.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/multi_style.dart';

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

  // NAVIGATION LOGIC WITH LOCK
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

    // Fetch settings from SQLite via LockController
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
        title: widget.folderName,
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          Obx(() {
            final bool hasNoData = controller.notes.isEmpty;

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
          _buildSearchBar(),
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
                return const CustomNoData(message: "No data");
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
                        (note) => _buildSlidableNote(note),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ...groupedNotes.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(entry.key),
                          ...entry.value.map(
                            (note) => _buildSlidableNote(note),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              );
            }),
          )
        ],
      ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              backgroundColor: AppColor().primaryColor,
              onPressed: () async {
                final result = await Get.to(() => CreateNoteScreen(folderId: widget.folderId));
                if (result == true) controller.fetchNotesByFolder(widget.folderId);
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomNavigationBar: isSelectionMode ? _buildSelectionBottomBar() : null,
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

  Widget _buildSlidableNote(NoteModel note) {
    bool isSelected = selectedNoteIds.contains(note.id);
    final List<String> imagePaths = note.imagePaths;

    final Color noteBgColor = (note.bgColor == 0) ? Theme.of(context).cardColor : Color(note.bgColor);

    final Color itemTextColor = (note.bgColor == 0)
        ? (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black)
        : (ThemeData.estimateBrightnessForColor(noteBgColor) == Brightness.dark ? AppColor().white : AppColor().black);

    final Color itemSubTextColor = itemTextColor.withValues(alpha: 0.7);

    final String titleText = note.title.trim().isNotEmpty ? note.title : controller.getPlainTextFromNote(note.content).trim();
    final String plainContent = controller.getPlainTextFromNote(note.content).trim();
    final String subtitleText = note.title.trim().isNotEmpty ? plainContent : "";

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
              onPressed: () => controller.togglePinNote(note, widget.folderId),
              icon: note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              label: note.isPinned ? 'unpin'.tr : 'pin'.tr,
              backgroundColor: AppColor().orange,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            AppSlidableAction(
              onPressed: () {
                if (note.isLocked == true) {
                  _verifyAndMove([note.id!]);
                } else {
                  _showMoveSheet([note.id!]);
                }
              },
              icon: Icons.folder,
              label: 'folder'.tr,
              backgroundColor: AppColor().primaryColor,
            ),
            AppSlidableAction(
              onPressed: () {
                note.isLocked ? _showUnlockBeforeDelete(note) : _showDeleteConfirmation(note);
              },
              icon: Icons.delete,
              label: 'delete'.tr,
              backgroundColor: AppColor().red,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _handleNoteTap(note),
          child: Container(
            decoration: BoxDecoration(
                color: noteBgColor,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(
                        color: AppColor().primaryColor,
                        width: 1.5,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.04),
                    blurRadius: 5,
                    spreadRadius: 0,
                    offset: Offset(0, 3),
                  )
                ]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isSelectionMode)
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: AppColor().primaryColor,
                      size: 24,
                    ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (note.isLocked == true)
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor().primaryColor.withValues(alpha: 0.1)),
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.lock,
                                  size: 18,
                                  color: AppColor().primaryColor,
                                ),
                              ),
                            SizedBox(width: note.isLocked == true ? 6 : 0),
                            Flexible(
                              child: Text(
                                titleText.isNotEmpty ? titleText : "untitled".tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text18(context).copyWith(
                                  color: itemTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              // note.date.toString(),
                              formatDateForLocale(note.date),
                              style: text14(context).copyWith(color: itemSubTextColor),
                            ),
                            const SizedBox(width: 8),
                            if (subtitleText.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  subtitleText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text14(context).copyWith(color: itemSubTextColor),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (imagePaths.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePaths[0]),
                        width: context.isPhone ? 60 : 80,
                        height: context.isPhone ? 60 : 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: context.isPhone ? 60 : 80,
                          height: context.isPhone ? 60 : 80,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, size: context.isPhone ? 24 : 30),
                        ),
                      ),
                    ),
                  if (imagePaths.isNotEmpty) SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
      child: customTextField(
        "search".tr,
        false,
        null,
        controller: searchController,
        onChanged: (v) => controller.searchNotes(v, widget.folderId),
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildSelectionBottomBar() {
    return BottomAppBar(
      height: 50,
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomAction(Icons.folder, AppColor().primaryColor, () {
            if (selectedNoteIds.isNotEmpty) {
              _handleMoveWithLock();
            }
          }),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${selectedNoteIds.length} ${'selected'.tr} ',
                style: text10,
              ),
            ],
          ),
          _buildBottomAction(Icons.delete, AppColor().red, () {
            if (selectedNoteIds.isNotEmpty) _handleBulkDeleteProtection();
          }),
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

  Widget _buildBottomAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: context.isPhone ? 25 : 30,
          ),
        ],
      ),
    );
  }

  void _verifyAndMove(List<int> noteIds) async {
    final TextEditingController verifyPassController = TextEditingController();
    final settings = await lockController.getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (!mounted) return;

    showConfirmDialog(
      context: context,
      title: "locked_note",
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
            SheetHeader(title: "move_to_folder".tr),
            Flexible(
              child: Obx(() {
                final otherFolders = folderController.folders.where((f) => f.id != widget.folderId).toList();
                if (otherFolders.isEmpty) {
                  return const CustomNoData(
                    message: "no_data",
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: otherFolders.length,
                  itemBuilder: (context, index) {
                    final folder = otherFolders[index];
                    return ListTile(
                      leading: Icon(Icons.folder, color: AppColor().primaryColor),
                      title: Text(
                        folder.title,
                        style: text16(context),
                      ),
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
      ),
    );
  }

  void _showBulkDeleteConfirm() {
    showConfirmDialog(
      context: context,
      title: "delete_note".tr,
      // subTitle: "Are you sure you want to delete ${selectedNoteIds.length} selected ${selectedNoteIds.length > 1 ? 'notes' : 'note'}?",
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
