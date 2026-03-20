import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class NoteController extends GetxController {
  final Box noteBox = Hive.box('student_notes');
  final Box trashBox = Hive.box('recently_deleted');

  var undoStack = <String>[].obs;
  var redoStack = <String>[].obs;
  bool isUndoRedoAction = false;

  void initializeHistory(String initialText) {
    undoStack.clear();
    redoStack.clear();
    undoStack.add(initialText);
  }

  void recordChange(String text) {
    if (isUndoRedoAction) return;

    if (undoStack.isEmpty || undoStack.last != text) {
      if (undoStack.length > 50) undoStack.removeAt(0);
      undoStack.add(text);
      redoStack.clear();
    }
  }

  String? undo() {
    if (undoStack.length > 1) {
      isUndoRedoAction = true;
      redoStack.add(undoStack.removeLast());
      isUndoRedoAction = false;
      return undoStack.last;
    }
    return null;
  }

  String? redo() {
    if (redoStack.isNotEmpty) {
      isUndoRedoAction = true;
      String redoneText = redoStack.removeLast();
      undoStack.add(redoneText);
      isUndoRedoAction = false;
      return redoneText;
    }
    return null;
  }

  // Future<void> shareNote({
  //   required String title,
  //   required String content,
  //   required List<File> selectedImages,
  // }) async {
  //   final String shareTitle = title.trim().isEmpty ? "Untitled Note" : title.trim();

  //   final String shareContent = content.trim().isEmpty ? "(No content)" : content.trim();

  //   final String fullText = "$shareTitle\n\n$shareContent";

  //   try {
  //     if (selectedImages.isNotEmpty) {
  //       final files = selectedImages.where((file) => file.existsSync()).map((file) => XFile(file.path)).toList();

  //       if (files.isNotEmpty) {
  //         await Share.shareXFiles(files, text: fullText);
  //       } else {
  //         await Share.share(fullText);
  //       }
  //     } else {
  //       await Share.share(fullText);
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       "Error",
  //       "Could not share note",
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   }
  // }

  Future<void> shareNote({
    required String title,
    required String content,
    required List<File> selectedImages,
  }) async {
    final String shareTitle = title.trim().isEmpty ? "Untitled Note" : title.trim();
    final String shareContent = content.trim().isEmpty ? "(No content)" : content.trim();
    final String fullText = "$shareTitle\n\n$shareContent";

    try {
      List<XFile> files = selectedImages.where((file) => file.existsSync()).map((file) => XFile(file.path)).toList();

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/note_content.txt');
      await tempFile.writeAsString(fullText);
      files.add(XFile(tempFile.path));

      if (files.isNotEmpty) {
        await Share.shareXFiles(files);
      } else {
        await Share.share(fullText);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not share note",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteNote({
    required dynamic noteKey,
    required Map? noteData,
    VoidCallback? onSuccess,
  }) async {
    try {
      final noteBox = Hive.box('student_notes');
      final trashBox = Hive.box('recently_deleted');

      if (noteKey != null && noteData != null) {
        // Prepare data for Trash (Add the deleted timestamp)
        final Map<String, dynamic> deletedData = Map<String, dynamic>.from(noteData);
        deletedData['deletedAt'] = DateTime.now().toIso8601String();

        await trashBox.put(noteKey, deletedData);

        await noteBox.delete(noteKey);
      }

      if (onSuccess != null) onSuccess();
    } catch (e) {
      Get.snackbar("Error", "Could not move to trash: $e");
    }
  }
}
