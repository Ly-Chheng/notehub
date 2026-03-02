import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/components/format_component.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';

class CreateNoteScreen extends StatefulWidget {
  final bool isEditing;
  final int? noteKey;
  final Map? existingNote;
  final dynamic folderKey; // The ID/Key of the folder this note belongs to

  const CreateNoteScreen({
    super.key,
    this.isEditing = false,
    this.noteKey,
    this.existingNote,
    this.folderKey,
  });

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

  // Track length to detect new lines for auto-numbering
  int _lastTextLength = 0;

  @override
  void initState() {
    super.initState();
    // Initialize Controllers
    titleController = TextEditingController(text: widget.existingNote?['title'] ?? "");
    contentController = TextEditingController(text: widget.existingNote?['subtitle'] ?? "");
    _lastTextLength = contentController.text.length;

    // Load existing styles and background if editing
    if (widget.isEditing && widget.existingNote != null) {
      isBold = widget.existingNote?['isBold'] ?? false;
      isItalic = widget.existingNote?['isItalic'] ?? false;
      isUnderlined = widget.existingNote?['isUnderlined'] ?? false;
      isStrikethrough = widget.existingNote?['isStrikethrough'] ?? false;
      noteBgColor = Color(widget.existingNote?['bgColorValue'] ?? 0xFFFFFFFF);

      int? colorVal = widget.existingNote?['colorValue'];
      if (colorVal != null) selectedColor = Color(colorVal);
    }

    // Listener for Auto-numbering and Bullets
    contentController.addListener(_handleAutoNumbering);
  }

  @override
  void dispose() {
    contentController.removeListener(_handleAutoNumbering);
    contentController.dispose();
    titleController.dispose();
    super.dispose();
  }

  // --- LOGIC: AUTO-NUMBERING & BULLETS ---
  void _handleAutoNumbering() {
    final text = contentController.text;

    if (text.length > _lastTextLength && text.endsWith('\n')) {
      List<String> lines = text.split('\n');

      if (lines.length > 1) {
        String previousLine = lines[lines.length - 2].trimLeft();

        // Check for "1. " pattern
        RegExp regExp = RegExp(r'^(\d+)\.\s');
        Match? match = regExp.firstMatch(previousLine);

        if (match != null) {
          int lastNumber = int.parse(match.group(1)!);
          String nextNumberPrefix = "${lastNumber + 1}. ";
          _insertTextAtEnd(nextNumberPrefix);
        }
        // Check for Bullet pattern
        else if (previousLine.startsWith('•')) {
          _insertTextAtEnd("• ");
        }
      }
    }
    _lastTextLength = text.length;
  }

  void _insertTextAtEnd(String insertion) {
    contentController.text = contentController.text + insertion;
    contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: contentController.text.length),
    );
  }

  // --- LOGIC: SAVE NOTE TO HIVE ---
  void _saveNote() async {
    // Prevent saving empty notes
    if (titleController.text.trim().isEmpty && contentController.text.trim().isEmpty) {
      Get.back();
      return;
    }

    final noteBox = Hive.box('student_notes');
    final folderBox = Hive.box('folders_box');

    // DETERMINE FOLDER KEY
    dynamic targetFolderKey = widget.folderKey;

    // If no folderKey passed, default to the first folder (usually "My Note")
    if (targetFolderKey == null) {
      if (folderBox.isNotEmpty) {
        targetFolderKey = folderBox.keys.first;
      } else {
        targetFolderKey = "default_folder"; // Fallback if no folders exist
      }
    }

    final noteData = {
      "title": titleController.text,
      "subtitle": contentController.text,
      "folderKey": targetFolderKey, // Linked to specific folder
      "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "isPinned": widget.existingNote?['isPinned'] ?? false,
      "isBold": isBold,
      "isItalic": isItalic,
      "isUnderlined": isUnderlined,
      "isStrikethrough": isStrikethrough,
      "colorValue": selectedColor.value,
      "bgColorValue": noteBgColor.value,
    };

    Get.back(); // Close screen

    if (widget.isEditing && widget.noteKey != null) {
      // Use put() with the key to overwrite existing entry
      await noteBox.put(widget.noteKey, noteData);
      Get.snackbar("Updated", "Note saved successfully", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } else {
      await noteBox.add(noteData);
      Get.snackbar("Success", "Note created", backgroundColor: AppColor().primaryColor, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }

    Get.back(); // Close the screen
  }

  // --- FORMATTING HELPERS ---
  void _insertBulletPoint() {
    final text = contentController.text;
    final selection = contentController.selection;
    final String insertion = (text.isEmpty || text.endsWith('\n')) ? "• " : "\n• ";
    contentController.text = text.replaceRange(selection.start, selection.end, insertion);
    contentController.selection = TextSelection.fromPosition(TextPosition(offset: selection.start + insertion.length));
  }

  void _insertNumberedList() {
    final text = contentController.text;
    final selection = contentController.selection;
    final String insertion = (text.isEmpty || text.endsWith('\n')) ? "1. " : "\n1. ";
    contentController.text = text.replaceRange(selection.start, selection.end, insertion);
    contentController.selection = TextSelection.fromPosition(TextPosition(offset: selection.start + insertion.length));
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
            onPressed: () {}, // Implement undo logic if needed
            icon: Image.asset('assets/images/undo.png', width: 24, height: 24, color: AppColor().primaryColor),
          ),
          IconButton(
            onPressed: () {}, // Implement redo logic if needed
            icon: Image.asset('assets/images/redo.png', width: 24, height: 24, color: AppColor().primaryColor),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) => _handleMenuSelection(value, context),
            itemBuilder: (context) => [
              _buildPopupItem('Lock', Icons.lock_outline),
              _buildPopupItem('Delete', Icons.delete_outline, color: Colors.red),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
                    _bottomIcon(Icons.palette_outlined, () {
                      showPaletteSheet(
                        context: context,
                        selectedColor: noteBgColor,
                        onColorSelected: (color) => setState(() => noteBgColor = color),
                      );
                    }),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined, color: Colors.blueAccent, size: 28),
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

  PopupMenuItem<String> _buildPopupItem(String title, IconData icon, {Color? color}) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.black87, size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: color ?? Colors.black87, fontSize: 16)),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) async {
    if (value == 'Delete') {
      await showConfirmDeleteDialog(
        context: context,
        title: 'Delete Note',
        subTitle: 'Are you sure you want to delete this note?',
        onConfirm: () {
          Get.back(); // Close dialog
          Get.back(); // Exit screen
        },
      );
    }
  }
}
