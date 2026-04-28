import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/models/note/note_model.dart';

class NoteController extends GetxController {
  var notes = <NoteModel>[].obs;
  var isLoading = false.obs;

  //   FETCH NOTES
  Future<void> fetchNotesByFolder(int folderId) async {
    isLoading.value = true;
    try {
      final db = await DatabaseService.db;
      final maps = await db.query(
        'notes',
        where: 'folder_id = ?',
        whereArgs: [folderId],
        orderBy: 'is_pinned DESC, id DESC',
      );

      notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
      debugPrint(" Fetched ${notes.length} note(s) from folder ID: $folderId");
    } catch (e, stack) {
      debugPrint(" Error fetching notes: $e");
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
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()); // Better format

    final row = {
      'folder_id': folderId,
      'title': title.isEmpty ? "Untitled" : title,
      'content': contentJson,
      'date': date,
      'is_locked': isLocked ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'bg_color': bgColor,
      'image_paths': jsonEncode(imagePaths),
      'show_table': showTable ? 1 : 0,
      'table_data': jsonEncode(tableData),
      'drawing_layers': jsonEncode(drawingLayers),
    };

    try {
      if (id == null) {
        // CREATE
        final newId = await db.insert('notes', row);
        debugPrint('Note CREATED successfully! New ID = $newId');
        return newId;
      } else {
        // UPDATE
        final rowsAffected = await db.update('notes', row, where: 'id = ?', whereArgs: [id]);
        debugPrint(' Note UPDATED successfully! ID = $id | Rows affected: $rowsAffected');
        return id;
      }
    } catch (e) {
      debugPrint(' Failed to save note: $e');

      rethrow;
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
    } catch (e) {
      debugPrint("Pin Error: $e");
    }
  }

  String getPlainTextFromNote(String? jsonContent) {
    if (jsonContent == null || jsonContent.isEmpty || jsonContent == '[]') {
      return "";
    }
    try {
      final doc = quill.Document.fromJson(jsonDecode(jsonContent));
      return doc.toPlainText().replaceAll('\n', ' ').trim();
    } catch (e) {
      return "";
    }
  }

  String getDateHeader(String dateStr) {
    try {
      DateTime noteDate = DateFormat('dd/MM/yyyy').parse(dateStr);

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
      DateTime noteDateMidnight = DateTime(noteDate.year, noteDate.month, noteDate.day);

      if (noteDateMidnight.isAtSameMomentAs(today)) {
        return "Today";
      } else if (noteDateMidnight.isAtSameMomentAs(yesterday)) {
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
}
