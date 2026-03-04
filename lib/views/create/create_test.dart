import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/components/background_component.dart';
import 'package:project_structure/views/create/components/format_component.dart';
import 'package:project_structure/views/create/components/media_component.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:share_plus/share_plus.dart';

class CreateNoteScreen extends StatefulWidget {
  final bool isEditing;
  final int? noteKey;
  final Map? existingNote;
  final dynamic folderKey;

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

  // Formatting & Media State
  bool isBold = false;
  bool isItalic = false;
  bool isUnderlined = false;
  bool isStrikethrough = false;
  Color selectedColor = Colors.black;
  Color noteBgColor = Colors.white;
  List<File> selectedImages = [];

  // Track current folder selection in state
  dynamic currentFolderKey;
  int _lastTextLength = 0;

  @override
  void initState() {
    super.initState();
    // 1. Initialize the folder key from widget props (IMPORTANT)
    currentFolderKey = widget.folderKey;

    titleController = TextEditingController(text: widget.existingNote?['title'] ?? "");
    contentController = TextEditingController(text: widget.existingNote?['subtitle'] ?? "");
    _lastTextLength = contentController.text.length;

    if (widget.isEditing && widget.existingNote != null) {
      isBold = widget.existingNote?['isBold'] ?? false;
      isItalic = widget.existingNote?['isItalic'] ?? false;
      isUnderlined = widget.existingNote?['isUnderlined'] ?? false;
      isStrikethrough = widget.existingNote?['isStrikethrough'] ?? false;
      noteBgColor = Color(widget.existingNote?['bgColorValue'] ?? 0xFFFFFFFF);

      // If editing, use the folder key saved in the note data
      currentFolderKey = widget.existingNote?['folderKey'] ?? widget.folderKey;

      List<dynamic>? imagePaths = widget.existingNote?['images'];
      if (imagePaths != null) {
        selectedImages = imagePaths.map((path) => File(path)).toList();
      }

      int? colorVal = widget.existingNote?['colorValue'];
      if (colorVal != null) selectedColor = Color(colorVal);
    }

    contentController.addListener(_handleAutoNumbering);
  }

  @override
  void dispose() {
    contentController.removeListener(_handleAutoNumbering);
    contentController.dispose();
    titleController.dispose();
    super.dispose();
  }

