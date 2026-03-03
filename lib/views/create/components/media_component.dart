import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_structure/core/utils/app_color.dart';

void showMediaSheet({
  required BuildContext context,
  required Function(File image) onImageSelected,
}) {
  final ImagePicker picker = ImagePicker();

  Future<void> pick(ImageSource source) async {
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 70, // Optimize for performance
      );

      if (file != null && context.mounted) {
        onImageSelected(File(file.path));
        Navigator.pop(context); // Close sheet after picking
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                Text("Add Media",
                    style: TextStyle(
                      fontSize: context.isPhone ? 16 : 18,
                      fontFamily: 'EN-BOLD',
                    )),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: AppColor().primaryColor,
              ),
              title: Text("Take a Photo",
                  style: TextStyle(
                    fontSize: context.isPhone ? 16 : 18,
                    fontFamily: 'EN-REGULAR',
                  )),
              onTap: () => pick(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.image_outlined,
                color: AppColor().primaryColor,
              ),
              title: Text("Select from Gallery",
                  style: TextStyle(
                    fontSize: context.isPhone ? 16 : 18,
                    fontFamily: 'EN-REGULAR',
                  )),
              onTap: () => pick(ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
