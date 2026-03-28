import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:project_structure/controllers/home/home_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/views/create/folder_note_list_screen.dart.dart';
import 'package:project_structure/views/home/components/create_folder_component.dart';
import 'package:project_structure/views/home/components/recently_deleted_screen.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/widgets/custom_header.dart';
import 'package:project_structure/widgets/custom_list_folder.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    controller.ensureDefaultFolder();
    controller.listenToScroll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: customHeader("Folders"),
            ),
            Expanded(
              child: SlidableAutoCloseBehavior(
                closeWhenOpened: true,
                child: ValueListenableBuilder(
                  valueListenable: controller.folderBox.listenable(),
                  builder: (context, Box box, _) {
                    final folders = controller.getSortedFolders(box.toMap().entries.toList());

                    return ListView.builder(
                      controller: controller.scrollController,
                      itemCount: folders.length + 1,
                      itemBuilder: (context, index) {
                        if (index == folders.length) {
                          return ValueListenableBuilder(
                            valueListenable: controller.trashBox.listenable(),
                            builder: (context, Box tBox, _) {
                              if (tBox.isEmpty) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    color: Theme.of(context).cardColor,
                                    child: CustomListFolder(
                                      title: "Recently Deleted",
                                      icon: Icons.delete,
                                      iconColor: Colors.red,
                                      listenable: controller.trashBox.listenable(),
                                      onTap: () => Get.to(() => const RecentlyDeletedScreen()),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        // Regular Folder Item
                        final folderKey = folders[index].key;
                        final folderData = folders[index].value;
                        bool isDefault = folderData['title'] == controller.defaultFolderName;
                        bool isPinned = folderData['isPinned'] ?? false;
                        bool isLocked = folderData['isLocked'] ?? false;

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: context.isPhone ? 8 : 12,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Slidable(
                              enabled: !isDefault,
                              startActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (c) => controller.togglePin(folderKey, folderData),
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    icon: isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                                    label: isPinned ? 'Unpin' : 'Pin',
                                  ),
                                  SlidableAction(
                                    onPressed: (context) {
                                      String? masterPass = controller.settingsBox.get('master_password');

                                      if (masterPass == null || masterPass.isEmpty) {
                                        Get.to(() => const CreatePasswordScreen());
                                        return;
                                      }

                                      controller.verifyAndExecute(
                                        context: context,
                                        isLocked: isLocked,
                                        title: isLocked ? "Unlock Folder" : "Lock Folder",
                                        onVerified: () => controller.toggleFolderLock(folderKey, folderData),
                                      );
                                    },
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    icon: isLocked ? Icons.lock_open : Icons.lock,
                                    label: isLocked ? 'Unlock' : 'Lock',
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (c) => showFolderSheet(context, folderKey: folderKey, existingData: folderData),
                                    backgroundColor: AppColor().primaryColor,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                  ),
                                  SlidableAction(
                                    onPressed: (c) {
                                      bool hasLockedNotes = controller.noteBox.values.any((n) => n['folderKey'] == folderKey && (n['isLocked'] ?? false));

                                      controller.verifyAndExecute(
                                        context: context,
                                        isLocked: hasLockedNotes || isLocked,
                                        title: "Delete Protected Folder",
                                        onVerified: () => controller.deleteFolder(folderKey),
                                      );
                                    },
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: Container(
                                color: Theme.of(context).cardColor,
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    context.isPhone ? 2 : 8,
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.folder,
                                      color: Color(folderData['colorValue']),
                                      size: context.isPhone ? 30 : 35,
                                    ),
                                    title: Row(
                                      children: [
                                        if (isLocked)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: context.isPhone ? 6 : 10,
                                            ),
                                            child: Icon(Icons.lock, size: 17, color: AppColor().primaryColor),
                                          ),
                                        Expanded(
                                            child: Text(
                                                // folderData['title'],
                                                isLocked && folderData['title'].length > 3 ? "${folderData['title'].substring(0, 3)}..." : folderData['title'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: context.isPhone ? 18 : 20))),
                                        if (isPinned) const Icon(Icons.push_pin, size: 17, color: Colors.orange),
                                      ],
                                    ),
                                    trailing: ValueListenableBuilder(
                                      valueListenable: controller.noteBox.listenable(),
                                      builder: (context, Box nBox, _) {
                                        int count = nBox.values.where((n) => n['folderKey'] == folderKey).length;
                                        return Text("$count", style: TextStyle(color: Colors.grey, fontSize: context.isPhone ? 16 : 18, fontFamily: 'EN-REGULAR'));
                                      },
                                    ),
                                    // onTap: () => Get.to(() => FolderNoteListScreen(
                                    //       folderKey: folderKey,
                                    //       folderName: folderData['title'],
                                    //     )),
                                    onTap: () {
                                      final bool isFolderLocked = folderData['isLocked'] ?? false;

                                      controller.verifyAndExecute(
                                        context: context,
                                        isLocked: isFolderLocked,
                                        title: "Locked Folder",
                                        onVerified: () {
                                          Get.to(() => FolderNoteListScreen(
                                                folderKey: folderKey,
                                                folderName: folderData['title'],
                                              ));
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        //   floatingActionButton: FloatingActionButton(
        //     backgroundColor: AppColor().primaryColor,
        //     onPressed: () {
        //       final defaultKey = controller.getDefaultFolderKey();
        //       Get.to(() => CreateNoteScreen(folderKey: defaultKey));
        //     },
        //     child: Icon(
        //       Icons.add,
        //       color: Colors.white,
        //       size: context.isPhone ? 30 : 35,
        //     ),
        //   ),
        // );
        floatingActionButton: Obx(() => AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: controller.isFabVisible.value ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: controller.isFabVisible.value ? 1 : 0,
                child: FloatingActionButton(
                  backgroundColor: AppColor().primaryColor,
                  onPressed: () {
                    final defaultKey = controller.getDefaultFolderKey();
                    Get.to(() => CreateNoteScreen(folderKey: defaultKey));
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: context.isPhone ? 30 : 35,
                  ),
                ),
              ),
            )));
  }
}
