import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/app_snack_bar.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MediaController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final SpeechToText _speech = SpeechToText();

  /// Exposes the speech engine instance safely
  SpeechToText get speechEngine => _speech;

  /// Picks an image
  Future<void> pickImage({
    required ImageSource source,
    required Function(File, String) onResult,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (file != null) {
        onResult(File(file.path), 'image');
        Get.back();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  /// Picks a video
  Future<void> pickVideo({
    required ImageSource source,
    required Function(File, String) onResult,
  }) async {
    try {
      final XFile? file = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (file != null) {
        onResult(File(file.path), 'video');
        Get.back();
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  /// Picks a document
  Future<void> pickFile({
    required Function(File, String) onResult,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip', 'rar'],
      );
      if (result != null && result.files.single.path != null) {
        onResult(File(result.files.single.path!), 'file');
        Get.back();
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  /// Scans text OCR
  Future<void> scanText({
    required BuildContext context,
    required Function(String) onTextScanned,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);

      if (Get.isBottomSheetOpen ?? false) Get.back();

      if (file == null) return;

      Get.dialog(
        Center(child: CircularProgressIndicator(color: AppColor().primaryColor)),
        barrierDismissible: false,
      );

      final inputImage = InputImage.fromFilePath(file.path);

      // Multiple text recognizers for cross-language compatibility
      final recognizers = [
        TextRecognizer(script: TextRecognitionScript.korean),
        TextRecognizer(script: TextRecognitionScript.chinese),
        TextRecognizer(script: TextRecognitionScript.japanese),
        TextRecognizer(script: TextRecognitionScript.latin),
      ];

      String bestText = "";

      for (final recognizer in recognizers) {
        final result = await recognizer.processImage(inputImage);

        if (result.text.length > bestText.length) {
          bestText = result.text;
        }
        await recognizer.close();
      }

      // Dismiss processing dialog loader
      if (Get.isDialogOpen ?? false) Get.back();

      debugPrint("Final OCR Result: $bestText");

      if (bestText.trim().isNotEmpty && context.mounted) {
        onTextScanned(bestText);
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
  // Future<void> scanText() async {
  //   final XFile? file = await picker.pickImage(source: ImageSource.camera);
  //   Get.back();
  //   if (file == null) return;

  //   Get.dialog(
  //     Center(child: CircularProgressIndicator(color: AppColor().primaryColor)),
  //     barrierDismissible: false,
  //   );

  //   try {
  //     final inputImage = InputImage.fromFilePath(file.path);

  //     // Multiple recognizers
  //     final recognizers = [
  //       TextRecognizer(script: TextRecognitionScript.korean),
  //       TextRecognizer(script: TextRecognitionScript.chinese),
  //       TextRecognizer(script: TextRecognitionScript.japanese),
  //       TextRecognizer(script: TextRecognitionScript.latin),
  //     ];

  //     String bestText = "";

  //     for (final recognizer in recognizers) {
  //       final result = await recognizer.processImage(inputImage);

  //       // debugPrint(
  //       //   "Detected (${recognizer.script.name}): ${result.text}",
  //       // );

  //       if (result.text.length > bestText.length) {
  //         bestText = result.text;
  //       }

  //       await recognizer.close();
  //     }

  //     if (Get.isDialogOpen ?? false) Get.back();

  //     debugPrint("Final OCR Result: $bestText");

  //     if (bestText.trim().isNotEmpty && context.mounted) {
  //       onTextScanned?.call(bestText);
  //     } else {
  //       AppSnackbar.showError(
  //         title: "error".tr,
  //         message: "no_text_detected_in_the_image".tr,
  //       );
  //     }
  //   } catch (e) {
  //     if (Get.isDialogOpen ?? false) Get.back();
  //     debugPrint("OCR Error: $e");
  //   }
  // }

  /// Initializes Speech Recognition engine and launches the customized UI window
  Future<void> startVoiceScan({
    required Function(String) onResult,
    required Widget Function(SpeechToText speechEngine) dialogBuilder,
  }) async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );

      if (available) {
        Get.back();

        Get.dialog(
          dialogBuilder(_speech),
          barrierDismissible: false,
        );
      } else {
        AppSnackbar.showError(title: "error".tr, message: "speech_not_available".tr);
      }
    } catch (e) {
      debugPrint("Speech Initialization Error: $e");
      AppSnackbar.showError(title: "error".tr, message: "speech_not_available".tr);
    }
  }
}
