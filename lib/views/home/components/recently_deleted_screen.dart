import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/controllers/home/home_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/sheet_header.dart';

class RecentlyDeletedScreen extends StatelessWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Obx(() => Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: customAppBar(
            title: "Recently Deleted",
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
                onSelected: (value) {
                  if (value == 'select') {
                    controller.toggleSelectionMode();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'select',
                    child: Row(
                      children: [
                        Icon(
                          controller.isSelectionMode.value ? Icons.check_circle_sharp : Icons.radio_button_unchecked,
                          color: AppColor().primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Text(controller.isSelectionMode.value ? 'Cancel Selection' : 'Select Notes'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ValueListenableBuilder(
            valueListenable: controller.trashBox.listenable(),
            builder: (context, Box box, _) {
              if (box.isEmpty) {
                return CustomNoData(
                  message: "No recently deleted notes",
                );
              }

              final entries = box.toMap().entries.toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final key = entries[index].key;
                  final data = entries[index].value;
                  final isSelected = controller.selectedKeys.contains(key);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Slidable(
                      key: ValueKey(key),
                      enabled: !controller.isSelectionMode.value,
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.5,
                        children: [
                          // SlidableAction(
                          //   onPressed: (context) => controller.restoreNote(key, data),
                          //   backgroundColor: Colors.green,
                          //   foregroundColor: Colors.white,
                          //   icon: Icons.restore,
                          //   label: 'Restore',
                          //   borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          // ),
                          SlidableAction(
                            onPressed: (context) => _showFolderPicker(context, controller, noteKey: key),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.folder,
                            label: 'Move',
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          ),
                          SlidableAction(
                            onPressed: (context) => controller.permanentDelete(key),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected ? BorderSide(color: AppColor().primaryColor, width: 1.5) : BorderSide.none,
                        ),
                        child: ListTile(
                          onTap: () {
                            if (controller.isSelectionMode.value) {
                              controller.toggleSelection(key);
                            }
                          },
                          leading: controller.isSelectionMode.value
                              ? Icon(
                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: AppColor().primaryColor,
                                )
                              : null,
                          title: Text(
                            data['title'] ?? "Untitled Note",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: context.isPhone ? 18 : 20,
                              fontFamily: 'EN-BOLD',
                            ),
                          ),
                          subtitle: Text(
                            data['deletedAt'] != null ? DateFormat('MM-dd-yyyy / hh:mm a').format(DateTime.parse(data['deletedAt'])) : "Unknown",
                            style: TextStyle(
                              fontSize: context.isPhone ? 14 : 16,
                              fontFamily: 'EN-REGULAR',
                              color: Colors.grey[600],
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
          bottomNavigationBar: controller.isSelectionMode.value
              ? BottomAppBar(
                  elevation: 8,
                  color: Theme.of(context).cardColor,
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // IconButton(
                        //   icon: const Icon(Icons.restore_page, color: Colors.green, size: 28),
                        //   onPressed: controller.selectedKeys.isEmpty ? null : () => controller.restoreSelected(),
                        // ),
                        IconButton(
                          icon: Icon(Icons.folder, color: AppColor().primaryColor, size: 28),
                          onPressed: controller.selectedKeys.isEmpty ? null : () => _showFolderPicker(context, controller),
                        ),
                        const Spacer(),
                        Text(
                          "${controller.selectedKeys.length} selected",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'EN-BOLD',
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                          onPressed: controller.selectedKeys.isEmpty ? null : () => controller.deleteSelectedPermanently(context),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ));
  }

  void _showFolderPicker(BuildContext context, HomeController controller, {dynamic noteKey}) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHeader(title: "Move to Folder"),
            const SizedBox(height: 15),
            Flexible(
              child: ValueListenableBuilder(
                valueListenable: controller.folderBox.listenable(),
                builder: (context, Box box, _) {
                  final folders = box.toMap().entries.toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folderKey = folders[index].key;
                      final folderData = folders[index].value;

                      return ListTile(
                        leading: Icon(Icons.folder, color: Color(folderData['colorValue'])),
                        title: Text(folderData['title']),
                        onTap: () {
                          if (noteKey != null) {
                            // If we swiped a single note
                            controller.moveSingleNoteToFolder(noteKey, folderKey);
                          } else {
                            // If we are in Selection Mode
                            controller.moveSelectedToFolder(folderKey);
                          }
                        },
                      );
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
