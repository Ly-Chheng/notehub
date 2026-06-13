import 'package:get/get.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/models/home/folder_model.dart';

class FolderController extends GetxController {
  var folders = <FolderModel>[].obs;
  var searchQuery = ''.obs;

  final String defaultFolderName = "My Note";

  @override
  void onInit() {
    super.onInit();
    loadFolders();
  }
  
  int get defaultFolderId {
    return folders
        .firstWhere(
          (f) => f.title == defaultFolderName,
          orElse: () => folders.first,
        )
        .id!;
  }

  Future<void> loadFolders() async {
    final db = await DatabaseService.db;

    final List<Map<String, dynamic>> maps = await db.query('folders', orderBy: 'id DESC');

    if (maps.isEmpty) {
      await _createDefaultFolder();
      return;
    }

    folders.assignAll(maps.map((e) => FolderModel.fromMap(e)).toList());

    bool hasDefault = folders.any((folder) => folder.title == defaultFolderName);

    if (!hasDefault) {
      await _createDefaultFolder();
    } else {
      _sortFolders();
    }
  }

  // Create default folder
  Future<void> _createDefaultFolder() async {
    final db = await DatabaseService.db;

    final defaultFolder = FolderModel(
      title: defaultFolderName,
      date: DateTime.now().toIso8601String(),
    );

    final id = await db.insert('folders', defaultFolder.toMap());

    defaultFolder.id = id;

    folders.insert(0, defaultFolder);
    folders.refresh();
  }

  // Add new folder
  Future<int> addFolder(String title) async {
    final db = await DatabaseService.db;

    final folder = FolderModel(
      title: title,
      date: DateTime.now().toIso8601String(),
    );

    final id = await db.insert('folders', folder.toMap());

    folder.id = id;
    folders.add(folder);

    _sortFolders();

    return id;
  }

  //  Update folder (prevent default)
  Future<void> updateFolder(int id, String newTitle) async {
    int index = folders.indexWhere((f) => f.id == id);
    if (index == -1) return;

    if (folders[index].title == defaultFolderName) return;

    final db = await DatabaseService.db;

    await db.update(
      'folders',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [id],
    );

    folders[index].title = newTitle;
    folders.refresh();
  }

  // Delete folder (prevent default)
  Future<void> deleteFolder(int id) async {
    int index = folders.indexWhere((f) => f.id == id);
    if (index == -1) return;

    if (folders[index].title == defaultFolderName) return;

    final db = await DatabaseService.db;

    await db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );

    folders.removeAt(index);
  }

  // Check default
  bool isDefaultFolder(FolderModel folder) {
    return folder.title == defaultFolderName;
  }

  Future<void> togglePin(int folderId) async {
    int index = folders.indexWhere((f) => f.id == folderId);
    if (index == -1) return;

    final folder = folders[index];

    if (folder.title == defaultFolderName) return;

    folders[index].isPinned = !folders[index].isPinned;

    // Save to database
    final db = await DatabaseService.db;
    await db.update(
      'folders',
      {'isPinned': folders[index].isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [folderId],
    );

    _sortFolders();
  }

  void _sortFolders() {
    folders.sort((a, b) {
      if (a.title == defaultFolderName) return -1;
      if (b.title == defaultFolderName) return 1;

      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      return (b.id ?? 0).compareTo(a.id ?? 0);
    });

    folders.refresh();
  }

  Future<void> toggleLock(int folderId) async {
    int index = folders.indexWhere((f) => f.id == folderId);
    if (index == -1) return;

    if (folders[index].title == defaultFolderName) return;

    folders[index].isLocked = !folders[index].isLocked;

    final db = await DatabaseService.db;
    await db.update(
      'folders',
      {'isLocked': folders[index].isLocked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [folderId],
    );

    _sortFolders();
  }

  Future<void> moveNote(int noteId, int newFolderId) async {
    final db = await DatabaseService.db;

    await db.update(
      'notes',
      {'folder_id': newFolderId},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // Inside FolderController class
  Future<void> clearAllFolderLocks() async {
    final db = await DatabaseService.db;

    await db.update(
      'folders',
      {'isLocked': 0},
    );

    for (var folder in folders) {
      folder.isLocked = false;
    }

    folders.refresh();
  }

  Future<void> forceUnlockAll() async {
    final db = await DatabaseService.db;

    await db.update('folders', {'isLocked': 0});

    for (var f in folders) {
      f.isLocked = false;
    }
    folders.refresh();
  }

  void searchFolders(String query) {
    searchQuery.value = query;
  }

  List<FolderModel> get filteredFolders {
    if (searchQuery.isEmpty) {
      return folders;
    }
    return folders.where((folder) => folder.title.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
  }
}
