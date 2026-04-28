import 'package:get/get.dart';
import 'package:hive/hive.dart';

class RecentlyDeletedController extends GetxController {
  final Box _trashBox = Hive.box('recently_deleted');

  // Get all deleted notes
  List get deletedNotes => _trashBox.values.toList();

  // Restore Note
  void restoreNote(int index) async {
    var noteData = _trashBox.getAt(index);
    
    // TODO: Insert noteData back into your SQLite Database
    // await DatabaseService.insert('notes', noteData);
    
    await _trashBox.deleteAt(index);
    update();
    Get.snackbar("Restored", "Note moved back to folders");
  }

  // Delete Permanently
  void deletePermanently(int index) async {
    await _trashBox.deleteAt(index);
    update();
  }

  // Empty Trash
  void clearAll() async {
    await _trashBox.clear();
    update();
  }
}