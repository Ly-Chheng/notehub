import 'package:get/get.dart';
import 'package:project_structure/controllers/focus_track/stopwatch_controller.dart';
import 'package:project_structure/controllers/home/folder_controller.dart';
import 'package:project_structure/controllers/note/note_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NoteController());
    Get.put(FolderController());
    Get.put(StopwatchController(), permanent: true);
  }
}