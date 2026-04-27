import 'package:get/get.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/models/note/folder_model.dart';

class FolderController extends GetxController {
  var folders = <FolderModel>[].obs;

  @override
  void onInit() {
    loadFolders();
    super.onInit();
  }

  Future<void> loadFolders() async {
    final db = await DatabaseService.db;
    final List<Map<String, dynamic>> maps = await db.query('folders', orderBy: 'id DESC');
    folders.assignAll(maps.map((e) => FolderModel.fromMap(e)).toList());
  }

  Future<int> addFolder(String title) async {
    final db = await DatabaseService.db;
    final folder = FolderModel(title: title, date: DateTime.now().toIso8601String());

    // Insert and get ID
    final id = await db.insert('folders', folder.toMap());

    folder.id = id;
    folders.insert(0, folder);
    folders.refresh();

    return id; // Return the ID for navigation
  }

  Future<void> updateFolder(int id, String newTitle) async {
    final db = await DatabaseService.db;
    await db.update('folders', {'title': newTitle}, where: 'id = ?', whereArgs: [id]);

    // Update local list
    int index = folders.indexWhere((f) => f.id == id);
    if (index != -1) {
      folders[index].title = newTitle;
      folders.refresh(); // Tells GetX to redraw
    }
  }

  Future<void> deleteFolder(int id) async {
    final db = await DatabaseService.db;
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);

    // Remove from local list
    folders.removeWhere((f) => f.id == id);
  }
}
