import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/multi_style.dart';

void showMediaSheet({
  required BuildContext context,
  required Function(File mediaFile, String type) onMediaSelected,
  Function(String text)? onTextScanned,
}) {
  final ImagePicker picker = ImagePicker();

  Future<void> scanText() async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    // Pick the image first
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    Get.back();
    if (file == null) return;

    Get.dialog(
      Center(
          child: CircularProgressIndicator(
        color: AppColor().primaryColor,
      )),
      barrierDismissible: false,
    );

    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      if (Get.isDialogOpen ?? false) Get.back();

      if (recognizedText.text.isNotEmpty && context.mounted) {
        // ONLY call the text scanner, skip onMediaSelected to avoid adding the image
        onTextScanned?.call(recognizedText.text);

        // Navigator.pop(context);
      } else {
        AppSnackbar.showError(
          title: "error".tr,
          message: "no_text_detected_in_the_image".tr,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("Error scanning text: $e");
    } finally {
      textRecognizer.close();
    }
  }

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
              icon: Icons.note_outlined,
              color: AppColor().primaryColor,
              title: "attach_file".tr,
              onTap: pickFile,
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.document_scanner_outlined,
              color: AppColor().primaryColor,
              title: "scan_text".tr,
              onTap: scanText,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
