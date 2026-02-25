import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:share_plus/share_plus.dart';

class NoteController extends GetxController {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  var history = <String>[].obs;
  var redoStack = <String>[].obs;
  var isPinned = false.obs;
  var selectedGridType = 'none'.obs;

  bool _isActionInProgress = false;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    history.add("");
    contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_isActionInProgress) return;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final currentText = contentController.text;
      if (history.isEmpty || currentText != history.last) {
        history.add(currentText);
        redoStack.clear();
      }
    });
  }

  void undo() {
    if (history.length > 1) {
      _isActionInProgress = true;
      redoStack.add(history.removeLast());
      contentController.text = history.last;
      _moveCursorToEnd();
      _isActionInProgress = false;
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      _isActionInProgress = true;
      final String nextText = redoStack.removeLast();
      history.add(nextText);
      contentController.text = nextText;
      _moveCursorToEnd();
      _isActionInProgress = false;
    }
  }

  void _moveCursorToEnd() {
    contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: contentController.text.length),
    );
  }

  void deleteNote() {
    // Add your database/list deletion logic here
    Get.back(); // Go back to previous screen after delete
  }

  // --- SHARE LOGIC ---
  // void shareNote() {
  //   final String text = "${titleController.text}\n\n${contentController.text}".trim();
  //   if (text.isNotEmpty) {
  //     Share.share(text, subject: titleController.text);
  //   } else {
  //     Get.snackbar("Note Empty", "Write something to share it!", snackPosition: SnackPosition.BOTTOM);
  //   }
  // }

  void shareNote(String title, String content) {
    // You would typically use the 'share_plus' package here
    print("Sharing: $title - $content");
  }

  void togglePin() {
    isPinned.value = !isPinned.value;
    Get.snackbar("Note", isPinned.value ? "Note Pinned" : "Note Unpinned",
        snackPosition: SnackPosition.BOTTOM,
        titleText: Text("Note", style: TextStyle(fontFamily: 'KH-Bold', fontWeight: FontWeight.bold, color: AppColor().primaryColor,fontSize: 18)),
        messageText: Text(isPinned.value ? "Note Pinned" : "Note Unpinned", style: TextStyle(fontFamily: 'KH-REGULAR', color: AppColor().primaryColor,fontSize: 16)));
  }

  void updateGrid(String type) => selectedGridType.value = type;

  @override
  void onClose() {
    _debounce?.cancel();
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
