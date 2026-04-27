import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/models/note/note_model.dart';

class NoteController extends GetxController {
  var notes = <NoteModel>[].obs;
  var isLoading = false.obs;

  Future<void> fetchNotesByFolder(int folderId) async {
    isLoading.value = true;
    final db = await DatabaseService.db;
    final maps = await db.query(
      'notes',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'is_pinned DESC, id DESC',
    );
    notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
    isLoading.value = false;
  }

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
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final row = {
      'folder_id': folderId,
      'title': title,
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

    if (id == null) {
      return await db.insert('notes', row);
    } else {
      await db.update('notes', row, where: 'id = ?', whereArgs: [id]);
      return id;
    }
  }

  Future<void> deleteNote(int id, int folderId) async {
    final db = await DatabaseService.db;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    fetchNotesByFolder(folderId);
  }

  Future<void> searchNotes(String query, int folderId) async {
    final db = await DatabaseService.db;
    final maps = await db.query(
      'notes',
      where: 'folder_id = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [folderId, '%$query%', '%$query%'],
    );
    notes.assignAll(maps.map((e) => NoteModel.fromMap(e)).toList());
  }
}