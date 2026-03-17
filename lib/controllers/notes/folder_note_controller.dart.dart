import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/widgets/custom_dialog.dart';

class FolderNoteController extends GetxController {
  final dynamic folderKey;
  FolderNoteController({required this.folderKey});

  final Box noteBox = Hive.box('student_notes');
  final Box settingsBox = Hive.box('settings_box');

  // Reactive States
  var isSelectionMode = false.obs;
  var selectedKeys = <dynamic>{}.obs;
  var searchQuery = "".obs;
  var filteredNotes = <MapEntry<dynamic, dynamic>>[].obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    refreshNotes();
    // Re-filter whenever search text changes
    ever(searchQuery, (_) => refreshNotes());
  }

  // The "Source of Truth" for the UI list
  void refreshNotes() {
    List<MapEntry<dynamic, dynamic>> notes = noteBox.toMap().entries.where((entry) => entry.value['folderKey'] == folderKey).toList();

    if (searchQuery.value.isNotEmpty) {
      notes = notes.where((entry) {
        final title = (entry.value['title'] ?? "").toString().toLowerCase();
        final content = (entry.value['subtitle'] ?? "").toString().toLowerCase();
        return title.contains(searchQuery.value) || content.contains(searchQuery.value);
      }).toList();
    }

    // Sort: Pinned first, then by Date (Key) descending
    notes.sort((a, b) {
      bool aPinned = a.value['isPinned'] ?? false;
      bool bPinned = b.value['isPinned'] ?? false;
      if (aPinned != bPinned) return -1;
      if (bPinned != aPinned) return 1;
      return b.key.compareTo(a.key);
    });

    filteredNotes.assignAll(notes);
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    selectedKeys.clear();
  }

  void toggleNoteSelection(dynamic key) {
    if (selectedKeys.contains(key)) {
      selectedKeys.remove(key);
    } else {
      selectedKeys.add(key);
    }
  }

  void togglePin(dynamic noteKey, dynamic note) {
    final updated = Map<String, dynamic>.from(note);
    updated['isPinned'] = !(note['isPinned'] ?? false);
    noteBox.put(noteKey, updated);
    refreshNotes();
  }

  void deleteSelectedNotes() {
    for (var key in selectedKeys) {
      noteBox.delete(key);
    }
    selectedKeys.clear();
    isSelectionMode.value = false;
    refreshNotes();
  }

  void moveNotesToFolder(dynamic targetFolderKey, {dynamic singleNoteKey}) {
    List<dynamic> keysToMove = singleNoteKey != null ? [singleNoteKey] : selectedKeys.toList();

    for (var noteKey in keysToMove) {
      final noteData = noteBox.get(noteKey);
      if (noteData != null) {
        final updatedNote = Map<String, dynamic>.from(noteData);
        updatedNote['folderKey'] = targetFolderKey;
        noteBox.put(noteKey, updatedNote);
      }
    }

    isSelectionMode.value = false;
    selectedKeys.clear();
    refreshNotes();
    Get.back(); // Close BottomSheet
    Get.snackbar("Success", "Notes moved successfully", backgroundColor: Colors.green, colorText: Colors.white);
  }

  bool anySelectedNoteIsLocked() {
    return selectedKeys.any((key) => noteBox.get(key)?['isLocked'] ?? false);
  }

  void verifyAndExecute({required bool isLocked, required VoidCallback onVerified, String title = "Security Check"}) {
    if (!isLocked) {
      onVerified();
      return;
    }
    final TextEditingController passController = TextEditingController();
    String? masterPassword = settingsBox.get('master_password');

    showConfirmDialog(
      context: Get.context!,
      title: title,
      subTitle: "Verification required for protected content.",
      confirmText: "Unlock",
      controller: passController,
      obscureText: true,
      hintText: "Master Password",
      onConfirm: () {
        if (passController.text == masterPassword) {
          Get.back(); // Close dialog
          onVerified();
        } else {
          Get.snackbar("Error", "Incorrect Password", backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }

  String getDateHeader(String dateStr) {
    try {
      DateTime noteDate = DateFormat('dd/MM/yyyy').parse(dateStr);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      if (noteDate.isAtSameMomentAs(today)) return "Today";
      if (noteDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) return "Yesterday";
      return DateFormat('MMMM d').format(noteDate);
    } catch (e) {
      return "Earlier";
    }
  }
}
