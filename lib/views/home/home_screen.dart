import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/views/create/folder_note_list_screen.dart.dart';
import 'package:project_structure/views/home/components/create_folder_component.dart';
import 'package:project_structure/widgets/custom_dialog.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Box folderBox = Hive.box('folders_box');
  final String defaultFolderName = "My Note";
  final Box settingsBox = Hive.box('settings_box');
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

  //   LOGIC BLOCK: CLEAN UP NOTES WHEN FOLDER IS DELETED
  void _deleteNotesInFolder(dynamic folderKey) {
    final notesToDelete = noteBox.toMap().entries.where((entry) => entry.value['folderKey'] == folderKey).map((entry) => entry.key).toList();

    for (var key in notesToDelete) {
      noteBox.delete(key);
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
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (c) => showFolderSheet(context, folderKey: folderKey, existingData: folderData),
                                  backgroundColor: Colors.blue,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                ),
                                SlidableAction(
                                  onPressed: (c) {
                                    // Check if folder contains locked notes
                                    bool hasLockedNotes = noteBox.values.any((n) => n['folderKey'] == folderKey && (n['isLocked'] ?? false));

                                    _verifyAndExecute(
                                      isLocked: hasLockedNotes,
                                      title: "Delete Protected Folder",
                                      onVerified: () {
                                        folderBox.delete(folderKey);
                                        _deleteNotesInFolder(folderKey);
                                      },
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
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
                                //   UPDATED TRAILING SECTION
                                trailing: SizedBox(
                                  width: 60,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // The Note Count
                                      ValueListenableBuilder(
                                        valueListenable: noteBox.listenable(),
                                        builder: (context, Box box, _) {
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

  void _verifyAndExecute({required bool isLocked, required VoidCallback onVerified, String title = "Security Check"}) {
    if (!isLocked) {
      onVerified();
      return;
    }

    final TextEditingController passController = TextEditingController();
    String? masterPassword = settingsBox.get('master_password');

    showConfirmDialog(
      context: context,
      title: title,
      subTitle: "Please enter your password to proceed.",
      confirmText: "Unlock",
      controller: passController,
      obscureText: true,
      hintText: "Master Password",
      onConfirm: () {
        if (passController.text == masterPassword) {
          Get.back();
          onVerified();
        } else {
          Get.snackbar("Error", "Incorrect Password", backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }
}
