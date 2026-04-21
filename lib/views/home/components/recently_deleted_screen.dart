import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
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

  String _getPlainTextFromNote(String? subtitleJson) {
    if (subtitleJson == null || subtitleJson.isEmpty) return "";

    try {
      final document = quill.Document.fromJson(jsonDecode(subtitleJson));
      return document.toPlainText().trim();
    } catch (e) {
      return subtitleJson;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Obx(() => PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              controller.isSelectionMode.value = false;
              controller.selectedKeys.clear();
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: customAppBar(
              title: "Recently Deleted",
              titleColor: AppColor().primaryColor,
              context: context,
              leadingColor: AppColor().primaryColor,
              actions: [
                ValueListenableBuilder(
                  valueListenable: controller.trashBox.listenable(),
                  builder: (context, Box box, _) {
                    if (box.isEmpty) return const SizedBox.shrink();

                    return PopupMenuButton<String>(
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
                    );
                  },
                ),
              ],
            ),
            body: SlidableAutoCloseBehavior(
              closeWhenOpened: true,
              child: ValueListenableBuilder(
                valueListenable: controller.trashBox.listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return CustomNoData(
                      message: "No recently deleted notes",
                    );
                  }

                  final entries = box.toMap().entries.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final key = entries[index].key;
                      final data = entries[index].value;
                      final isSelected = controller.selectedKeys.contains(key);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Slidable(
                          key: ValueKey(key),
                          enabled: !controller.isSelectionMode.value,
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.5,
                            children: [
                              SlidableAction(
                                onPressed: (context) => _showFolderPicker(context, controller, noteKey: key),
                                backgroundColor: AppColor().primaryColor,
                                foregroundColor: AppColor().white,
                                icon: Icons.folder,
                                label: 'Move',
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                              ),
                              SlidableAction(
                                onPressed: (context) {
                                  controller.deleteWapDialog(context, {key});
                                },
                                backgroundColor: AppColor().red,
                                foregroundColor: AppColor().white,
                                icon: Icons.delete,
                                label: 'Delete',
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(12),
                                ),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (controller.isSelectionMode.value) {
                                controller.toggleSelection(key);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: AppColor().primaryColor, width: 1) : null,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (controller.isSelectionMode.value)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(
                                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                        color: AppColor().primaryColor,
                                      ),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (data['title'] != null && data['title'].toString().trim().isNotEmpty) ? data['title'] : _getPlainTextFromNote(data['subtitle']),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'EN-REGULAR',
                                            fontFamilyFallback: ['KH-REGULAR'],
                                            fontSize: context.isPhone ? 16 : 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          data['deletedAt'] != null ? DateFormat('MM-dd-yyyy / hh:mm a').format(DateTime.parse(data['deletedAt'])) : "Unknown",
                                          style: TextStyle(
                                            fontFamily: 'EN-REGULAR',
                                            fontSize: context.isPhone ? 14 : 16,
                                            color: Colors.grey[600],
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
                    },
                  );
                },
              ),
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
                          IconButton(
                            icon: Icon(Icons.folder, color: AppColor().primaryColor, size: 28),
                            onPressed: controller.selectedKeys.isEmpty ? null : () => _showFolderPicker(context, controller),
                          ),
                          const Spacer(),
                          Text(
                            "${controller.selectedKeys.length} selected",
                            style: TextStyle(
                              fontSize: context.isPhone ? 14 : 16,
                              fontFamily: 'EN-REGULAR',
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.delete, color: AppColor().red, size: 28),
                            onPressed: controller.selectedKeys.isEmpty ? null : () => controller.deleteSelectedPermanently(context),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
        ));
  }

  void _showFolderPicker(BuildContext context, HomeController controller, {dynamic noteKey}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: double.infinity),
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Container(
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
                          leading: Icon(
                            Icons.folder,
                            color: AppColor().primaryColor,
                          ),
                          title: Text(
                            folderData['title'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            if (noteKey != null) {
                              controller.moveSingleNoteToFolder(noteKey, folderKey);
                            } else {
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
      ),
    );
    // Get.bottomSheet(
    //   Container(
    //     decoration: BoxDecoration(
    //       color: Theme.of(context).cardColor,
    //       borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    //     ),
    //     padding: const EdgeInsets.all(20),
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         const SheetHeader(title: "Move to Folder"),
    //         const SizedBox(height: 15),
    //         Flexible(
    //           child: ValueListenableBuilder(
    //             valueListenable: controller.folderBox.listenable(),
    //             builder: (context, Box box, _) {
    //               final folders = box.toMap().entries.toList();
    //               return ListView.builder(
    //                 shrinkWrap: true,
    //                 itemCount: folders.length,
    //                 itemBuilder: (context, index) {
    //                   final folderKey = folders[index].key;
    //                   final folderData = folders[index].value;
    //                   return ListTile(
    //                     leading: Icon(
    //                       Icons.folder,
    //                       color: AppColor().primaryColor,
    //                     ),
    //                     title: Text(
    //                       folderData['title'],
    //                       maxLines: 1,
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                     onTap: () {
    //                       if (noteKey != null) {
    //                         controller.moveSingleNoteToFolder(noteKey, folderKey);
    //                       } else {
    //                         controller.moveSelectedToFolder(folderKey);
    //                       }
    //                     },
    //                   );
    //                 },
    //               );
    //             },
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
