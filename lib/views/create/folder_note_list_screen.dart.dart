import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/components/delete_confirmation_sheet.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custome_no_data.dart';

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
  final Box noteBox = Hive.box('student_notes');
  bool isSelectionMode = false;
  Set<dynamic> selectedKeys = {}; // Store Hive keys, not indexes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: widget.folderName, // Fixed: Use dynamic folder name
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            offset: const Offset(0, 50),
            color: Theme.of(context).cardColor,
            onSelected: (value) => _handleMenuSelection(value),
            itemBuilder: (context) => [
              _buildPopupItem(
                isSelectionMode ? 'Cancel Selection' : 'Select Notes',
                isSelectionMode ? Icons.check_circle_sharp : Icons.radio_button_unchecked,
              ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: noteBox.listenable(),
        builder: (context, Box box, _) {
          // 1. Convert box to a list of entries (Key + Value)
          // 2. FILTER: Only notes belonging to THIS folder
          List<MapEntry<dynamic, dynamic>> notesList = box.toMap().entries.where((entry) => entry.value['folderKey'] == widget.folderKey).toList();

          // 3. SORT: Pinned first
          notesList.sort((a, b) {
            bool aPinned = a.value['isPinned'] ?? false;
            bool bPinned = b.value['isPinned'] ?? false;
            if (aPinned && !bPinned) return -1;
            if (!aPinned && bPinned) return 1;
            return 0;
          });

          if (notesList.isEmpty) {
            // return const Center(child: Text("No notes in this folder."));
            return const CustomNoData(
              message: "No notes in this folder",
            );
          }

          return ListView.builder(
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              final entry = notesList[index];
              final noteKey = entry.key; // The unique Hive ID
              final noteData = entry.value;

              return _buildSlidableNote(noteKey, noteData);
            },
          );
        },
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
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.folder, color: AppColor().primaryColor),
                      onPressed: selectedKeys.isEmpty ? null : _showMoveNotesSheet,
                    ),
                    const Spacer(),
                    Text(
                      "${selectedKeys.length} selected",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: selectedKeys.isEmpty
                          ? null
                          : () {
                              showDeleteConfirmationSheet(
                                context,
                                () {
                                  _deleteSelectedNotes();
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
    bool isPinned = note['isPinned'] ?? false;
    bool isSelected = selectedKeys.contains(noteKey);

    bool noteIsBold = note['isBold'] ?? false;
    bool noteIsItalic = note['isItalic'] ?? false;
    bool noteIsUnderlined = note['isUnderlined'] ?? false;
    bool noteIsStrikethrough = note['isStrikethrough'] ?? false;
    int? colorValue = note['colorValue'];
    Color noteColor = colorValue != null ? Color(colorValue) : Colors.black;
    final bgColor = Color(note['bgColorValue'] ?? 0xFFFFFFFF);

    // Image Data
    List<dynamic>? imagePaths = note['images'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Slidable(
        key: ValueKey(noteKey),
        enabled: !isSelectionMode, // Disable slide when selecting
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
              onPressed: (context) => _showMoveNotesSheet(singleNoteKey: noteKey),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.folder,
              label: 'Folder',
            ),
            SlidableAction(
              onPressed: (context) => noteBox.delete(noteKey),
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
              Get.to(() => CreateNoteScreen(
                    isEditing: true,
                    noteKey: noteKey,
                    existingNote: note,
                    folderKey: widget.folderKey,
                  ));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
              border: isSelected ? Border.all(color: AppColor().primaryColor, width: 1) : null,
            ),
            child: Row(
              children: [
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: AppColor().primaryColor,
                    ),
                  ),
                if (isPinned && !isSelectionMode)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.push_pin, color: Colors.orange, size: 20),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note['title']?.isEmpty == true ? "Untitled" : note['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: context.isPhone ? 18 : 20, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          note['subtitle'] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.isPhone ? 14 : 16,
                            color: noteColor,
                            fontWeight: noteIsBold ? FontWeight.bold : FontWeight.normal,
                            fontStyle: noteIsItalic ? FontStyle.italic : FontStyle.normal,
                            decoration: TextDecoration.combine([
                              if (noteIsUnderlined) TextDecoration.underline,
                              if (noteIsStrikethrough) TextDecoration.lineThrough,
                            ]),
                          ),
                        ),
                      ),
                      Text(
                        (note['date'] ?? "").replaceAll("/", "-"),
                        style: TextStyle(
                          fontSize: context.isPhone ? 11 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // --- IMAGE PREVIEW THUMBNAIL (Right side) ---
                if (imagePaths != null && imagePaths.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePaths[0]), // Displays the first image taken
                        width: context.isPhone ? 70 : 100,
                        height: context.isPhone ? 70 : 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: context.isPhone ? 70 : 100,
                          height: context.isPhone ? 70 : 100,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, size: context.isPhone ? 24 : 30),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteSelectedNotes() {
    for (var key in selectedKeys) {
      noteBox.delete(key);
    }
    setState(() {
      selectedKeys.clear();
      isSelectionMode = false;
    });
  }

  PopupMenuItem<String> _buildPopupItem(String title, IconData icon) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: context.isPhone ? 20 : 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(fontSize: context.isPhone ? 14 : 16),
          ),
        ],
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

  // Add dynamic? singleNoteKey as a parameter
  void _showMoveNotesSheet({dynamic singleNoteKey}) {
    final folderBox = Hive.box('folders_box');
    final List<MapEntry<dynamic, dynamic>> folders = folderBox.toMap().entries.where((entry) => entry.key != widget.folderKey).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: context.isPhone ? 16 : 18,
                          fontFamily: 'EN-REGULAR',
                        ))),
                Text("Move to Folder",
                    style: TextStyle(
                      fontSize: context.isPhone ? 16 : 18,
                      fontFamily: 'EN-BOLD',
                    )),
              ],
            ),
            const SizedBox(height: 20),
            if (folders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No other folders found"),
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return ListTile(
                    leading: Icon(Icons.folder, size: context.isPhone ? 24 : 30, color: Color(folder.value['colorValue'] ?? Colors.blue.value)),
                    title: Text(
                      folder.value['title'] ?? "Unnamed Folder",
                      style: TextStyle(fontSize: context.isPhone ? 14 : 16),
                    ),
                    onTap: () async {
                      // Determine if we are moving one note or the selection
                      List<dynamic> keysToMove = singleNoteKey != null ? [singleNoteKey] : selectedKeys.toList();

                      for (var noteKey in keysToMove) {
                        final noteData = noteBox.get(noteKey);
                        if (noteData != null) {
                          final updatedNote = Map<String, dynamic>.from(noteData);
                          updatedNote['folderKey'] = folder.key;
                          await noteBox.put(noteKey, updatedNote);
                        }
                      }

                      Navigator.pop(context);
                      setState(() {
                        isSelectionMode = false;
                        selectedKeys.clear();
                      });

                      Get.snackbar("Success", "Moved to ${folder.value['title']}", snackPosition: SnackPosition.BOTTOM, colorText: Colors.white);
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
}
