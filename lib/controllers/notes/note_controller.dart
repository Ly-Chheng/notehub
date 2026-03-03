import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void onClose() {
    _debounce?.cancel();
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
