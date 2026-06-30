import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_structure/controllers/notes/media_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_menu_item.dart.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_sheet_header.dart';
import 'package:speech_to_text/speech_to_text.dart';

void showMediaSheet({
  required BuildContext context,
  required Function(File mediaFile, String type) onMediaSelected,
  Function(String text)? onTextScanned,
}) {
  final ImagePicker picker = ImagePicker();
  final MediaController controller = Get.put(MediaController());

  final themeColor = Theme.of(context).cardColor;

  Future<void> scanText() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    Get.back();
    if (file == null) return;

    Get.dialog(
      Center(child: CircularProgressIndicator(color: AppColor().primaryColor)),
      barrierDismissible: false,
    );

    try {
      final inputImage = InputImage.fromFilePath(file.path);

      // Multiple recognizers
      final recognizers = [
        TextRecognizer(script: TextRecognitionScript.korean),
        TextRecognizer(script: TextRecognitionScript.chinese),
        TextRecognizer(script: TextRecognitionScript.japanese),
        TextRecognizer(script: TextRecognitionScript.latin),
      ];

      String bestText = "";

      for (final recognizer in recognizers) {
        final result = await recognizer.processImage(inputImage);

        // debugPrint(
        //   "Detected (${recognizer.script.name}): ${result.text}",
        // );

        if (result.text.length > bestText.length) {
          bestText = result.text;
        }

        await recognizer.close();
      }

      if (Get.isDialogOpen ?? false) Get.back();

      debugPrint("Final OCR Result: $bestText");

      if (bestText.trim().isNotEmpty && context.mounted) {
        onTextScanned?.call(bestText);
      } else {
        AppSnackbar.showError(
          title: "error".tr,
          message: "no_text_detected_in_the_image".tr,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("OCR Error: $e");
    }
  }

  Future<void> scanVoice(Function(String) onResult) async {
    final SpeechToText speech = SpeechToText();

    // Initialize
    bool available = await speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );
    if (available) {
      Get.back();
      speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            if (Get.isDialogOpen == true) {
              Get.back();
            }
            onResult(result.recognizedWords);
          }
        },
      );

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: themeColor,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              final controller = AnimationController(
                vsync: Navigator.of(context),
                duration: const Duration(milliseconds: 1000),
              )..repeat(reverse: true);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 0.9, end: 1.1).animate(
                        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor().red.withValues(alpha: 0.1),
                        ),
                        child: Icon(Icons.mic_rounded, size: 64, color: AppColor().red),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("listening".tr, style: text18(context)),
                    const SizedBox(height: 10),
                    Text("speak_now".tr, style: text14(context)),
                  ],
                ),
              );
            },
          ),
        ),
        barrierDismissible: true,
      ).then((_) {
        speech.stop();
      });
    } else {
      AppSnackbar.showError(title: "error".tr, message: "speech_not_available".tr);
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
              onTap: () => controller.pickImage(source: ImageSource.camera, onResult: onMediaSelected),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.image_outlined,
              color: AppColor().primaryColor,
              title: "gallery_image".tr,
              onTap: () => controller.pickImage(source: ImageSource.gallery, onResult: onMediaSelected),
            ),
            divider(context),
            const SizedBox(height: 5),
            buildActionItem(
              context,
              icon: Icons.video_library_outlined,
              color: AppColor().primaryColor,
              title: "gallery_video".tr,
              onTap: () => controller.pickVideo(source: ImageSource.gallery, onResult: onMediaSelected),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.note_outlined,
              color: AppColor().primaryColor,
              title: "attach_file".tr,
              onTap: () => controller.pickFile(onResult: onMediaSelected),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.document_scanner_outlined,
              color: AppColor().primaryColor,
              title: "scan_text".tr,
              onTap: scanText,
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.mic_none,
              color: AppColor().primaryColor,
              title: "voice_note".tr,
              onTap: () => scanVoice((text) {
                if (onTextScanned != null) {
                  onTextScanned(text);
                }
              }),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}

Widget divider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(
      height: 1,
      color: Colors.grey.withValues(alpha: 0.08),
    ),
  );
}
