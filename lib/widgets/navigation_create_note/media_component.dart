import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/multi_style.dart';

void showMediaSheet({
  required BuildContext context,
  required Function(File mediaFile, String type) onMediaSelected,
}) {
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (file != null && context.mounted) {
        onMediaSelected(File(file.path), 'image');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> pickVideo(ImageSource source) async {
    try {
      final XFile? file = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (file != null && context.mounted) {
        onMediaSelected(File(file.path), 'video');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'zip',
          'rar',
        ],
      );

      if (result != null && result.files.single.path != null && context.mounted) {
        final file = File(result.files.single.path!);

        onMediaSelected(file, 'file');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(
              title: "add_media".tr,
            ),
            const SizedBox(height: 15),
            buildActionItem(
              context,
              icon: Icons.camera_alt_outlined,
              color: AppColor().primaryColor,
              title: "take_photo".tr,
              onTap: () => pickImage(ImageSource.camera),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.image_outlined,
              color: AppColor().primaryColor,
              title: "gallery_image".tr,
              onTap: () => pickImage(ImageSource.gallery),
            ),
            divider(context),
            const SizedBox(height: 5),
            // buildActionItem(
            //   context,
            //   icon: Icons.videocam_outlined,
            //   color: AppColor().primaryColor,
            //   title: "Record a Video",
            //   onTap: () => pickVideo(ImageSource.camera),
            // ),
            // divider(context),
            buildActionItem(
              context,
              icon: Icons.video_library_outlined,
              color: AppColor().primaryColor,
              title: "gallery_video".tr,
              onTap: () => pickVideo(ImageSource.gallery),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.attach_file_outlined,
              color: AppColor().primaryColor,
              title: "attach_file".tr,
              onTap: pickFile,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
