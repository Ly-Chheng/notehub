// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:intl/intl.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';

// class CreateNoteScreen extends StatefulWidget {
//   const CreateNoteScreen({super.key});

//   @override
//   State<CreateNoteScreen> createState() => _CreateNoteScreenState();
// }

// class _CreateNoteScreenState extends State<CreateNoteScreen> {
//   final titleController = TextEditingController();
//   final contentController = TextEditingController();

//   // THE LOCAL SAVE FUNCTION
//   void _saveNoteLocally() async {
//     if (titleController.text.isEmpty && contentController.text.isEmpty) {
//       Get.back();
//       return;
//     }

//     // 1. Prepare the data map
//     final newNoteData = {
//       "title": titleController.text.isEmpty ? "Untitled" : titleController.text,
//       "subtitle": contentController.text,
//       "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
//       "hasImage": false,
//       "isLocked": false,
//     };

//     // 2. Add to the local Hive box
//     final box = Hive.box('student_notes');
//     await box.add(newNoteData);

//     // 3. Print success message and go back
//     print("SUCCESS: Note saved to local database!");

//     Get.back(); // Close screen

//     Get.snackbar(
//       "Success",
//       "Note created successfully",
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FB),
//       appBar: customAppBar(
//         title: "Create Note",
//         titleColor: AppColor().primaryColor,
//         context: context,
//         leadingColor: AppColor().primaryColor,
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: Image.asset('assets/images/undo.png', width: 24, height: 24, color: AppColor().primaryColor),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: Image.asset('assets/images/redo.png', width: 24, height: 24, color: AppColor().primaryColor),
//           ),
//           PopupMenuButton<String>(
//             icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             offset: const Offset(0, 50),
//             color: Colors.white,
//             onSelected: (value) => (value, context),
//             itemBuilder: (context) => [],
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none),
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             Expanded(
//               child: TextField(
//                 controller: contentController,
//                 maxLines: null,
//                 decoration: const InputDecoration(hintText: 'Note something down', border: InputBorder.none),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.send_outlined, color: Colors.blueAccent),
//               onPressed: _saveNoteLocally, // TRIGGER SAVE
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//version 2 have create,delete, pinnded, edit
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class CreateNoteScreen extends StatefulWidget {
  final bool isEditing;
  final int? noteKey;
  final Map? existingNote;

  const CreateNoteScreen({super.key, this.isEditing = false, this.noteKey, this.existingNote});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    // Fill text if we are editing
    titleController = TextEditingController(text: widget.existingNote?['title'] ?? "");
    contentController = TextEditingController(text: widget.existingNote?['subtitle'] ?? "");
  }

  void _saveNote() async {
    if (titleController.text.isEmpty && contentController.text.isEmpty) {
      Get.back();
      return;
    }

    final box = Hive.box('student_notes');

    // Data Map
    final noteData = {
      "title": titleController.text,
      "subtitle": contentController.text,
      "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "isPinned": widget.existingNote?['isPinned'] ?? false, // Keep pin status if editing
    };
    Get.back(); // Close screen

    if (widget.isEditing && widget.noteKey != null) {
      // UPDATE: Overwrite at specific index
      await box.putAt(widget.noteKey!, noteData);
      Get.snackbar("Updated", "Note updated successfully", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      // CREATE: Add new
      await box.add(noteData);
      Get.snackbar("Success", "Note created successfully", backgroundColor: Colors.blue, colorText: Colors.white);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(widget.isEditing ? "Edit Note" : "Create Note")),
      appBar: customAppBar(
        title: widget.isEditing ? "Edit Note" : "Create Note",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Image.asset('assets/images/undo.png', width: 24, height: 24, color: AppColor().primaryColor),
          ),
          IconButton(
            onPressed: () {},
            icon: Image.asset('assets/images/redo.png', width: 24, height: 24, color: AppColor().primaryColor),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            offset: const Offset(0, 50),
            color: Colors.white,
            onSelected: (value) => (value, context),
            itemBuilder: (context) => [],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Content...', border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.send_outlined, color: Colors.blueAccent, size: 30),
              onPressed: _saveNote,
            ),
          ],
        ),
      ),
    );
  }
}
