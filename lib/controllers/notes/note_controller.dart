import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class NoteController extends GetxController {
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

  // Undo Logic
  String? undo() {
    if (undoStack.length > 1) {
      isUndoRedoAction = true;
      redoStack.add(undoStack.removeLast());
      isUndoRedoAction = false;
      return undoStack.last;
    }
    return null;
  }

  // Redo Logic
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

  Future<void> shareNote({
    required String title,
    required String content,
    required List<File> selectedImages,
  }) async {
    final String shareTitle = title.isEmpty ? "Untitled Note" : title;
    final String fullText = "$shareTitle\n\n$content";

    try {
      if (selectedImages.isNotEmpty) {
        final List<XFile> filesToShare = selectedImages.map((file) => XFile(file.path)).toList();

        await Share.shareXFiles(filesToShare, text: fullText);
      } else {
        // Share text only
        await Share.share(fullText);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not share note: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void handleAutoNumbering({
    required TextEditingController controller,
    required int lastTextLength,
    required Function(int) updateLastLength,
  }) {
    final text = controller.text;

    if (text.length > lastTextLength && text.endsWith('\n')) {
      List<String> lines = text.split('\n');

      if (lines.length > 1) {
        String previousLine = lines[lines.length - 2].trimLeft();

        RegExp regExp = RegExp(r'^(\d+)\.\s');
        Match? match = regExp.firstMatch(previousLine);

        if (match != null) {
          int lastNumber = int.parse(match.group(1)!);
          _insertText(controller, "${lastNumber + 1}. ");
        } else if (previousLine.startsWith('•')) {
          _insertText(controller, "• ");
        } else if (previousLine.startsWith('-')) {
          _insertText(controller, "- ");
        }
      }
    }

    updateLastLength(text.length);
  }

  void _insertText(TextEditingController controller, String insertion) {
    controller.text = controller.text + insertion;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  Future<void> deleteNote({
    required dynamic noteKey,
    required List<File> images,
    VoidCallback? onSuccess,
  }) async {
    try {
      // 1. Clean up local files (Images/Drawings) to save storage
      for (var file in images) {
        if (await file.exists()) {
          await file.delete();
        }
      }

      // 2. Remove entry from Hive
      final noteBox = Hive.box('student_notes');
      await noteBox.delete(noteKey);

      // 3. Execute callback (like navigation)
      if (onSuccess != null) {
        onSuccess();
      }

      Get.snackbar(
        "Deleted",
        "Note and attachments removed successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Could not delete note: $e");
    }
  }
}
