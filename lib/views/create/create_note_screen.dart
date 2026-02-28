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
import 'package:project_structure/views/create/components/format_component.dart';
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

  // Formatting State
  bool isBold = false;
  bool isItalic = false;
  bool isUnderlined = false;
  bool isStrikethrough = false;
  Color selectedColor = Colors.black;
  Color noteBgColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Fill text if we are editing
    titleController = TextEditingController(text: widget.existingNote?['title'] ?? "");
    contentController = TextEditingController(text: widget.existingNote?['subtitle'] ?? "");

    // Load existing styles if editing
    if (widget.isEditing && widget.existingNote != null) {
      isBold = widget.existingNote?['isBold'] ?? false;
      isItalic = widget.existingNote?['isItalic'] ?? false;
      isUnderlined = widget.existingNote?['isUnderlined'] ?? false;
      isStrikethrough = widget.existingNote?['isStrikethrough'] ?? false;
      int? colorVal = widget.existingNote?['colorValue'];
      noteBgColor = Color(widget.existingNote?['bgColorValue'] ?? 0xFFFFFFFF);
      if (colorVal != null) selectedColor = Color(colorVal);
    }
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
      // SAVE STYLES HERE
      "isBold": isBold,
      "isItalic": isItalic,
      "isUnderlined": isUnderlined,
      "isStrikethrough": isStrikethrough,
      "colorValue": selectedColor.value,
      "bgColorValue": noteBgColor.value,
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

  //Format
  void _insertBulletPoint() {
    final text = contentController.text;
    final selection = contentController.selection;

    // Insert "• " at the current cursor position
    final String newText = text.replaceRange(selection.start, selection.end, text.isEmpty ? "• " : "\n• ");

    contentController.text = newText;

    // Move cursor to the end of the bullet point
    contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + (text.isEmpty ? 2 : 3)),
    );
  }

  void _insertNumberedList() {
    final text = contentController.text;
    final selection = contentController.selection;

    // Insert "1. " at the current cursor position
    final String insertion = text.isEmpty ? "1. " : "\n1. ";
    final String newText = text.replaceRange(selection.start, selection.end, insertion);

    contentController.text = newText;

    // Move cursor to the end of the "1. " string
    contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + insertion.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noteBgColor,
      resizeToAvoidBottomInset: true,
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
                style: TextStyle(
                  fontSize: 18,
                  color: selectedColor,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                  // decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
                  decoration: TextDecoration.combine([
                    if (isUnderlined) TextDecoration.underline,
                    if (isStrikethrough) TextDecoration.lineThrough,
                  ]),
                ),
                decoration: const InputDecoration(hintText: 'Content...', border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _bottomIcon(Icons.image_outlined, () {}),
                    _bottomIcon(Icons.text_fields, () {
                      showFormatSheet(
                        context: context,
                        isBold: isBold,
                        isItalic: isItalic,
                        isUnderlined: isUnderlined,
                        isStrikethrough: isStrikethrough,
                        selectedColor: selectedColor,
                        onBoldChanged: (val) => setState(() => isBold = val),
                        onItalicChanged: (val) => setState(() => isItalic = val),
                        onUnderlineChanged: (val) => setState(() => isUnderlined = val),
                        onStrikethroughChanged: (val) => setState(() => isStrikethrough = val),
                        onColorChanged: (val) => setState(() => selectedColor = val),
                        onBulletPressed: _insertBulletPoint,
                        onNumberedPressed: _insertNumberedList,
                      );
                    }),
                    // IconButton(icon: const Icon(Icons.palette_outlined), onPressed: () => showPaletteSheet(context: context, onColorSelected: (c) => setState(() => noteBgColor = c))),
                    _bottomIcon(Icons.palette_outlined, () {
                      showPaletteSheet(
                        context: context,
                        selectedColor: noteBgColor, // Pass current background color here
                        onColorSelected: (color) {
                          setState(() {
                            noteBgColor = color;
                          });
                        },
                      );
                    }),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined, color: Colors.blueAccent),
                  onPressed: _saveNote,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Theme.of(context).iconTheme.color, size: 24),
      onPressed: onPressed,
    );
  }
}
