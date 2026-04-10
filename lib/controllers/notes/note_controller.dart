import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

enum ShareMode { text, photo }

class NoteController extends GetxController {
  final Box noteBox = Hive.box('student_notes');
  final Box trashBox = Hive.box('recently_deleted');
  final Box settingsBox = Hive.box('settings_box');
  final Box folderBox = Hive.box('folders_box');
  var searchQuery = "".obs;

  void updateSearchQuery(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  List<MapEntry<dynamic, dynamic>> getFilteredNotes(dynamic folderKey) {
    final allNotes = noteBox.toMap().entries.where((entry) => entry.value['folderKey'] == folderKey).toList();

    List<MapEntry<dynamic, dynamic>> filtered = allNotes;
    if (searchQuery.isNotEmpty) {
      filtered = allNotes.where((entry) {
        final title = (entry.value['title'] ?? "").toString().toLowerCase();
        final content = (entry.value['subtitle'] ?? "").toString().toLowerCase();
        return title.contains(searchQuery.value) || content.contains(searchQuery.value);
      }).toList();
    }

    filtered.sort((a, b) {
      DateTime dateA = _parseNoteDate(a.value['date']);
      DateTime dateB = _parseNoteDate(b.value['date']);

      int dateCompare = dateB.compareTo(dateA);
      if (dateCompare != 0) return dateCompare;

      return b.key.compareTo(a.key);
    });

    return filtered;
  }

  DateTime _parseNoteDate(dynamic dateStr) {
    try {
      if (dateStr == null) return DateTime(2000);
      return DateFormat('dd/MM/yyyy').parse(dateStr.toString());
    } catch (e) {
      return DateTime(2000);
    }
  }

  Future<void> moveNotesToFolder({
    required List<dynamic> keysToMove,
    required dynamic targetFolderKey,
  }) async {
    try {
      for (var noteKey in keysToMove) {
        final noteData = noteBox.get(noteKey);
        if (noteData != null) {
          final updatedNote = Map<String, dynamic>.from(noteData);
          updatedNote['folderKey'] = targetFolderKey;
          await noteBox.put(noteKey, updatedNote);
        }
      }
      update();
    } catch (e) {
      Get.snackbar("Error", "Failed to move notes", backgroundColor: AppColor().red, colorText: AppColor().white);
    }
  }

  Future<void> shareNote({
    required String title,
    required String content,
    required List<File> selectedImages,
    required ShareMode mode,
  }) async {
    try {
      final String shareTitle = title.trim().isEmpty ? "Untitled Note" : title.trim();
      final String shareContent = content.trim();
      final String fullMessage = "${shareTitle.toUpperCase()}\n$shareContent";

      if (mode == ShareMode.photo) {
        if (selectedImages.isNotEmpty) {
          final List<XFile> xFiles = selectedImages.where((f) => f.existsSync()).map((f) => XFile(f.path)).toList();
          SharePlus.instance.share(ShareParams(files: xFiles));
        } else {
          Get.snackbar("Info", "No photos found in this note to share.");
        }
      } else {
        SharePlus.instance.share(ShareParams(text: fullMessage, subject: shareTitle));
      }
    } catch (e) {
      Get.snackbar("Share Error", "Could not open share menu", backgroundColor: AppColor().red, colorText: AppColor().white);
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

  String getDateHeader(String dateStr) {
    try {
      DateTime noteDate = DateFormat('dd/MM/yyyy').parse(dateStr);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));

      if (noteDate.isAtSameMomentAs(today)) {
        return "Today";
      } else if (noteDate.isAtSameMomentAs(yesterday)) {
        return "Yesterday";
      } else if (noteDate.year == now.year) {
        return DateFormat('MMMM d').format(noteDate);
      } else {
        return DateFormat('MMMM d, y').format(noteDate);
      }
    } catch (e) {
      return "Earlier";
    }
  }

  String getPlainTextFromNote(String? subtitleJson) {
    if (subtitleJson == null || subtitleJson.isEmpty) return "";

    try {
      final document = quill.Document.fromJson(jsonDecode(subtitleJson));
      return document.toPlainText().trim();
    } catch (e) {
      return subtitleJson;
    }
  }

  /// Check if any selected notes are locked
  bool anySelectedNoteIsLocked(Set<dynamic> selectedKeys) {
    return selectedKeys.any((key) {
      final note = noteBox.get(key);
      return note != null && (note['isLocked'] ?? false);
    });
  }

  void verifyAndExecute({
    required BuildContext context,
    required bool isLocked,
    required VoidCallback onVerified,
    String title = "This note is locked.",
  }) {
    if (!isLocked) {
      onVerified();
      return;
    }

    final TextEditingController passController = TextEditingController();
    String? masterPassword = settingsBox.get('master_password');

    showConfirmDialog(
      context: context,
      title: title,
      subTitle: "Verification required for this locked note.",
      confirmText: "Unlock",
      controller: passController,
      obscureText: true,
      hintText: "Master Password",
      onConfirm: () {
        if (passController.text == masterPassword) {
          onVerified();
        } else {
          Get.snackbar("Error", "Incorrect Password", backgroundColor: AppColor().red, colorText: AppColor().white);
        }
      },
    );
  }

  /// Deletes multiple notes and moves them to the recently_deleted box
  void deleteSelectedNotes({
    required Set<dynamic> selectedKeys,
    VoidCallback? onComplete,
  }) {
    for (var key in selectedKeys) {
      final noteData = noteBox.get(key);
      if (noteData != null) {
        final deletedData = Map<String, dynamic>.from(noteData);
        deletedData['deletedAt'] = DateTime.now().toIso8601String();

        trashBox.put(key, deletedData);
        noteBox.delete(key);
      }
    }

    update();

    if (onComplete != null) onComplete();
  }

  List<MapEntry<dynamic, dynamic>> get allFolders => folderBox.toMap().entries.toList();
  Future<void> updateNoteFolder(dynamic noteKey, dynamic targetFolderKey) async {
    final noteData = noteBox.get(noteKey);
    if (noteData != null) {
      final updatedNote = Map<String, dynamic>.from(noteData);
      updatedNote['folderKey'] = targetFolderKey;
      await noteBox.put(noteKey, updatedNote);
      update();
    }
  }
}
