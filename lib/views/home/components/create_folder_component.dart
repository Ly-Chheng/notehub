import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/models/folder_model.dart';

void showCreateFolderSheet(BuildContext context) {
  TextEditingController folderController = TextEditingController();
  final Box<Folder> folderBox = Hive.box<Folder>('folders_box');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text("Cancel",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: context.isPhone ? 16 : 18,
                        fontFamily: 'EN-REGULAR',
                      )),
                ),
                Text("Create Folder",
                    style: TextStyle(
                      fontSize: context.isPhone ? 16 : 18,
                      fontFamily: 'EN-BOLD',
                    )),
                TextButton(
                  onPressed: () {
                    if (folderController.text.trim().isNotEmpty) {
                      // SAVE TO HIVE
                      final newFolder = Folder(
                        title: folderController.text.trim(),
                        colorValue: Colors.blue.value,
                      );
                      folderBox.add(newFolder);
                      Get.back();
                    }
                  },
                  child: Text("Done",
                      style: TextStyle(
                        color: AppColor().primaryColor,
                        fontSize: context.isPhone ? 16 : 18,
                        fontFamily: 'EN-REGULAR',
                      )),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E9EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: folderController,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: "Folder Name",
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: context.isPhone ? 16 : 18,
                      fontFamily: 'EN-REGULAR',
                    )),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
