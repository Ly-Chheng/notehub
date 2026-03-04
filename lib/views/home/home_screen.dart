import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/views/create/folder_note_list_screen.dart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Box folderBox = Hive.box('folders_box');
  final String defaultFolderName = "My Note";

  // 1. Define the note box at the top of your _MyHomePageState
  final Box noteBox = Hive.box('student_notes');

  @override
  void initState() {
    super.initState();
    _ensureDefaultFolder();
  }

  void _ensureDefaultFolder() {
    bool exists = folderBox.values.any((f) => f['title'] == defaultFolderName);
    if (!exists) {
      folderBox.add({
        "title": defaultFolderName,
        "colorValue": Colors.orange.value,
        "isPinned": false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text("Folders", style: TextStyle(fontSize: 18, fontFamily: 'EN-BOLD')),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: folderBox.listenable(),
              builder: (context, Box box, _) {
                List<MapEntry<dynamic, dynamic>> folders = box.toMap().entries.toList();

                // iPhone Sort: 1. Default Folder, 2. Pinned Folders, 3. Rest
                folders.sort((a, b) {
                  if (a.value['title'] == defaultFolderName) return -1;
                  if (b.value['title'] == defaultFolderName) return 1;

                  bool aPinned = a.value['isPinned'] ?? false;
                  bool bPinned = b.value['isPinned'] ?? false;
                  if (aPinned && !bPinned) return -1;
                  if (!aPinned && bPinned) return 1;
                  return 0;
                });

                return ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folderKey = folders[index].key;
                    final folderData = folders[index].value;
                    bool isDefault = folderData['title'] == defaultFolderName;
                    bool isPinned = folderData['isPinned'] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Slidable(
                            enabled: !isDefault,
                            // START ACTION (Swipe Right to Pin)
                            startActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (c) {
                                    final updated = Map<String, dynamic>.from(folderData);
                                    updated['isPinned'] = !isPinned;
                                    folderBox.put(folderKey, updated);
                                  },
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                  label: isPinned ? 'Unpin' : 'Pin',
                                ),
                              ],
                            ),
                            // END ACTION (Swipe Left to Edit/Delete)
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (c) => _showFolderSheet(context, folderKey: folderKey, existingData: folderData),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                ),
                                SlidableAction(
                                  onPressed: (c) => folderBox.delete(folderKey),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            // child: Container(
                            //   color: Colors.white,
                            //   child: ListTile(

                            //     leading: Icon(
                            //       isDefault ? Icons.folder_shared : Icons.folder,
                            //       color: Color(folderData['colorValue']),
                            //       size: 28,
                            //     ),
                            //     title: Row(
                            //       children: [
                            //         if (isPinned) const Icon(Icons.push_pin, size: 14, color: Colors.orange),
                            //         if (isPinned) const SizedBox(width: 5),
                            //         Text(folderData['title'], style: const TextStyle(fontSize: 17)),
                            //       ],
                            //     ),
                            //     trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            //     onTap: () => Get.to(() => FolderNoteListScreen(
                            //           folderKey: folderKey,
                            //           folderName: folderData['title'],
                            //         )),
                            //   ),
                            // ),
                            child: Container(
                              color: Theme.of(context).cardColor,
                              child: ListTile(
                                leading: Icon(
                                  isDefault ? Icons.folder : Icons.folder,
                                  color: Color(folderData['colorValue']),
                                  size: 28,
                                ),
                                title: Row(
                                  children: [
                                    if (isPinned) const SizedBox(width: 5),
                                    Text(folderData['title'],
                                        style: TextStyle(
                                          fontSize: context.isPhone ? 18 : 20,
                                        )),
                                    if (isPinned) Icon(Icons.push_pin, size: context.isPhone ? 14 : 16, color: Colors.orange),
                                  ],
                                ),
                                // --- UPDATED TRAILING SECTION ---
                                trailing: SizedBox(
                                  width: 60, // Give it enough width for the number + arrow
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // The Note Count
                                      ValueListenableBuilder(
                                        valueListenable: noteBox.listenable(),
                                        builder: (context, Box box, _) {
                                          // Count notes where folderKey matches this folder's key
                                          int noteCount = box.values.where((note) => note['folderKey'] == folderKey).length;

                                          return Text(
                                            "$noteCount",
                                            style: TextStyle(color: Colors.grey, fontSize: context.isPhone ? 16 : 18, fontFamily: 'EN-REGULAR'),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () => Get.to(() => FolderNoteListScreen(
                                      folderKey: folderKey,
                                      folderName: folderData['title'],
                                    )),
                              ),
                            )),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor().primaryColor,
        onPressed: () {
          // Find the key for "My Note" folder
          final defaultFolder = folderBox.values.firstWhere(
            (f) => f['title'] == defaultFolderName,
            orElse: () => null,
          );

          // Get the key of the default folder
          dynamic defaultKey = folderBox.keyAt(folderBox.values.toList().indexOf(defaultFolder));

          // Go straight to Create Note, tagged to "My Note"
          Get.to(() => CreateNoteScreen(folderKey: defaultKey));
        },
        child: Icon(Icons.add, size: context.isPhone ? 30 : 33, color: Colors.white),
      ),
    );
  }

  // CREATE & EDIT SHEET (iPhone Style)
  void _showFolderSheet(BuildContext context, {dynamic folderKey, dynamic existingData}) {
    TextEditingController folderController = TextEditingController(
      text: existingData != null ? existingData['title'] : "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.red, fontFamily: 'EN-ENGINEER', fontSize: 16))),
                Text(existingData == null ? "New Folder" : "Rename Folder", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'EN-ENGINEER')),
                TextButton(
                  onPressed: () {
                    String name = folderController.text.trim();
                    if (name.isNotEmpty) {
                      final data = {
                        "title": name,
                        "colorValue": existingData != null ? existingData['colorValue'] : Colors.blue.value,
                        "isPinned": existingData?['isPinned'] ?? false,
                      };

                      if (existingData != null) {
                        folderBox.put(folderKey, data);
                      } else {
                        folderBox.add(data);
                      }
                      Get.back();
                    }
                  },
                  child: Text("Save",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor().primaryColor,
                        fontFamily: 'EN-ENGINEER',
                      )),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: folderController,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF2F2F7),
                hintText: "Enter Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
