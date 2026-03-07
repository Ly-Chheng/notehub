import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class NoteController extends GetxController {
  // Observable stacks for Undo/Redo
  var undoStack = <String>[].obs;
  var redoStack = <String>[].obs;
  bool isUndoRedoAction = false;

  // Initialize the stack with the starting text
  void initializeHistory(String initialText) {
    undoStack.clear();
    redoStack.clear();
    undoStack.add(initialText);
  }

  // Record a new state
  void recordChange(String text) {
    if (isUndoRedoAction) return;

    // Only record if the text is different from the last snapshot
    if (undoStack.isEmpty || undoStack.last != text) {
      if (undoStack.length > 50) undoStack.removeAt(0); // Limit memory
      undoStack.add(text);
      redoStack.clear(); // New manual typing clears the Redo path
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
        // Map File paths to XFile for the share_plus package
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
}

// contentController.addListener(() {
//   noteController.handleAutoNumbering(
//     controller: contentController,
//     lastTextLength: _lastTextLength,
//     updateLastLength: (value) => _lastTextLength = value,
//   );
// });
