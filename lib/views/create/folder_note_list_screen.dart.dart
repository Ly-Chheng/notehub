import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/create/components/delete_confirmation_sheet.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/popup_lists_menu.dart';
import 'package:project_structure/widgets/sheet_header.dart';

class FolderNoteListScreen extends StatefulWidget {
  final dynamic folderKey;
  final String folderName;

  const FolderNoteListScreen({
    super.key,
    required this.folderKey,
    required this.folderName,
  });

  @override
  State<FolderNoteListScreen> createState() => _FolderNoteListScreenState();
}

class _FolderNoteListScreenState extends State<FolderNoteListScreen> {
  final NoteController controller = Get.put(NoteController());
  final Box noteBox = Hive.box('student_notes');
  final Box trashBox = Hive.box('recently_deleted');
  bool isSelectionMode = false;
  Set<dynamic> selectedKeys = {};

  bool isSearching = false;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  bool _anySelectedNoteIsLocked() {
    return selectedKeys.any((key) {
      final note = noteBox.get(key);
      return note != null && (note['isLocked'] ?? false);
    });
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
          PopupMenuButton<String>(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor().primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                Icons.more_vert_outlined,
                color: AppColor().primaryColor,
                size: 20,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            offset: const Offset(0, 50),
            color: Theme.of(context).cardColor,
            onSelected: (value) => _handleMenuSelection(value),
            itemBuilder: (context) => [
              buildPopupItem(
                context,
                isSelectionMode ? 'Cancel Selection' : 'Select Notes',
                isSelectionMode ? Icons.check_circle_sharp : Icons.radio_button_unchecked,
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: SlidableAutoCloseBehavior(
                  closeWhenOpened: true,
                  child: ValueListenableBuilder(
                      valueListenable: noteBox.listenable(),
                      builder: (context, Box box, _) {
                        return Obx(() {
                          final notesList = controller.getFilteredNotes(widget.folderKey);

                          if (notesList.isEmpty) {
                            return CustomNoData(
                              message: controller.searchQuery.isEmpty ? "No notes in this folder" : "No results matching",
                            );
                          }

                          final pinnedNotes = notesList.where((e) => e.value['isPinned'] == true).toList();
                          final unpinnedNotes = notesList.where((e) => e.value['isPinned'] != true).toList();

                          if (notesList.isEmpty) {
                            return CustomNoData(
                              message: searchQuery.isEmpty ? "No notes in this folder" : "No results matching",
                            );
                          }

                          return ListView(
                            children: [
                              if (pinnedNotes.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
                                  child: Text(
                                    "Pinned",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor().primaryColor,
                                    ),
                                  ),
                                ),
                                ...pinnedNotes.map((entry) => _buildSlidableNote(entry.key, entry.value)).toList(),
                              ],
                              if (unpinnedNotes.isNotEmpty) ...[
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: unpinnedNotes.length,
                                  itemBuilder: (context, index) {
                                    final entry = unpinnedNotes[index];
                                    final noteKey = entry.key;
                                    final noteData = entry.value;

                                    String currentHeader = controller.getDateHeader(noteData['date'] ?? "");
                                    String? prevHeader;
                                    if (index > 0) {
                                      prevHeader = controller.getDateHeader(unpinnedNotes[index - 1].value['date'] ?? "");
                                    }

                                    bool showHeader = currentHeader != prevHeader;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (showHeader)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 20, bottom: 10, left: 5),
                                            child: Text(
                                              currentHeader,
                                              style: text18(context).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        _buildSlidableNote(noteKey, noteData),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          );
                        });
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor().primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => Get.to(() => CreateNoteScreen(folderKey: widget.folderKey)),
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: isSelectionMode
          ? BottomAppBar(
              color: Theme.of(context).cardColor,
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.folder,
                        color: AppColor().primaryColor,
                        size: 24,
                      ),
                      onPressed: selectedKeys.isEmpty
                          ? null
                          : () {
                              controller.verifyAndExecute(
                                context: context,
                                isLocked: _anySelectedNoteIsLocked(),
                                title: "Move Protected Notes",
                                onVerified: () => _showMoveNotesSheet(),
                              );
                            },
                    ),
                    const Spacer(),
                    Text(
                      "${selectedKeys.length} selected",
                      style: const TextStyle(fontSize: 12, fontFamily: 'EN-ENGULAR'),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 24,
                      ),
                      onPressed: selectedKeys.isEmpty
                          ? null
                          : () {
                              controller.verifyAndExecute(
                                context: context,
                                isLocked: _anySelectedNoteIsLocked(),
                                title: "Delete Protected Notes",
                                onVerified: () {
                                  showDeleteConfirmationSheet(
                                    context,
                                    () {
                                      controller.deleteSelectedNotes(
                                        selectedKeys: selectedKeys,
                                        onComplete: () {
                                          setState(() {
                                            selectedKeys.clear();
                                            isSelectionMode = false;
                                          });
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSlidableNote(dynamic noteKey, dynamic note) {
    bool isLocked = note['isLocked'] ?? false;
    bool isPinned = note['isPinned'] ?? false;
    bool isSelected = selectedKeys.contains(noteKey);
    List<dynamic>? imagePaths = note['images'];

    final dynamic savedColor = note['bgColorValue'];
    final Color noteBgColor = (savedColor == null || savedColor == 0xFFFFFFFF) ? Theme.of(context).cardColor : Color(savedColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Slidable(
        key: ValueKey(noteKey),
        enabled: !isSelectionMode,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.6,
          children: [
            SlidableAction(
              onPressed: (context) {
                final updated = Map<String, dynamic>.from(note);
                updated['isPinned'] = !isPinned;
                noteBox.put(noteKey, updated);
              },
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              label: isPinned ? 'Unpin' : 'Pin',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
            ),
            SlidableAction(
              onPressed: (context) => controller.verifyAndExecute(
                context: context,
                isLocked: isLocked,
                title: "Move Locked Note",
                onVerified: () => _showMoveNotesSheet(singleNoteKey: noteKey),
              ),
              backgroundColor: AppColor().primaryColor,
              foregroundColor: Colors.white,
              icon: Icons.folder,
              label: 'Folder',
            ),
            SlidableAction(
              onPressed: (context) => controller.verifyAndExecute(
                context: context,
                isLocked: isLocked,
                title: "Delete Locked Note",
                onVerified: () {
                  final noteData = noteBox.get(noteKey);
                  if (noteData != null) {
                    trashBox.put(noteKey, {
                      ...Map<String, dynamic>.from(noteData),
                      'deletedAt': DateTime.now().toIso8601String(),
                    });
                    noteBox.delete(noteKey);
                  }
                },
              ),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            if (isSelectionMode) {
              setState(() {
                if (isSelected) {
                  selectedKeys.remove(noteKey);
                } else {
                  selectedKeys.add(noteKey);
                }
              });
            } else {
              controller.verifyAndExecute(
                context: context,
                isLocked: isLocked,
                onVerified: () {
                  Get.to(() => CreateNoteScreen(
                        isEditing: true,
                        noteKey: noteKey,
                        existingNote: note,
                        folderKey: widget.folderKey,
                      ));
                },
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: noteBgColor,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: AppColor().primaryColor, width: 1) : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColor().primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: AppColor().primaryColor,
                            size: 15,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (isSelectionMode)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Icon(
                                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: AppColor().primaryColor,
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              note['title']?.isEmpty == true ? "" : note['title'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: context.isPhone ? 18 : 20,
                                                color: Theme.of(context).colorScheme.onSurface,
                                                fontFamily: 'EN-BOLD',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Text(
                                          controller.getPlainTextFromNote(note['subtitle']),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: context.isPhone ? 14 : 16,
                                            fontFamily: 'EN-REGULAR',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (imagePaths != null && imagePaths.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePaths[0]),
                        width: context.isPhone ? 50 : 80,
                        height: context.isPhone ? 50 : 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: context.isPhone ? 50 : 80,
                          height: context.isPhone ? 50 : 80,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, size: context.isPhone ? 24 : 30),
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  width: 15,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    if (value == 'Select Notes' || value == 'Cancel Selection') {
      setState(() {
        isSelectionMode = !isSelectionMode;
        selectedKeys.clear();
      });
    }
  }

  void _showMoveNotesSheet({dynamic singleNoteKey}) {
    final folderBox = Hive.box('folders_box');
    final folders = folderBox.toMap().entries.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(title: "Move to Folder"),
            if (folders.isEmpty)
              CustomNoData(
                message: "No other folders found",
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  final bool isCurrentFolder = folder.key == widget.folderKey;
                  String folderTitle = folder.value['title'] ?? "Unnamed Folder";
                  return ListTile(
                    leading: Icon(Icons.folder, color: AppColor().primaryColor),
                    title: Text(folderTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: isCurrentFolder ? Icon(Icons.check, color: AppColor().primaryColor) : null,
                    onTap: () async {
                      if (!isCurrentFolder) {
                        await controller.moveNotesToFolder(
                          keysToMove: singleNoteKey != null ? [singleNoteKey] : selectedKeys.toList(),
                          targetFolderKey: folder.key,
                        );
                      }
                      Navigator.pop(context);
                      setState(() {
                        isSelectionMode = false;
                        selectedKeys.clear();
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return customTextField(
      "Search notes...",
      false,
      null,
      controller: searchController,
      onChanged: controller.updateSearchQuery,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                searchController.clear();
                controller.updateSearchQuery("");
              },
            )
          : const SizedBox.shrink()),
    );
  }
}
