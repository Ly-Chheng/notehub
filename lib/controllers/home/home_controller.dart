import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/widgets/custom_dialog.dart';

class HomeController extends GetxController {
  final Box folderBox = Hive.box('folders_box');
  final Box noteBox = Hive.box('student_notes');
  final Box trashBox = Hive.box('recently_deleted');
  final Box settingsBox = Hive.box('settings_box');

  var isSelectionMode = false.obs;
  var selectedKeys = <dynamic>{}.obs;

  void deleteFolder(dynamic folderKey) {
    _moveFolderNotesToTrash(folderKey);
    folderBox.delete(folderKey);
  }

  void _moveFolderNotesToTrash(dynamic folderKey) {
    final notesToMove = noteBox.toMap().entries.where((entry) => entry.value['folderKey'] == folderKey).toList();

    for (var entry in notesToMove) {
      trashBox.put(entry.key, {
        ...Map<String, dynamic>.from(entry.value),
        'deletedAt': DateTime.now().toIso8601String(),
      });
      noteBox.delete(entry.key);
    }
  }

  void permanentDelete(dynamic key) {
    trashBox.delete(key);
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedKeys.clear();
    }
  }

  void toggleSelection(dynamic key) {
    if (selectedKeys.contains(key)) {
      selectedKeys.remove(key);
    } else {
      selectedKeys.add(key);
    }
  }

  void restoreSelected() {
    if (selectedKeys.isEmpty) return;

    for (var key in selectedKeys) {
      final data = trashBox.get(key);
      if (data != null) {
        final restoredData = Map<String, dynamic>.from(data);
        restoredData.remove('deletedAt');
        noteBox.put(key, restoredData);
        trashBox.delete(key);
      }
    }

    toggleSelectionMode();
  }

  void deleteSelectedPermanently(BuildContext context) {
    if (selectedKeys.isEmpty) return;

    showConfirmDialog(
      context: context,
      title: "Delete Permanently?",
      subTitle: "Are you sure you want to delete ${selectedKeys.length} items forever? This action cannot be undone.",
      onConfirm: () {
        for (var key in selectedKeys) {
          trashBox.delete(key);
        }
        // Reset selection mode
        toggleSelectionMode();
      },
    );
  }

  void restoreNote(dynamic key, dynamic data) {
    final restoredData = Map<String, dynamic>.from(data);
    restoredData.remove('deletedAt'); // Clean metadata

    noteBox.put(key, restoredData);
    trashBox.delete(key);
  }

  // For Bulk Move (Selection Mode)
  void moveSelectedToFolder(dynamic targetFolderKey) {
    if (selectedKeys.isEmpty) return;
    for (var key in selectedKeys) {
      _executeMove(key, targetFolderKey);
    }
    toggleSelectionMode();
    Get.back();
  }

  // For Single Move (Swipe)
  void moveSingleNoteToFolder(dynamic key, dynamic targetFolderKey) {
    _executeMove(key, targetFolderKey);
    Get.back();
  }

  // Internal helper to avoid code duplication
  void _executeMove(dynamic key, dynamic targetFolderKey) {
    final data = trashBox.get(key);
    if (data != null) {
      final restoredData = Map<String, dynamic>.from(data);
      restoredData.remove('deletedAt');
      restoredData['folderKey'] = targetFolderKey;
      noteBox.put(key, restoredData);
      trashBox.delete(key);
    }
  }
}
