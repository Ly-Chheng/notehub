import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/components/delete_confirmation_sheet.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
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

  bool isSearching = false;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  bool _anySelectedNoteIsLocked() {
    return selectedKeys.any((key) {
      final note = noteBox.get(key);
      return note != null && (note['isLocked'] ?? false);
    });
  }

  // UNIVERSAL PASSWORD VERIFICATION
  void _verifyAndExecute({required bool isLocked, required VoidCallback onVerified, String title = "This note is locked."}) {
    if (!isLocked) {
      onVerified();
      return;
    }

    final TextEditingController passController = TextEditingController();
    final Box settingsBox = Hive.box('settings_box');
    String? masterPassword = settingsBox.get('master_password');

    showConfirmDeleteDialog(
      context: context,
      title: title,
      subTitle: "Verification required for this locked note.",
      confirmText: "Unlock",
      controller: passController,
      obscureText: true,
      hintText: "Master Password",
      onConfirm: () {
        if (passController.text == masterPassword) {
          onVerified();
        } else {
          Get.snackbar(
            "Error",
            "Incorrect Password",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  String _getDateHeader(String dateStr) {
    try {
      DateTime noteDate = DateFormat('dd/MM/yyyy').parse(dateStr);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));

      if (noteDate.isAtSameMomentAs(today)) {
        return "Today";
      } else if (noteDate.isAtSameMomentAs(yesterday)) {
        return "Yesterday";
      } else if (noteDate.year == now.year) {
        return DateFormat('MMMM d').format(noteDate);
      } else {
        return DateFormat('MMMM d, y').format(noteDate);
      }
    } catch (e) {
      return "Earlier";
    }
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          children: [
            /// SEARCH BAR
            TextFormField(
              controller: searchController,
              style: TextStyle(fontSize: context.isPhone ? 16 : 18),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor().primaryColor, width: 1),
                ),
                hintText: "Search",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: AppColor().primaryColor),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            SizedBox(
              height: 20,
            ),

            /// NOTES LIST
            // Expanded(
            //   child: ValueListenableBuilder(
            //     valueListenable: noteBox.listenable(),
            //     builder: (context, Box box, _) {
            //       // 1. Get notes for THIS folder
            //       List<MapEntry<dynamic, dynamic>> notesList = box.toMap().entries.where((entry) => entry.value['folderKey'] == widget.folderKey).toList();

            //       /// SEARCH FILTER
            //       if (searchQuery.isNotEmpty) {
            //         notesList = notesList.where((entry) {
            //           final title = (entry.value['title'] ?? "").toString().toLowerCase();
            //           final content = (entry.value['subtitle'] ?? "").toString().toLowerCase();

            //           return title.contains(searchQuery) || content.contains(searchQuery);
            //         }).toList();
            //       }

            //       notesList.sort((a, b) {
            //         bool aPinned = a.value['isPinned'] ?? false;
            //         bool bPinned = b.value['isPinned'] ?? false;

            //         if (aPinned != bPinned) {
            //           return aPinned ? -1 : 1;
            //         }

            //         return b.key.compareTo(a.key);
            //       });

            //       if (notesList.isEmpty) {
            //         return CustomNoData(
            //           message: searchQuery.isEmpty ? "No notes in this folder" : "No results matching",
            //         );
            //       }

            //       /// LIST BUILDER WITH DATE HEADERS
            //       return ListView.builder(
            //         itemCount: notesList.length,
            //         itemBuilder: (context, index) {
            //           final entry = notesList[index];
            //           final noteKey = entry.key;
            //           final noteData = entry.value;

            //           // 4. GROUPING LOGIC
            //           String currentHeader = _getDateHeader(noteData['date'] ?? "");
            //           String? prevHeader;
            //           if (index > 0) {
            //             prevHeader = _getDateHeader(notesList[index - 1].value['date'] ?? "");
            //           }

            //           bool showHeader = currentHeader != prevHeader;

            //           return Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               if (showHeader)
            //                 Padding(
            //                   padding: const EdgeInsets.only(top: 20, bottom: 10, left: 5),
            //                   child: Text(
            //                     currentHeader,
            //                     style: TextStyle(
            //                       fontSize: 14,
            //                       fontWeight: FontWeight.bold,
            //                       color: Colors.grey[600],
            //                     ),
            //                   ),
            //                 ),
            //               _buildSlidableNote(noteKey, noteData),
            //             ],
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: noteBox.listenable(),
                builder: (context, Box box, _) {
                  // 1. Get notes for THIS folder
                  List<MapEntry<dynamic, dynamic>> notesList = box.toMap().entries.where((entry) => entry.value['folderKey'] == widget.folderKey).toList();

                  /// SEARCH FILTER
                  if (searchQuery.isNotEmpty) {
                    notesList = notesList.where((entry) {
                      final title = (entry.value['title'] ?? "").toString().toLowerCase();
                      final content = (entry.value['subtitle'] ?? "").toString().toLowerCase();
                      return title.contains(searchQuery) || content.contains(searchQuery);
                    }).toList();
                  }

                  // 2. SPLIT: Create two separate lists
                  List<MapEntry<dynamic, dynamic>> pinnedNotes = notesList.where((e) => e.value['isPinned'] == true).toList();
                  List<MapEntry<dynamic, dynamic>> unpinnedNotes = notesList.where((e) => e.value['isPinned'] != true).toList();

                  // 3. SORT: Newest at the top (Highest Hive Key)
                  pinnedNotes.sort((a, b) => b.key.compareTo(a.key));
                  unpinnedNotes.sort((a, b) => b.key.compareTo(a.key));

                  if (notesList.isEmpty) {
                    return CustomNoData(
                      message: searchQuery.isEmpty ? "No notes in this folder" : "No results matching",
                    );
                  }

                  return ListView(
                    children: [
                      /// PINNED SECTION BLOCK
                      if (pinnedNotes.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
                          child: Text(
                            "Pinned",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColor().primaryColor, // Matching your theme
                            ),
                          ),
                        ),
                        ...pinnedNotes.map((entry) => _buildSlidableNote(entry.key, entry.value)).toList(),
                      ],

                      /// UNPINNED SECTION WITH DATE HEADERS
                      if (unpinnedNotes.isNotEmpty) ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), // Main ListView handles scrolling
                          itemCount: unpinnedNotes.length,
                          itemBuilder: (context, index) {
                            final entry = unpinnedNotes[index];
                            final noteKey = entry.key;
                            final noteData = entry.value;

                            // Grouping Logic for Unpinned Notes
                            String currentHeader = _getDateHeader(noteData['date'] ?? "");
                            String? prevHeader;
                            if (index > 0) {
                              prevHeader = _getDateHeader(unpinnedNotes[index - 1].value['date'] ?? "");
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
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
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
                },
              ),
            ),
          ],
        ),
      ),

      /// ADD NOTE BUTTON
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
                      // onPressed: selectedKeys.isEmpty ? null : _showMoveNotesSheet,
                      onPressed: selectedKeys.isEmpty
                          ? null
                          : () {
                              // Check if security is needed
                              _verifyAndExecute(
                                isLocked: _anySelectedNoteIsLocked(),
                                title: "Move Protected Notes",
                                onVerified: () => _showMoveNotesSheet(),
                              );
                            },
                    ),
                    const Spacer(),
                    Text(
                      "${selectedKeys.length} selected",
                      style: const TextStyle(fontSize: 11, fontFamily: 'EN-ENGULAR'),
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
                              _verifyAndExecute(
                                isLocked: _anySelectedNoteIsLocked(),
                                title: "Delete Protected Notes",
                                onVerified: () {
                                  showDeleteConfirmationSheet(
                                    context,
                                    () => _deleteSelectedNotes(),
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

    bool noteIsBold = note['isBold'] ?? false;
    bool noteIsItalic = note['isItalic'] ?? false;
    bool noteIsUnderlined = note['isUnderlined'] ?? false;
    bool noteIsStrikethrough = note['isStrikethrough'] ?? false;
    int? colorValue = note['colorValue'];
    Color noteColor = colorValue != null ? Color(colorValue) : Colors.black;
    final bgColor = Color(note['bgColorValue'] ?? 0xFFFFFFFF);

    List<dynamic>? imagePaths = note['images'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Slidable(
        key: ValueKey(noteKey),
        enabled: !isSelectionMode,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.6,
          children: [
            SizedBox(
              width: 10,
            ),
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
              onPressed: (context) => _verifyAndExecute(
                isLocked: isLocked,
                title: "Move Locked Note",
                onVerified: () => _showMoveNotesSheet(singleNoteKey: noteKey),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.folder,
              label: 'Folder',
            ),
            SlidableAction(
              onPressed: (context) => _verifyAndExecute(
                isLocked: isLocked,
                title: "Delete Locked Note",
                onVerified: () => noteBox.delete(noteKey),
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
              _verifyAndExecute(
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
              color: bgColor,
              borderRadius: BorderRadius.circular(13),
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
                            size: 16,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // if (isPinned && !isSelectionMode)
                                //   const Padding(
                                //     padding: EdgeInsets.only(right: 10),
                                //     child: Icon(Icons.push_pin, color: Colors.orange, size: 15),
                                //   ),
                              ],
                            ),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          note['title']?.isEmpty == true ? "" : note['title'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: context.isPhone ? 18 : 20,
                                            fontFamily: 'EN-BOLD',
                                            color: noteColor,
                                          ),
                                        ),
                                      ],
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
                                  ],
                                ),
                              ],
                            ),
                          ],
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
                        File(imagePaths[0]),
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
