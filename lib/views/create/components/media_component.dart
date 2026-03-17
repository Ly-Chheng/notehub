import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/sheet_header.dart';

void showMediaSheet({
  required BuildContext context,
  required Function(File image) onImageSelected,
}) {
  final ImagePicker picker = ImagePicker();

  Future<void> pick(ImageSource source) async {
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 70, 
      );

      if (file != null && context.mounted) {
        onImageSelected(File(file.path));
        Navigator.pop(context); 
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(
              title: "Add Media",
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
