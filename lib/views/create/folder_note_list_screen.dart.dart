import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_button.dart';

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
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteSelectedNotes,
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            offset: const Offset(0, 50),
            color: Theme.of(context).cardColor,
            onSelected: (value) => _handleMenuSelection(value),
            itemBuilder: (context) => [
              _buildPopupItem(
                isSelectionMode ? 'Cancel Selection' : 'Select Notes',
                isSelectionMode ? Icons.close : Icons.radio_button_unchecked,
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
            return const Center(child: Text("No notes in this folder."));
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
              icon: isPinned ? Icons.push_pin : Icons.push_pin,
              label: isPinned ? 'Unpin' : 'Pin',
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
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: AppColor().primaryColor, width: 2) : null,
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        note['subtitle'] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: noteColor.withOpacity(0.7),
                          fontWeight: noteIsBold ? FontWeight.bold : FontWeight.normal,
                          fontStyle: noteIsItalic ? FontStyle.italic : FontStyle.normal,
                          decoration: TextDecoration.combine([
                            if (noteIsUnderlined) TextDecoration.underline,
                            if (noteIsStrikethrough) TextDecoration.lineThrough,
                          ]),
                        ),
                      ),
                    ],
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
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(title),
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
}