  // --- LOGIC: MOVE FOLDER BOTTOM SHEET ---
  void _showMoveFolderSheet() {
    final folderBox = Hive.box('folders_box');
    final List<MapEntry<dynamic, dynamic>> folders = folderBox.toMap().entries.toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Move to Folder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  bool isSelected = currentFolderKey == folder.key;

                  // FIXED: Changed 'name' to 'title' to match your Hive storage key
                  String folderTitle = folder.value['title'] ?? "Unnamed Folder";

                  return ListTile(
                    leading: Icon(Icons.folder, color: isSelected ? AppColor().primaryColor : Colors.grey),
                    title: Text(folderTitle),
                    trailing: isSelected ? Icon(Icons.check_circle, color: AppColor().primaryColor) : null,
                    onTap: () {
                      setState(() => currentFolderKey = folder.key);
                      Navigator.pop(context);
                      Get.snackbar("Success", "Note will be saved to $folderTitle", snackPosition: SnackPosition.BOTTOM);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC: SAVE NOTE TO HIVE ---
  void _saveNote() async {
    if (titleController.text.trim().isEmpty && contentController.text.trim().isEmpty && selectedImages.isEmpty) {
      Get.back();
      return;
    }

    final noteBox = Hive.box('student_notes');

    final noteData = {
      "title": titleController.text,
      "subtitle": contentController.text,
      "folderKey": currentFolderKey, // Saving the updated folder key here
      "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "isPinned": widget.existingNote?['isPinned'] ?? false,
      "isBold": isBold,
      "isItalic": isItalic,
      "isUnderlined": isUnderlined,
      "isStrikethrough": isStrikethrough,
      "colorValue": selectedColor.value,
      "bgColorValue": noteBgColor.value,
      "images": selectedImages.map((file) => file.path).toList(),
    };

    if (widget.isEditing && widget.noteKey != null) {
      await noteBox.put(widget.noteKey, noteData);
      Get.snackbar("Updated", "Note saved successfully", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      await noteBox.add(noteData);
      Get.snackbar("Success", "Note created", backgroundColor: AppColor().primaryColor, colorText: Colors.white);
    }
    Get.back();
  }

  // --- MENU HANDLER ---
  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'Share':
        _shareNote();
        break;
      case 'Move Folder':
        _showMoveFolderSheet();
        break;
      case 'Lock':
        Get.snackbar("Locked", "Note protection enabled", snackPosition: SnackPosition.BOTTOM);
        break;
      case 'Delete':
        showConfirmDeleteDialog(
          context: context,
          title: 'Delete Note',
          subTitle: 'Are you sure you want to delete this note?',
          onConfirm: () {
            if (widget.isEditing && widget.noteKey != null) {
              Hive.box('student_notes').delete(widget.noteKey);
            }
            Get.back(); // Close Dialog
            Get.back(); // Exit Screen
          },
        );
        break;
    }
  }

  void _shareNote() async {
    final String text = "${titleController.text}\n\n${contentController.text}";
    if (selectedImages.isNotEmpty) {
      await Share.shareXFiles(selectedImages.map((e) => XFile(e.path)).toList(), text: text);
    } else {
      await Share.share(text);
    }
  }

  // --- AUTO-NUMBERING & BULLETS ---
  void _handleAutoNumbering() {
    final text = contentController.text;
    if (text.length > _lastTextLength && text.endsWith('\n')) {
      List<String> lines = text.split('\n');
      if (lines.length > 1) {
        String previousLine = lines[lines.length - 2].trimLeft();
        RegExp regExp = RegExp(r'^(\d+)\.\s');
        Match? match = regExp.firstMatch(previousLine);
        if (match != null) {
          int lastNumber = int.parse(match.group(1)!);
          _insertTextAtEnd("${lastNumber + 1}. ");
        } else if (previousLine.startsWith('•')) {
          _insertTextAtEnd("• ");
        }
      }
    }
    _lastTextLength = text.length;
  }

  void _insertTextAtEnd(String insertion) {
    contentController.text = contentController.text + insertion;
    contentController.selection = TextSelection.fromPosition(TextPosition(offset: contentController.text.length));
  }

  void _insertBulletPoint() {
    final text = contentController.text;
    final selection = contentController.selection;
    final String ins = (text.isEmpty || text.endsWith('\n')) ? "• " : "\n• ";
    contentController.text = text.replaceRange(selection.start, selection.end, ins);
    contentController.selection = TextSelection.fromPosition(TextPosition(offset: selection.start + ins.length));
  }

  void _insertNumberedList() {
    final text = contentController.text;
    final selection = contentController.selection;
    final String ins = (text.isEmpty || text.endsWith('\n')) ? "1. " : "\n1. ";
    contentController.text = text.replaceRange(selection.start, selection.end, ins);
    contentController.selection = TextSelection.fromPosition(TextPosition(offset: selection.start + ins.length));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noteBgColor,
      appBar: customAppBar(
        title: widget.isEditing ? "Edit Note" : "Create Note",
        context: context,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (val) => _handleMenuSelection(val, context),
            itemBuilder: (context) => [
              _buildPopupItem('Share', Icons.share_outlined),
              _buildPopupItem('Lock', Icons.lock_outline),
              _buildPopupItem('Move Folder', Icons.folder_outlined),
              _buildPopupItem('Delete', Icons.delete_outline, color: Colors.red),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (selectedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12, top: 10),
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(image: FileImage(selectedImages[index]), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => selectedImages.removeAt(index)),
                          child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  _bottomIcon(Icons.image_outlined, () => showMediaSheet(context: context, onImageSelected: (img) => setState(() => selectedImages.add(img)))),
                  _bottomIcon(
                      Icons.text_fields,
                      () => showFormatSheet(
                            context: context,
                            isBold: isBold,
                            isItalic: isItalic,
                            isUnderlined: isUnderlined,
                            isStrikethrough: isStrikethrough,
                            selectedColor: selectedColor,
                            onBoldChanged: (v) => setState(() => isBold = v),
                            onItalicChanged: (v) => setState(() => isItalic = v),
                            onUnderlineChanged: (v) => setState(() => isUnderlined = v),
                            onStrikethroughChanged: (v) => setState(() => isStrikethrough = v),
                            onColorChanged: (v) => setState(() => selectedColor = v),
                            onBulletPressed: _insertBulletPoint,
                            onNumberedPressed: _insertNumberedList,
                          )),
                  _bottomIcon(Icons.palette_outlined, () => showPaletteSheet(context: context, selectedColor: noteBgColor, onColorSelected: (c) => setState(() => noteBgColor = c))),
                ],
              ),
              IconButton(icon: const Icon(Icons.send_outlined, color: Colors.blueAccent, size: 28), onPressed: _saveNote),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomIcon(IconData icon, VoidCallback onPressed) => IconButton(icon: Icon(icon), onPressed: onPressed);

  PopupMenuItem<String> _buildPopupItem(String title, IconData icon, {Color? color}) => PopupMenuItem<String>(
        value: title,
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.black87, size: 20),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: color ?? Colors.black87)),
          ],
        ),
      );
}
