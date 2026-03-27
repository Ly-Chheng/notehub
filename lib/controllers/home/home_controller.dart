import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/widgets/custom_dialog.dart';

class HomeController extends GetxController {
  final Box folderBox = Hive.box('folders_box');
  final Box noteBox = Hive.box('student_notes');
  final Box trashBox = Hive.box('recently_deleted');
  final Box settingsBox = Hive.box('settings_box');

  final String defaultFolderName = "My Note";

  var isSelectionMode = false.obs;
  var selectedKeys = <dynamic>{}.obs;

  // Logic moved from initState
  void ensureDefaultFolder() {
    bool exists = folderBox.values.any((f) => f['title'] == defaultFolderName);
    if (!exists) {
      folderBox.add({
        "title": defaultFolderName,
        "colorValue": Colors.orange.value,
        "isPinned": false,
      });
    }
  }

  // Sorting logic
  List<MapEntry<dynamic, dynamic>> getSortedFolders(List<MapEntry<dynamic, dynamic>> entries) {
    return entries
      ..sort((a, b) {
        if (a.value['title'] == defaultFolderName) return -1;
        if (b.value['title'] == defaultFolderName) return 1;

        bool aPinned = a.value['isPinned'] ?? false;
        bool bPinned = b.value['isPinned'] ?? false;
        if (aPinned && !bPinned) return -1;
        if (!aPinned && bPinned) return 1;
        return 0;
      });
  }

  // Folder Actions
  void togglePin(dynamic key, dynamic data) {
    final updated = Map<String, dynamic>.from(data);
    updated['isPinned'] = !(data['isPinned'] ?? false);
    folderBox.put(key, updated);
  }

  void deleteFolder(dynamic folderKey) {
    _moveFolderNotesToTrash(folderKey);
    folderBox.delete(folderKey);
  }

  void _moveFolderNotesToTrash(dynamic folderKey) {
    final notesToMove = noteBox.toMap().entries.where((e) => e.value['folderKey'] == folderKey).toList();
    for (var entry in notesToMove) {
      trashBox.put(entry.key, {
        ...Map<String, dynamic>.from(entry.value),
        'deletedAt': DateTime.now().toIso8601String(),
      });
      noteBox.delete(entry.key);
    }
  }

  void verifyAndExecute({
    required BuildContext context,
    required bool isLocked,
    required VoidCallback onVerified,
    String title = "Security Check",
  }) {
    if (!isLocked) {
      onVerified();
      return;
    }

    final TextEditingController passController = TextEditingController();
    String? masterPassword = settingsBox.get('master_password');

    if (masterPassword == null) {
      Get.snackbar("Security", "Please set a master password first.");
      onVerified(); // Or redirect to CreatePasswordScreen
      return;
    }

    showConfirmDialog(
      context: context,
      title: title,
      subTitle: "Enter password to unlock this folder.",
      controller: passController,
      obscureText: true,
      onConfirm: () {
        if (passController.text == masterPassword) {
          Get.back();
          onVerified();
        } else {
          Get.snackbar("Error", "Incorrect Password", backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }

  // FOLDER LOCK LOGIC
  void toggleFolderLock(dynamic key, dynamic data) {
    final updated = Map<String, dynamic>.from(data);
    bool currentlyLocked = data['isLocked'] ?? false;

    updated['isLocked'] = !currentlyLocked;
    folderBox.put(key, updated);

    update();
  }

  dynamic getDefaultFolderKey() {
    try {
      return folderBox.toMap().entries.firstWhere((e) => e.value['title'] == defaultFolderName).key;
    } catch (e) {
      return null;
    }
  }

  void permanentDelete(dynamic key) {
    trashBox.delete(key);
  }

  void deleteWapDialog(BuildContext context, Set<dynamic> keysToDelete) {
    if (keysToDelete.isEmpty) return;

    showConfirmDialog(
      context: context,
      title: "Delete Permanently?",
      subTitle: "Are you sure you want to delete ${keysToDelete.length} item(s) forever? This action cannot be undone.",
      onConfirm: () {
        for (var key in keysToDelete) {
          trashBox.delete(key);
        }
      },
    );
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
