import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';

import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/controllers/notes/folder_controller.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/note/note_model.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/sheet_header.dart';

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

  // --- NEW: NAVIGATION LOGIC WITH LOCK ---
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

  // void _showUnlockDialog(NoteModel note) {
  //   final TextEditingController verifyPassController = TextEditingController();
  //   String storedPass = lockController.settingsBox.get('master_password') ?? "";

  //   showConfirmDialog(
  //     context: context,
  //     title: "Locked Note",
  //     subTitle: "Please enter your password to view this note.",
  //     confirmText: "Unlock",
  //     controller: verifyPassController,
  //     obscureText: true,
  //     hintText: "Password",
  //     onConfirm: () {
  //       if (verifyPassController.text == storedPass) {
  //         _navigateToCreateNote(note);
  //       } else {
  //         Get.snackbar(
  //           "Error",
  //           "Incorrect Password",
  //           backgroundColor: AppColor().red,
  //           colorText: Colors.white,
  //           snackPosition: SnackPosition.TOP,
  //         );
  //       }
  //     },
  //   );
  // }

void _showUnlockDialog(NoteModel note) async {
    final TextEditingController verifyPassController = TextEditingController();
    
    // Fetch settings from SQLite via LockController
    final settings = await lockController.getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (!mounted) return;

    showConfirmDialog(
      context: context,
      title: "Locked Note",
      subTitle: "Please enter your password to view this note.",
      confirmText: "Unlock",
      controller: verifyPassController,
      obscureText: true,
      hintText: "Password",
      onConfirm: () {
        if (verifyPassController.text == storedPass) {
          _navigateToCreateNote(note);
        } else {
          Get.snackbar(
            "Error",
            "Incorrect Password",
            backgroundColor: AppColor().red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
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
          IconButton(
            icon: Icon(isSelectionMode ? Icons.close : Icons.more_vert_outlined),
            color: AppColor().primaryColor,
            onPressed: () {
              setState(() {
                isSelectionMode = !isSelectionMode;
                selectedNoteIds.clear();
              });
            },
          ),
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
                ));
              }

              if (controller.notes.isEmpty) {
                return const CustomNoData(message: "No notes found");
              }

              final pinnedNotes = controller.notes.where((n) => n.isPinned).toList();
              final otherNotes = controller.notes.where((n) => !n.isPinned).toList();

              Map<String, List<NoteModel>> groupedNotes = {};

              for (var note in otherNotes) {
                String dateKey = controller.getDateHeader(note.date.toString());

                if (groupedNotes[dateKey] == null) {
                  groupedNotes[dateKey] = [];
                }
                groupedNotes[dateKey]!.add(note);
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  if (pinnedNotes.isNotEmpty) ...[
                    _buildSectionHeader("Pinned"),
                    ...pinnedNotes.map((note) => _buildSlidableNote(note)),
                    const SizedBox(height: 10),
                  ],
                  ...groupedNotes.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(entry.key),
                        ...entry.value.map((note) => _buildSlidableNote(note)),
                      ],
                    );
                  }),
                ],
              );
            }),
          ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Text(
            title,
            style: text20(context),
          ),
          const Spacer(),
          if (title == "Pinned") Icon(Icons.keyboard_arrow_down, color: AppColor().orange, size: 22),
        ],
      ),
    );
  }

  Widget _buildSlidableNote(NoteModel note) {
    bool isSelected = selectedNoteIds.contains(note.id);
    final List<String> imagePaths = note.imagePaths ?? [];

    final Color noteBgColor = (note.bgColor == null || note.bgColor == 0) ? Theme.of(context).cardColor : Color(note.bgColor!);

    final Color itemTextColor = (note.bgColor == null || note.bgColor == 0)
        ? (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black)
        : (ThemeData.estimateBrightnessForColor(noteBgColor) == Brightness.dark ? AppColor().white : AppColor().black);

    final Color itemSubTextColor = itemTextColor.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Slidable(
        key: ValueKey(note.id),
        enabled: !isSelectionMode,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.7,
          children: [
            SlidableAction(
              onPressed: (context) => controller.togglePinNote(note, widget.folderId),
              backgroundColor: AppColor().orange,
              foregroundColor: AppColor().white,
              icon: note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              label: note.isPinned ? 'Unpin' : 'Pin',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            SlidableAction(
              onPressed: (context) => _showMoveSheet([note.id!]),
              backgroundColor: AppColor().primaryColor,
              foregroundColor: AppColor().white,
              icon: Icons.folder,
              label: 'Folder',
            ),
            SlidableAction(
              onPressed: (context) => _showDeleteConfirmation(note),
              backgroundColor: AppColor().red,
              foregroundColor: AppColor().white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ],
        ),
        child: GestureDetector(
          // onTap: () async {
          //   if (isSelectionMode) {
          //     setState(() {
          //       if (isSelected) {
          //         selectedNoteIds.remove(note.id!);
          //       } else {
          //         selectedNoteIds.add(note.id!);
          //       }
          //     });
          //   } else {
          //     final result = await Get.to(() => CreateNoteScreen(
          //           isEditing: true,
          //           existingNote: note,
          //           folderId: widget.folderId,
          //         ));

          //     if (result == true) {
          //       controller.fetchNotesByFolder(widget.folderId);
          //     }
          //   }
          // },
          onTap: () => _handleNoteTap(note),
          child: Container(
            decoration: BoxDecoration(
              color: noteBgColor,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppColor().primaryColor,
                      width: 1.5,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                              Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 18,
                                  color: AppColor().primaryColor,
                                ),
                              ),
                            Text(
                              (note.title.trim().isNotEmpty)
                                  ? note.title
                                  : (controller.getPlainTextFromNote(note.content ?? "").trim().isNotEmpty)
                                      ? controller.getPlainTextFromNote(note.content ?? "")
                                      : "Untitled",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text18(context).copyWith(
                                color: itemTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              note.date.toString(),
                              style: text14(context).copyWith(color: itemSubTextColor),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                controller.getPlainTextFromNote(note.content ?? ""),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text14(context).copyWith(color: itemSubTextColor),
                              ),
                            ),
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
      padding: const EdgeInsets.all(15),
      child: customTextField(
        "Search notes...",
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
            if (selectedNoteIds.isNotEmpty) _showMoveSheet(selectedNoteIds.toList());
          }),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${selectedNoteIds.length} selected",
                style: TextStyle(fontSize: context.isPhone ? 12 : 14, fontFamily: 'EN-ENGULAR'),
              ),
            ],
          ),
          _buildBottomAction(Icons.delete, AppColor().red, () {
            if (selectedNoteIds.isNotEmpty) _showBulkDeleteConfirm();
          }),
        ],
      ),
    );
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
            const SheetHeader(title: "Move to Folder"),
            Flexible(
              child: Obx(() {
                final otherFolders = folderController.folders.where((f) => f.id != widget.folderId).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: otherFolders.length,
                  itemBuilder: (context, index) {
                    final folder = otherFolders[index];
                    return ListTile(
                      leading: Icon(Icons.folder, color: AppColor().primaryColor),
                      title: Text(
                        folder.title,
                        style: text18(context),
                      ),
                      onTap: () async {
                        for (var id in noteIds) {
                          await controller.moveNote(id, folder.id!);
                        }
                        controller.fetchNotesByFolder(widget.folderId);
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
      title: "Delete Notes?",
      subTitle: "Are you sure you want to delete ${selectedNoteIds.length} selected notes?",
      confirmText: "Delete",
      onConfirm: () async {
        for (var id in selectedNoteIds) {
          await controller.deleteNote(id, widget.folderId);
        }
        controller.fetchNotesByFolder(widget.folderId);
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
      title: "Delete Note",
      subTitle: "Are you sure you want to delete this note?",
      confirmText: "Delete",
      onConfirm: () async {
        await controller.deleteNote(note.id!, widget.folderId);
        controller.fetchNotesByFolder(widget.folderId);
      },
    );
  }
}
