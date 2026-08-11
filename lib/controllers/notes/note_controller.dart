import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/models/note/note_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

enum ShareMode { text, photo, file }

class NoteController extends GetxController {
  var notes = <NoteModel>[].obs;
  var trashNotes = <NoteModel>[].obs;
  var isLoading = false.obs;

  // FETCH NOTES (Only active, non-deleted records)
  Future<void> fetchNotesByFolder(int folderId) async {
    isLoading.value = true;
    try {
      final db = await DatabaseService.db;
      final maps = await db.query(
        'notes',
        where: 'folder_id = ? AND is_deleted = 0',
        whereArgs: [folderId],
        orderBy: 'is_pinned DESC, id DESC',
      );

      notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
    } catch (e) {
      debugPrint(" Error fetching notes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Soft-deletes notes and moves them to a fallback structural folder safety net
  Future<void> bulkMoveToTrashByFolder(int folderId, int fallbackFolderId) async {
    try {
      final db = await DatabaseService.db;

      await db.update(
        'notes',
        {
          'is_deleted': 1,
          'folder_id': fallbackFolderId,
        },
        where: 'folder_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)',
        whereArgs: [folderId],
      );

      notes.clear();

      await fetchTrashNotes();
    } catch (e) {
      debugPrint("Error executing protected batch folder trash migration: $e");
    }
  }

  // FETCH TRASH NOTES
  Future<void> fetchTrashNotes() async {
    isLoading.value = true;
    try {
      final db = await DatabaseService.db;
      final maps = await db.query(
        'notes',
        where: 'is_deleted = 1',
        orderBy: 'id DESC',
      );
      trashNotes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
    } catch (e) {
      debugPrint(" Error fetching trash notes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //   SAVE NOTE (Create / Update)
  Future<int?> saveNoteSQLite({
    int? id,
    required int folderId,
    required String title,
    required String contentJson,
    bool isLocked = false,
    bool isPinned = false,
    int bgColor = 0,
    List<String> imagePaths = const [],
    bool showTable = false,
    List<List<String>> tableData = const [],
    List<Map<String, dynamic>> drawingLayers = const [],
  }) async {
    final db = await DatabaseService.db;
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final row = {
      'folder_id': folderId,
      'title': title.isEmpty ? "" : title,
      'content': contentJson,
      'date': date,
      'is_locked': isLocked ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'is_deleted': 0,
      'bg_color': bgColor,
      'image_paths': jsonEncode(imagePaths),
      'show_table': showTable ? 1 : 0,
      'table_data': jsonEncode(tableData),
      'drawing_layers': jsonEncode(drawingLayers),
    };

    try {
      int? resultId;

      if (id == null) {
        //  CREATE NEW NOTE
        resultId = await db.insert('notes', row);
        // debugPrint(' Note CREATED: ID $resultId');
      } else {
        // UPDATE EXISTING NOTE
        // int count = await db.update('notes', row, where: 'id = ?', whereArgs: [id]);
        resultId = id;
        // debugPrint(' Note UPDATED: ID $id ($count rows affected)');
      }

      await fetchNotesByFolder(folderId);

      return resultId;
    } catch (e) {
      debugPrint(' SQLite Save Error: $e');

      Get.snackbar(
        "Save Failed",
        "Could not save your note to the database.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // MOVE TO TRASH (Soft Delete)
  Future<void> moveToTrash(int id, int folderId) async {
    try {
      final db = await DatabaseService.db;
      await db.update(
        'notes',
        {'is_deleted': 1, 'is_pinned': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      notes.removeWhere((element) => element.id == id);
    } catch (e) {
      debugPrint(' Error moving note to trash: $e');
    }
  }

  // BULK MOVE TO TRASH
  Future<void> bulkMoveToTrash(List<int> ids, int folderId) async {
    try {
      final db = await DatabaseService.db;
      final batch = db.batch();
      for (var id in ids) {
        batch.update(
          'notes',
          {'is_deleted': 1, 'is_pinned': 0},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
      notes.removeWhere((element) => ids.contains(element.id));
    } catch (e) {
      debugPrint(" Bulk move to trash error: $e");
    }
  }

  // RESTORE NOTE
  Future<void> restoreNote(int id) async {
    try {
      final db = await DatabaseService.db;
      await db.update('notes', {'is_deleted': 0}, where: 'id = ?', whereArgs: [id]);
      trashNotes.removeWhere((note) => note.id == id);
    } catch (e) {
      debugPrint(' Error restoring note: $e');
    }
  }

  // PERMANENT HARD DELETE
  Future<void> permanentDeleteNote(int id) async {
    try {
      final db = await DatabaseService.db;
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      trashNotes.removeWhere((note) => note.id == id);
    } catch (e) {
      debugPrint(' Error permanently deleting note: $e');
    }
  }

  // EMPTY TRASH
  Future<void> emptyTrash() async {
    try {
      final db = await DatabaseService.db;
      await db.delete('notes', where: 'is_deleted = 1');
      trashNotes.clear();
    } catch (e) {
      debugPrint(' Error emptying trash: $e');
    }
  }

  // BULK MOVE FOLDER (Optimized Transaction)
  Future<void> bulkMoveNotes(List<int> noteIds, int newFolderId) async {
    try {
      final db = await DatabaseService.db;
      final batch = db.batch();
      for (var id in noteIds) {
        batch.update(
          'notes',
          {'folder_id': newFolderId},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
      notes.removeWhere((element) => noteIds.contains(element.id));
    } catch (e) {
      debugPrint(" Bulk Move Error: $e");
    }
  }

  //   DELETE NOTE
  Future<void> deleteNote(int id, int folderId) async {
    try {
      final db = await DatabaseService.db;
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      debugPrint(' Note deleted successfully (ID: $id)');
      await fetchNotesByFolder(folderId);
    } catch (e) {
      debugPrint(' Error deleting note: $e');
    }
  }

  //   SEARCH NOTES
  Future<void> searchNotes(String query, int folderId) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      fetchNotesByFolder(folderId);
      return;
    }

    try {
      final db = await DatabaseService.db;
      final maps = await db.query(
        'notes',
        where: 'folder_id = ? AND (title LIKE ? OR content LIKE ?)',
        whereArgs: [folderId, '%$trimmedQuery%', '%$trimmedQuery%'],
        orderBy: 'is_pinned DESC, id DESC',
      );

      notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
      debugPrint(" Search for '$trimmedQuery' returned ${notes.length} result(s)");
    } catch (e) {
      debugPrint(" Search error: $e");
    }
  }

// MOVE NOTE TO ANOTHER FOLDER
  Future<void> moveNote(int noteId, int newFolderId) async {
    try {
      final db = await DatabaseService.db;

      int rowsAffected = await db.update(
        'notes',
        {'folder_id': newFolderId},
        where: 'id = ?',
        whereArgs: [noteId],
      );

      if (rowsAffected > 0) {
        debugPrint("Note $noteId moved to folder $newFolderId in Database");

        notes.removeWhere((element) => element.id == noteId);

        notes.refresh();
      } else {
        debugPrint("Move failed: Note ID not found");
      }
    } catch (e) {
      debugPrint("Move Note Error: $e");
    }
  }

  Future<void> togglePinNote(NoteModel note, int folderId) async {
    try {
      final db = await DatabaseService.db;

      int newStatus = (note.isPinned == true) ? 0 : 1;

      await db.update(
        'notes',
        {'is_pinned': newStatus},
        where: 'id = ?',
        whereArgs: [note.id],
      );

      await fetchNotesByFolder(folderId);
      notes.refresh();
    } catch (e) {
      debugPrint("Pin Error: $e");
    }
  }

  String getPlainTextFromNote(String content) {
    try {
      final decoded = jsonDecode(content);
      final doc = Document.fromJson(decoded);

      return doc.toPlainText().replaceAll('￼', '').replaceAll('OBJ', '').replaceAll('\n', ' ').trim();
    } catch (e) {
      return '';
    }
  }

  String getDateHeader(String dateStr) {
    try {
      DateTime noteDate = DateFormat('dd/MM/yyyy').parse(dateStr);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));
      DateTime noteDateMidnight = DateTime(noteDate.year, noteDate.month, noteDate.day);

      if (noteDateMidnight.isAtSameMomentAs(today)) {
        return 'today'.tr;
      } else if (noteDateMidnight.isAtSameMomentAs(yesterday)) {
        return 'yesterday'.tr;
      } else if (noteDate.year == now.year) {
        // For "MMMM d", we use DateFormat with the current locale
        return DateFormat('MMMM d', Get.locale.toString()).format(noteDate);
      } else {
        return DateFormat('MMMM d, y', Get.locale.toString()).format(noteDate);
      }
    } catch (e) {
      return 'earlier'.tr;
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
      final String fullMessage = "$shareTitle\n$shareContent";

      if (mode == ShareMode.photo) {
        if (selectedImages.isNotEmpty) {
          final List<XFile> xFiles = selectedImages.where((f) => f.existsSync()).map((f) => XFile(f.path)).toList();
          SharePlus.instance.share(ShareParams(files: xFiles));
        } else {
          Get.snackbar("Info", "No photos found in this note to share.");
        }
      } else if (mode == ShareMode.file) {
        final Directory tempDir = await getTemporaryDirectory();
        final String cleanTitle = shareTitle.replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), '');
        final String fileName = "${cleanTitle.isEmpty ? 'shared_file' : cleanTitle}.txt";
        final File file = File('${tempDir.path}/$fileName');

        // await file.writeAsString(fullMessage);
        await file.writeAsString(shareContent);

        final XFile xFile = XFile(file.path);
        SharePlus.instance.share(ShareParams(files: [xFile]));
      } else {
        SharePlus.instance.share(ShareParams(text: fullMessage, subject: shareTitle));
      }
    } catch (e) {
      Get.snackbar("Share Error", "Could not open share menu", backgroundColor: AppColor().red, colorText: AppColor().white);
    }
  }

  Future<int> getCountForFolder(int folderId) async {
    try {
      final db = await DatabaseService.db;
      // AND is_deleted = 0 to ignore recently deleted notes
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notes WHERE folder_id = ? AND is_deleted = 0',
        [folderId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      final db = await DatabaseService.db;
      await db.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      debugPrint("Note ${note.id} updated in SQLite");
    } catch (e) {
      debugPrint("Error updating note: $e");
    }
  }

  Future<void> fetchAllNotes() async {
    isLoading.value = true;
    try {
      final db = await DatabaseService.db;
      final maps = await db.query('notes', orderBy: 'id DESC');
      notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
    } catch (e) {
      debugPrint("Error fetching all notes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void refreshNotes(int folderId) {
    fetchNotesByFolder(folderId);
  }

  // Inside NoteController class
  Future<bool> hasLockedNotesInFolder(int folderId) async {
    try {
      final db = await DatabaseService.db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notes WHERE folder_id = ? AND is_locked = 1',
        [folderId],
      );
      int count = Sqflite.firstIntValue(result) ?? 0;
      return count > 0;
    } catch (e) {
      debugPrint("Error checking for locked notes: $e");
      return false;
    }
  }
}


// == V2 with Firebase 
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:project_structure/core/database/database_service.dart';
// import 'package:project_structure/core/services/note_sync_service.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/models/note/note_model.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sqflite/sqflite.dart';

// enum ShareMode { text, photo, file }

// class NoteController extends GetxController {
//   var notes = <NoteModel>[].obs;
//   var trashNotes = <NoteModel>[].obs;
//   var isLoading = false.obs;

//   // Sync Configuration
//   final NoteSyncService _syncService = NoteSyncService();
//   final String userId = "user_123"; // គួរទទួលបានពី Firebase Auth Module របស់អ្នក

//   /// ជំនួយការហៅលំហូរការងារ Sync ទៅ Firebase (Debounce 3 វិនាទី)
//   void _triggerFirebasePushDebounce() {
//     debounce(
//       "".obs,
//       (_) => _syncService.pushLocalChangesToFirebase(userId),
//       time: const Duration(seconds: 3),
//     );
//   }

//   // FETCH NOTES (Only active, non-deleted records)
//   Future<void> fetchNotesByFolder(int folderId) async {
//     isLoading.value = true;
//     try {
//       final db = await DatabaseService.db;
//       final maps = await db.query(
//         'notes',
//         where: 'folder_id = ? AND is_deleted = 0',
//         whereArgs: [folderId],
//         orderBy: 'is_pinned DESC, id DESC',
//       );

//       notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
//     } catch (e) {
//       debugPrint(" Error fetching notes: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Soft-deletes notes and moves them to a fallback structural folder safety net
//   Future<void> bulkMoveToTrashByFolder(int folderId, int fallbackFolderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();

//       await db.update(
//         'notes',
//         {
//           'is_deleted': 1,
//           'folder_id': fallbackFolderId,
//           'is_synced': 0,
//           'updated_at': timestamp,
//         },
//         where: 'folder_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)',
//         whereArgs: [folderId],
//       );

//       notes.clear();
//       await fetchTrashNotes();
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint("Error executing protected batch folder trash migration: $e");
//     }
//   }

//   // FETCH TRASH NOTES
//   Future<void> fetchTrashNotes() async {
//     isLoading.value = true;
//     try {
//       final db = await DatabaseService.db;
//       final maps = await db.query(
//         'notes',
//         where: 'is_deleted = 1',
//         orderBy: 'id DESC',
//       );
//       trashNotes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
//     } catch (e) {
//       debugPrint(" Error fetching trash notes: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // SAVE NOTE (Create / Update)
//   Future<int?> saveNoteSQLite({
//     int? id,
//     required int folderId,
//     required String title,
//     required String contentJson,
//     bool isLocked = false,
//     bool isPinned = false,
//     int bgColor = 0,
//     List<String> imagePaths = const [],
//     bool showTable = false,
//     List<List<String>> tableData = const [],
//     List<Map<String, dynamic>> drawingLayers = const [],
//   }) async {
//     final db = await DatabaseService.db;
//     final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
//     final timestamp = DateTime.now().toIso8601String();

//     final row = {
//       'folder_id': folderId,
//       'title': title.isEmpty ? "" : title,
//       'content': contentJson,
//       'date': date,
//       'is_locked': isLocked ? 1 : 0,
//       'is_pinned': isPinned ? 1 : 0,
//       'is_deleted': 0,
//       'bg_color': bgColor,
//       'image_paths': jsonEncode(imagePaths),
//       'show_table': showTable ? 1 : 0,
//       'table_data': jsonEncode(tableData),
//       'drawing_layers': jsonEncode(drawingLayers),
//       'is_synced': 0,
//       'updated_at': timestamp,
//     };

//     try {
//       int? resultId;

//       if (id == null) {
//         // CREATE NEW NOTE
//         resultId = await db.insert('notes', row);
//       } else {
//         // UPDATE EXISTING NOTE
//         await db.update('notes', row, where: 'id = ?', whereArgs: [id]);
//         resultId = id;
//       }

//       await fetchNotesByFolder(folderId);
//       _triggerFirebasePushDebounce();

//       return resultId;
//     } catch (e) {
//       debugPrint(' SQLite Save Error: $e');
//       Get.snackbar(
//         "Save Failed",
//         "Could not save your note to the database.",
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return null;
//     }
//   }

//   // MOVE TO TRASH (Soft Delete)
//   Future<void> moveToTrash(int id, int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();

//       await db.update(
//         'notes',
//         {
//           'is_deleted': 1,
//           'is_pinned': 0,
//           'is_synced': 0,
//           'updated_at': timestamp,
//         },
//         where: 'id = ?',
//         whereArgs: [id],
//       );
//       notes.removeWhere((element) => element.id == id);
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint(' Error moving note to trash: $e');
//     }
//   }

//   // BULK MOVE TO TRASH
//   Future<void> bulkMoveToTrash(List<int> ids, int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final batch = db.batch();
//       final timestamp = DateTime.now().toIso8601String();

//       for (var id in ids) {
//         batch.update(
//           'notes',
//           {
//             'is_deleted': 1,
//             'is_pinned': 0,
//             'is_synced': 0,
//             'updated_at': timestamp,
//           },
//           where: 'id = ?',
//           whereArgs: [id],
//         );
//       }
//       await batch.commit(noResult: true);
//       notes.removeWhere((element) => ids.contains(element.id));
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint(" Bulk move to trash error: $e");
//     }
//   }

//   // RESTORE NOTE
//   Future<void> restoreNote(int id) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();

//       await db.update(
//           'notes',
//           {
//             'is_deleted': 0,
//             'is_synced': 0,
//             'updated_at': timestamp,
//           },
//           where: 'id = ?',
//           whereArgs: [id]);
//       trashNotes.removeWhere((note) => note.id == id);
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint(' Error restoring note: $e');
//     }
//   }

//   // PERMANENT HARD DELETE
//   Future<void> permanentDeleteNote(int id) async {
//     try {
//       final db = await DatabaseService.db;

//       final List<Map<String, dynamic>> maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
//       if (maps.isNotEmpty) {
//         String? firebaseId = maps.first['firebase_id'];
//         if (firebaseId != null) {
//           await _syncService.deleteNoteFromFirebase(userId, firebaseId);
//         }
//       }

//       await db.delete('notes', where: 'id = ?', whereArgs: [id]);
//       trashNotes.removeWhere((note) => note.id == id);
//     } catch (e) {
//       debugPrint(' Error permanently deleting note: $e');
//     }
//   }

//   // EMPTY TRASH
//   Future<void> emptyTrash() async {
//     try {
//       final db = await DatabaseService.db;

//       final List<Map<String, dynamic>> maps = await db.query('notes', where: 'is_deleted = 1');
//       for (var row in maps) {
//         String? firebaseId = row['firebase_id'];
//         if (firebaseId != null) {
//           await _syncService.deleteNoteFromFirebase(userId, firebaseId);
//         }
//       }

//       await db.delete('notes', where: 'is_deleted = 1');
//       trashNotes.clear();
//     } catch (e) {
//       debugPrint(' Error emptying trash: $e');
//     }
//   }

//   // BULK MOVE FOLDER (Optimized Transaction)
//   Future<void> bulkMoveNotes(List<int> noteIds, int newFolderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final batch = db.batch();
//       final timestamp = DateTime.now().toIso8601String();

//       for (var id in noteIds) {
//         batch.update(
//           'notes',
//           {
//             'folder_id': newFolderId,
//             'is_synced': 0,
//             'updated_at': timestamp,
//           },
//           where: 'id = ?',
//           whereArgs: [id],
//         );
//       }
//       await batch.commit(noResult: true);
//       notes.removeWhere((element) => noteIds.contains(element.id));
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint(" Bulk Move Error: $e");
//     }
//   }

//   // DELETE NOTE
//   Future<void> deleteNote(int id, int folderId) async {
//     try {
//       final db = await DatabaseService.db;

//       final List<Map<String, dynamic>> maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
//       if (maps.isNotEmpty) {
//         String? firebaseId = maps.first['firebase_id'];
//         if (firebaseId != null) {
//           await _syncService.deleteNoteFromFirebase(userId, firebaseId);
//         }
//       }

//       await db.delete('notes', where: 'id = ?', whereArgs: [id]);
//       await fetchNotesByFolder(folderId);
//     } catch (e) {
//       debugPrint(' Error deleting note: $e');
//     }
//   }

//   // SEARCH NOTES
//   Future<void> searchNotes(String query, int folderId) async {
//     final trimmedQuery = query.trim();

//     if (trimmedQuery.isEmpty) {
//       fetchNotesByFolder(folderId);
//       return;
//     }

//     try {
//       final db = await DatabaseService.db;
//       final maps = await db.query(
//         'notes',
//         where: 'folder_id = ? AND is_deleted = 0 AND (title LIKE ? OR content LIKE ?)',
//         whereArgs: [folderId, '%$trimmedQuery%', '%$trimmedQuery%'],
//         orderBy: 'is_pinned DESC, id DESC',
//       );

//       notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
//     } catch (e) {
//       debugPrint(" Search error: $e");
//     }
//   }

//   // MOVE NOTE TO ANOTHER FOLDER
//   Future<void> moveNote(int noteId, int newFolderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();

//       int rowsAffected = await db.update(
//         'notes',
//         {
//           'folder_id': newFolderId,
//           'is_synced': 0,
//           'updated_at': timestamp,
//         },
//         where: 'id = ?',
//         whereArgs: [noteId],
//       );

//       if (rowsAffected > 0) {
//         notes.removeWhere((element) => element.id == noteId);
//         notes.refresh();
//         _triggerFirebasePushDebounce();
//       }
//     } catch (e) {
//       debugPrint("Move Note Error: $e");
//     }
//   }

//   // TOGGLE PIN NOTE
//   Future<void> togglePinNote(NoteModel note, int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();
//       int newStatus = (note.isPinned == true) ? 0 : 1;

//       await db.update(
//         'notes',
//         {
//           'is_pinned': newStatus,
//           'is_synced': 0,
//           'updated_at': timestamp,
//         },
//         where: 'id = ?',
//         whereArgs: [note.id],
//       );

//       await fetchNotesByFolder(folderId);
//       notes.refresh();
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint("Pin Error: $e");
//     }
//   }

//   String getPlainTextFromNote(String content) {
//     try {
//       final decoded = jsonDecode(content);
//       final doc = quill.Document.fromJson(decoded);

//       return doc.toPlainText().replaceAll('￼', '').replaceAll('OBJ', '').replaceAll('\n', ' ').trim();
//     } catch (e) {
//       return '';
//     }
//   }

//   String getDateHeader(String dateStr) {
//     try {
//       DateTime noteDate = DateFormat('dd/MM/yyyy').parse(dateStr);
//       DateTime now = DateTime.now();
//       DateTime today = DateTime(now.year, now.month, now.day);
//       DateTime yesterday = today.subtract(const Duration(days: 1));
//       DateTime noteDateMidnight = DateTime(noteDate.year, noteDate.month, noteDate.day);

//       if (noteDateMidnight.isAtSameMomentAs(today)) {
//         return 'today'.tr;
//       } else if (noteDateMidnight.isAtSameMomentAs(yesterday)) {
//         return 'yesterday'.tr;
//       } else if (noteDate.year == now.year) {
//         return DateFormat('MMMM d', Get.locale.toString()).format(noteDate);
//       } else {
//         return DateFormat('MMMM d, y', Get.locale.toString()).format(noteDate);
//       }
//     } catch (e) {
//       return 'earlier'.tr;
//     }
//   }

//   Future<void> shareNote({
//     required String title,
//     required String content,
//     required List<File> selectedImages,
//     required ShareMode mode,
//   }) async {
//     try {
//       final String shareTitle = title.trim().isEmpty ? "Untitled Note" : title.trim();
//       final String shareContent = content.trim();
//       final String fullMessage = "$shareTitle\n$shareContent";

//       if (mode == ShareMode.photo) {
//         if (selectedImages.isNotEmpty) {
//           final List<XFile> xFiles = selectedImages.where((f) => f.existsSync()).map((f) => XFile(f.path)).toList();
//           SharePlus.instance.share(ShareParams(files: xFiles));
//         } else {
//           Get.snackbar("Info", "No photos found in this note to share.");
//         }
//       } else if (mode == ShareMode.file) {
//         final Directory tempDir = await getTemporaryDirectory();
//         final String cleanTitle = shareTitle.replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), '');
//         final String fileName = "${cleanTitle.isEmpty ? 'shared_file' : cleanTitle}.txt";
//         final File file = File('${tempDir.path}/$fileName');

//         await file.writeAsString(shareContent);

//         final XFile xFile = XFile(file.path);
//         SharePlus.instance.share(ShareParams(files: [xFile]));
//       } else {
//         SharePlus.instance.share(ShareParams(text: fullMessage, subject: shareTitle));
//       }
//     } catch (e) {
//       Get.snackbar("Share Error", "Could not open share menu", backgroundColor: AppColor().red, colorText: AppColor().white);
//     }
//   }

//   Future<int> getCountForFolder(int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final result = await db.rawQuery(
//         'SELECT COUNT(*) as count FROM notes WHERE folder_id = ? AND is_deleted = 0',
//         [folderId],
//       );
//       return Sqflite.firstIntValue(result) ?? 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   Future<void> updateNote(NoteModel note) async {
//     try {
//       final db = await DatabaseService.db;
//       var noteMap = note.toMap();
//       noteMap['is_synced'] = 0;
//       noteMap['updated_at'] = DateTime.now().toIso8601String();

//       await db.update(
//         'notes',
//         noteMap,
//         where: 'id = ?',
//         whereArgs: [note.id],
//       );
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint("Error updating note: $e");
//     }
//   }

//   Future<void> fetchAllNotes() async {
//     isLoading.value = true;
//     try {
//       final db = await DatabaseService.db;
//       final maps = await db.query('notes', orderBy: 'id DESC');
//       notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
//     } catch (e) {
//       debugPrint("Error fetching all notes: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void refreshNotes(int folderId) {
//     fetchNotesByFolder(folderId);
//   }

//   Future<bool> hasLockedNotesInFolder(int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final result = await db.rawQuery(
//         'SELECT COUNT(*) as count FROM notes WHERE folder_id = ? AND is_locked = 1',
//         [folderId],
//       );
//       int count = Sqflite.firstIntValue(result) ?? 0;
//       return count > 0;
//     } catch (e) {
//       debugPrint("Error checking for locked notes: $e");
//       return false;
//     }
//   }

//   // សម្រាប់រក្សាទុកស្ថានភាពនៃការ Sync លើ UI (បង្ហាញ Loading Spiner)
//   var isSyncing = false.obs;

//   Future<void> syncDataAction(int currentFolderId) async {
//     if (isSyncing.value) return; // បើកំពុង Sync មិនឱ្យចុចជាន់គ្នាទេ

//     isSyncing.value = true;
//     try {
//       // 1. រុញទិន្នន័យដែលសល់លើ Local ឡើងទៅមុន
//       await _syncService.pushLocalChangesToFirebase(userId);

//       // 2. ទាញទិន្នន័យថ្មីៗពី Firebase មកវិញ (ទាញយកម៉ោង Sync ចុងក្រោយពី Storage របស់អ្នក)
//       // ឧទាហរណ៍៖ String lastSync = storage.read('last_sync') ?? '2000-01-01T00:00:00.000Z';
//       String lastSync = '2000-01-01T00:00:00.000Z';
//       await _syncService.pullChangesFromFirebase(userId, lastSync);

//       // 3. Update UI ឡើងវិញក្រោយពេល Sync រួចរាល់
//       await fetchNotesByFolder(currentFolderId);

//       Get.snackbar("Sync Success", "Your notes are up to date.", snackPosition: SnackPosition.BOTTOM);
//     } catch (e) {
//       debugPrint("❌ Action Sync Error: $e");
//     } finally {
//       isSyncing.value = false;
//     }
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart'; // 🛡️ បន្ថែម Firebase Auth
// import 'package:flutter/widgets.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:project_structure/core/database/database_service.dart';
// import 'package:project_structure/core/services/note_sync_service.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/models/note/note_model.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sqflite/sqflite.dart';

// enum ShareMode { text, photo, file }

// class NoteController extends GetxController {
//   var notes = <NoteModel>[].obs;
//   var trashNotes = <NoteModel>[].obs;
//   var isLoading = false.obs;
//   var isSyncing = false.obs;

//   // Sync Configuration
//   final NoteSyncService _syncService = NoteSyncService();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // 🛡️ ទាញយកព័ត៌មាន User បច្ចុប្បន្នពី Firebase Auth ផ្ទាល់
//   User? get currentUser => _auth.currentUser;
//   String get userId => currentUser?.uid ?? '';
//   String get userEmail => currentUser?.email ?? '';

//   // 🔄 បង្កើត Observable trigger សម្រាប់ Debounce Sync ឱ្យដំណើរការបានត្រឹមត្រូវ
//   final _syncTrigger = 0.obs;
//   Worker? _debounceWorker;

//   @override
//   void onInit() {
//     super.onInit();
//     // 🛡️ កំណត់ Debounce ឱ្យដំណើរការបានត្រឹមត្រូវ (រង់ចាំ 3 វិនាទីក្រោយឈប់កែប្រែ ទើប Sync)
//     _debounceWorker = debounce(
//       _syncTrigger,
//       (_) => _performAutoSync(),
//       time: const Duration(seconds: 3),
//     );
//   }

//   @override
//   void onClose() {
//     _debounceWorker?.dispose(); // បិទ Worker ពេលឈប់ប្រើប្រាស់ Controller
//     super.onClose();
//   }

//   /// ជំនួយការហៅលំហូរការងារ Sync ទៅ Firebase (Debounce)
//   void _triggerFirebasePushDebounce() {
//     if (userId.isNotEmpty) {
//       _syncTrigger.value++; // បង្កើនតម្លៃដើម្បី Trigger Debounce Worker
//     }
//   }

//   /// មុខងារ Push ទិន្នន័យស្វ័យប្រវត្តិតាមរយៈ Debounce
//   Future<void> _performAutoSync() async {
//     if (userId.isEmpty) return;
//     try {
//       await _syncService.pushLocalChangesToFirebase(userId, userEmail);
//     } catch (e) {
//       debugPrint("❌ Auto-sync failed: $e");
//     }
//   }

//   // FETCH NOTES (Only active, non-deleted records)
//   Future<void> fetchNotesByFolder(int folderId) async {
//     isLoading.value = true;
//     try {
//       final db = await DatabaseService.db;
//       final maps = await db.query(
//         'notes',
//         where: 'folder_id = ? AND is_deleted = 0',
//         whereArgs: [folderId],
//         orderBy: 'is_pinned DESC, id DESC',
//       );

//       notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
//     } catch (e) {
//       debugPrint(" Error fetching notes: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Soft-deletes notes and moves them to a fallback structural folder safety net
//   Future<void> bulkMoveToTrashByFolder(int folderId, int fallbackFolderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();

//       await db.update(
//         'notes',
//         {
//           'is_deleted': 1,
//           'folder_id': fallbackFolderId,
//           'is_synced': 0,
//           'updated_at': timestamp,
//         },
//         where: 'folder_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)',
//         whereArgs: [folderId],
//       );

//       notes.clear();
//       await fetchTrashNotes();
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint("Error executing protected batch folder trash migration: $e");
//     }
//   }

//   // FETCH TRASH NOTES
//   Future<void> fetchTrashNotes() async {
//     isLoading.value = true;
//     try {
//       final db = await DatabaseService.db;
//       final maps = await db.query(
//         'notes',
//         where: 'is_deleted = 1',
//         orderBy: 'id DESC',
//       );
//       trashNotes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
//     } catch (e) {
//       debugPrint(" Error fetching trash notes: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // SAVE NOTE (Create / Update)
//   Future<int?> saveNoteSQLite({
//     required int folderId,
//     required String title,
//     required String contentJson,
//     int? id,
//     bool isLocked = false,
//     bool isPinned = false,
//     int bgColor = 0,
//     List<String> imagePaths = const [],
//     bool showTable = false,
//     List<List<String>> tableData = const [],
//     List<Map<String, dynamic>> drawingLayers = const [],
//   }) async {
//     final db = await DatabaseService.db;
//     final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
//     final timestamp = DateTime.now().toIso8601String();

//     final row = {
//       'folder_id': folderId,
//       'title': title.isEmpty ? "" : title,
//       'content': contentJson,
//       'date': date,
//       'is_locked': isLocked ? 1 : 0,
//       'is_pinned': isPinned ? 1 : 0,
//       'is_deleted': 0,
//       'bg_color': bgColor,
//       'image_paths': jsonEncode(imagePaths),
//       'show_table': showTable ? 1 : 0,
//       'table_data': jsonEncode(tableData),
//       'drawing_layers': jsonEncode(drawingLayers),
//       'is_synced': 0,
//       'updated_at': timestamp,
//     };

//     try {
//       int? resultId;

//       if (id == null) {
//         // CREATE NEW NOTE
//         resultId = await db.insert('notes', row);
//       } else {
//         // UPDATE EXISTING NOTE
//         await db.update('notes', row, where: 'id = ?', whereArgs: [id]);
//         resultId = id;
//       }

//       await fetchNotesByFolder(folderId);
//       _triggerFirebasePushDebounce();

//       return resultId;
//     } catch (e) {
//       debugPrint(' SQLite Save Error: $e');
//       Get.snackbar(
//         "Save Failed",
//         "Could not save your note to the database.",
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return null;
//     }
//   }

//   // MOVE TO TRASH (Soft Delete)
//   Future<void> moveToTrash(int id, int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();

//       await db.update(
//         'notes',
//         {
//           'is_deleted': 1,
//           'is_pinned': 0,
//           'is_synced': 0,
//           'updated_at': timestamp,
//         },
//         where: 'id = ?',
//         whereArgs: [id],
//       );
//       notes.removeWhere((element) => element.id == id);
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint(' Error moving note to trash: $e');
//     }
//   }

//   // BULK MOVE TO TRASH
//   Future<void> bulkMoveToTrash(List<int> ids, int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final batch = db.batch();
//       final timestamp = DateTime.now().toIso8601String();

//       for (var id in ids) {
//         batch.update(
//           'notes',
//           {
//             'is_deleted': 1,
//             'is_pinned': 0,
//             'is_synced': 0,
//             'updated_at': timestamp,
//           },
//           where: 'id = ?',
//           whereArgs: [id],
//         );
//       }
//       await batch.commit(noResult: true);
//       notes.removeWhere((element) => ids.contains(element.id));
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint(" Bulk move to trash error: $e");
//     }
//   }

//   // RESTORE NOTE
//   Future<void> restoreNote(int id) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();

//       await db.update(
//           'notes',
//           {
//             'is_deleted': 0,
//             'is_synced': 0,
//             'updated_at': timestamp,
//           },
//           where: 'id = ?',
//           whereArgs: [id]);
//       trashNotes.removeWhere((note) => note.id == id);
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint(' Error restoring note: $e');
//     }
//   }

//   // PERMANENT HARD DELETE
//   Future<void> permanentDeleteNote(int id) async {
//     try {
//       if (userId.isEmpty) return;
//       final db = await DatabaseService.db;

//       final List<Map<String, dynamic>> maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
//       if (maps.isNotEmpty) {
//         String? firebaseId = maps.first['firebase_id'];
//         if (firebaseId != null) {
//           await _syncService.deleteNoteFromFirebase(userId, firebaseId);
//         }
//       }

//       await db.delete('notes', where: 'id = ?', whereArgs: [id]);
//       trashNotes.removeWhere((note) => note.id == id);
//     } catch (e) {
//       debugPrint(' Error permanently deleting note: $e');
//     }
//   }

//   // EMPTY TRASH
//   Future<void> emptyTrash() async {
//     try {
//       if (userId.isEmpty) return;
//       final db = await DatabaseService.db;

//       final List<Map<String, dynamic>> maps = await db.query('notes', where: 'is_deleted = 1');
//       for (var row in maps) {
//         String? firebaseId = row['firebase_id'];
//         if (firebaseId != null) {
//           await _syncService.deleteNoteFromFirebase(userId, firebaseId);
//         }
//       }

//       await db.delete('notes', where: 'is_deleted = 1');
//       trashNotes.clear();
//     } catch (e) {
//       debugPrint(' Error emptying trash: $e');
//     }
//   }

//   // BULK MOVE FOLDER (Optimized Transaction)
//   Future<void> bulkMoveNotes(List<int> noteIds, int newFolderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final batch = db.batch();
//       final timestamp = DateTime.now().toIso8601String();

//       for (var id in noteIds) {
//         batch.update(
//           'notes',
//           {
//             'folder_id': newFolderId,
//             'is_synced': 0,
//             'updated_at': timestamp,
//           },
//           where: 'id = ?',
//           whereArgs: [id],
//         );
//       }
//       await batch.commit(noResult: true);
//       notes.removeWhere((element) => noteIds.contains(element.id));
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint(" Bulk Move Error: $e");
//     }
//   }

//   // DELETE NOTE
//   Future<void> deleteNote(int id, int folderId) async {
//     try {
//       if (userId.isEmpty) return;
//       final db = await DatabaseService.db;

//       final List<Map<String, dynamic>> maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
//       if (maps.isNotEmpty) {
//         String? firebaseId = maps.first['firebase_id'];
//         if (firebaseId != null) {
//           await _syncService.deleteNoteFromFirebase(userId, firebaseId);
//         }
//       }

//       await db.delete('notes', where: 'id = ?', whereArgs: [id]);
//       await fetchNotesByFolder(folderId);
//     } catch (e) {
//       debugPrint(' Error deleting note: $e');
//     }
//   }

//   // SEARCH NOTES
//   Future<void> searchNotes(String query, int folderId) async {
//     final trimmedQuery = query.trim();

//     if (trimmedQuery.isEmpty) {
//       fetchNotesByFolder(folderId);
//       return;
//     }

//     try {
//       final db = await DatabaseService.db;
//       final maps = await db.query(
//         'notes',
//         where: 'folder_id = ? AND is_deleted = 0 AND (title LIKE ? OR content LIKE ?)',
//         whereArgs: [folderId, '%$trimmedQuery%', '%$trimmedQuery%'],
//         orderBy: 'is_pinned DESC, id DESC',
//       );

//       notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
//     } catch (e) {
//       debugPrint(" Search error: $e");
//     }
//   }

//   // MOVE NOTE TO ANOTHER FOLDER
//   Future<void> moveNote(int noteId, int newFolderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();

//       int rowsAffected = await db.update(
//         'notes',
//         {
//           'folder_id': newFolderId,
//           'is_synced': 0,
//           'updated_at': timestamp,
//         },
//         where: 'id = ?',
//         whereArgs: [noteId],
//       );

//       if (rowsAffected > 0) {
//         notes.removeWhere((element) => element.id == noteId);
//         notes.refresh();
//         _triggerFirebasePushDebounce();
//       }
//     } catch (e) {
//       debugPrint("Move Note Error: $e");
//     }
//   }

//   // TOGGLE PIN NOTE
//   Future<void> togglePinNote(NoteModel note, int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final timestamp = DateTime.now().toIso8601String();
//       int newStatus = (note.isPinned == true) ? 0 : 1;

//       await db.update(
//         'notes',
//         {
//           'is_pinned': newStatus,
//           'is_synced': 0,
//           'updated_at': timestamp,
//         },
//         where: 'id = ?',
//         whereArgs: [note.id],
//       );

//       await fetchNotesByFolder(folderId);
//       notes.refresh();
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint("Pin Error: $e");
//     }
//   }

//   String getPlainTextFromNote(String content) {
//     try {
//       final decoded = jsonDecode(content);
//       final doc = quill.Document.fromJson(decoded);

//       return doc.toPlainText().replaceAll('￼', '').replaceAll('OBJ', '').replaceAll('\n', ' ').trim();
//     } catch (e) {
//       return '';
//     }
//   }

//   String getDateHeader(String dateStr) {
//     try {
//       DateTime noteDate = DateFormat('dd/MM/yyyy').parse(dateStr);
//       DateTime now = DateTime.now();
//       DateTime today = DateTime(now.year, now.month, now.day);
//       DateTime yesterday = today.subtract(const Duration(days: 1));
//       DateTime noteDateMidnight = DateTime(noteDate.year, noteDate.month, noteDate.day);

//       if (noteDateMidnight.isAtSameMomentAs(today)) {
//         return 'today'.tr;
//       } else if (noteDateMidnight.isAtSameMomentAs(yesterday)) {
//         return 'yesterday'.tr;
//       } else if (noteDate.year == now.year) {
//         return DateFormat('MMMM d', Get.locale.toString()).format(noteDate);
//       } else {
//         return DateFormat('MMMM d, y', Get.locale.toString()).format(noteDate);
//       }
//     } catch (e) {
//       return 'earlier'.tr;
//     }
//   }

//   Future<void> shareNote({
//     required String title,
//     required String content,
//     required List<File> selectedImages,
//     required ShareMode mode,
//   }) async {
//     try {
//       final String shareTitle = title.trim().isEmpty ? "Untitled Note" : title.trim();
//       final String shareContent = content.trim();
//       final String fullMessage = "$shareTitle\n$shareContent";

//       if (mode == ShareMode.photo) {
//         if (selectedImages.isNotEmpty) {
//           final List<XFile> xFiles = selectedImages.where((f) => f.existsSync()).map((f) => XFile(f.path)).toList();
//           SharePlus.instance.share(ShareParams(files: xFiles));
//         } else {
//           Get.snackbar("Info", "No photos found in this note to share.");
//         }
//       } else if (mode == ShareMode.file) {
//         final Directory tempDir = await getTemporaryDirectory();
//         final String cleanTitle = shareTitle.replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), '');
//         final String fileName = "${cleanTitle.isEmpty ? 'shared_file' : cleanTitle}.txt";
//         final File file = File('${tempDir.path}/$fileName');

//         await file.writeAsString(shareContent);

//         final XFile xFile = XFile(file.path);
//         SharePlus.instance.share(ShareParams(files: [xFile]));
//       } else {
//         SharePlus.instance.share(ShareParams(text: fullMessage, subject: shareTitle));
//       }
//     } catch (e) {
//       Get.snackbar("Share Error", "Could not open share menu", backgroundColor: AppColor().red, colorText: AppColor().white);
//     }
//   }

//   Future<int> getCountForFolder(int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final result = await db.rawQuery(
//         'SELECT COUNT(*) as count FROM notes WHERE folder_id = ? AND is_deleted = 0',
//         [folderId],
//       );
//       return Sqflite.firstIntValue(result) ?? 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   Future<void> updateNote(NoteModel note) async {
//     try {
//       final db = await DatabaseService.db;
//       var noteMap = note.toMap();
//       noteMap['is_synced'] = 0;
//       noteMap['updated_at'] = DateTime.now().toIso8601String();

//       await db.update(
//         'notes',
//         noteMap,
//         where: 'id = ?',
//         whereArgs: [note.id],
//       );
//       _triggerFirebasePushDebounce();
//     } catch (e) {
//       debugPrint("Error updating note: $e");
//     }
//   }

//   Future<void> fetchAllNotes() async {
//     isLoading.value = true;
//     try {
//       final db = await DatabaseService.db;
//       final maps = await db.query('notes', orderBy: 'id DESC');
//       notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
//     } catch (e) {
//       debugPrint("Error fetching all notes: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void refreshNotes(int folderId) {
//     fetchNotesByFolder(folderId);
//   }

//   Future<bool> hasLockedNotesInFolder(int folderId) async {
//     try {
//       final db = await DatabaseService.db;
//       final result = await db.rawQuery(
//         'SELECT COUNT(*) as count FROM notes WHERE folder_id = ? AND is_locked = 1',
//         [folderId],
//       );
//       int count = Sqflite.firstIntValue(result) ?? 0;
//       return count > 0;
//     } catch (e) {
//       debugPrint("Error checking for locked notes: $e");
//       return false;
//     }
//   }

//   // 🛡️ មុខងារធ្វើសមកាលកម្មដោយដៃ (Manual Sync) តាមរយៈ Gmail
//   Future<void> syncDataAction(int currentFolderId) async {
//     if (isSyncing.value) return;

//     // ត្រួតពិនិត្យថាបាន Login ជាមួយ Gmail រួចរាល់ហើយឬនៅ
//     if (userId.isEmpty) {
//       Get.snackbar("Sync Info", "Please login with Google Account to sync your data.", snackPosition: SnackPosition.BOTTOM);
//       return;
//     }

//     isSyncing.value = true;
//     try {
//       // 1. រុញទិន្នន័យពី Local ទៅកាន់ Firebase (បោះទាំង UID និង Email ទៅការពារ Virtual Doc)
//       await _syncService.pushLocalChangesToFirebase(userId, userEmail);

//       // 2. ទាញទិន្នន័យពី Firebase មកវិញ (បងអាចរក្សាទុកម៉ោងចុងក្រោយក្នុង GetStorage ដើម្បីកុំឲ្យទាញជាន់គ្នា)
//       String lastSync = '2000-01-01T00:00:00.000Z';
//       await _syncService.pullChangesFromFirebase(userId, lastSync);

//       // 3. Update ផ្ទាំង UI ឡើវិញ
//       await fetchNotesByFolder(currentFolderId);

//       Get.snackbar("Sync Success", "Your notes are up to date.", snackPosition: SnackPosition.BOTTOM);
//     } catch (e) {
//       debugPrint("❌ Action Sync Error: $e");
//     } finally {
//       isSyncing.value = false;
//     }
//   }
// }
