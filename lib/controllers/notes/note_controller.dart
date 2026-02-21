import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteController extends GetxController {
  // Text Editing Controllers
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  // History management using RxLists for Obx reactivity
  var history = <String>[].obs;
  var redoStack = <String>[].obs;
  
  // Internal flags and timers
  bool _isActionInProgress = false;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // Initialize history with an empty string
    history.add("");
    
    // Listen to content changes
    contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // If the change came from an Undo/Redo button, don't record it again
    if (_isActionInProgress) return;

    // Debounce: Wait 500ms after the user stops typing to save history
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final currentText = contentController.text;
      
      // Only save if the text is different from the last saved state
      if (history.isEmpty || currentText != history.last) {
        history.add(currentText);
        redoStack.clear(); // New typing invalidates redo history
        
        // Keep history size optimized (e.g., last 50 steps)
        if (history.length > 50) {
          history.removeAt(0);
        }
      }
    });
  }

  // --- Public Undo Action ---
  void undo() {
    if (history.length > 1) {
      _isActionInProgress = true;
      
      // Move current state to redo stack
      redoStack.add(history.removeLast());
      
      // Set text to the previous state in history
      contentController.text = history.last;
      
      _moveCursorToEnd();
      _isActionInProgress = false;
    }
  }

  // --- Public Redo Action ---
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

  // --- Helper: Ensure cursor stays at the end of text ---
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