import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FolderNoteController extends GetxController {
  final dynamic folderKey;
  final Box noteBox = Hive.box('student_notes');
  final Box folderBox = Hive.box('folders_box');

  // Reactive states for selection mode
  var isSelectionMode = false.obs;
  var selectedKeys = <dynamic>{}.obs;

  FolderNoteController({required this.folderKey});

  // Get filtered and sorted notes (Pinned first)
  List<MapEntry<dynamic, dynamic>> getFilteredNotes() {
    List<MapEntry<dynamic, dynamic>> notesList = noteBox.toMap().entries
        .where((entry) => entry.value['folderKey'] == folderKey)
        .toList();

    notesList.sort((a, b) {
      bool aPinned = a.value['isPinned'] ?? false;
      bool bPinned = b.value['isPinned'] ?? false;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });
    return notesList;
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

  void togglePin(dynamic key, dynamic note) {
    final updated = Map<String, dynamic>.from(note);
    updated['isPinned'] = !(note['isPinned'] ?? false);
    noteBox.put(key, updated);
  }

  Future<void> moveNotes(List<dynamic> keys, dynamic targetFolderKey) async {
    for (var key in keys) {
      final data = noteBox.get(key);
      if (data != null) {
        final updated = Map<String, dynamic>.from(data);
        updated['folderKey'] = targetFolderKey;
        await noteBox.put(key, updated);
      }
    }
    isSelectionMode.value = false;
    selectedKeys.clear();
  }

  void deleteNotes(List<dynamic> keys) {
    for (var key in keys) {
      noteBox.delete(key);
    }
    isSelectionMode.value = false;
    selectedKeys.clear();
  }
}