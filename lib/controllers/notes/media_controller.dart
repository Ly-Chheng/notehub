import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MediaController extends GetxController {
  final ImagePicker _picker = ImagePicker();

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
}
