import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/components/background_component.dart';
import 'package:project_structure/views/create/components/format_component.dart';
import 'package:project_structure/views/create/components/handwriting_component.dart';
import 'package:project_structure/views/create/components/media_component.dart';
import 'package:project_structure/views/create/components/table_component.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/sheet_header.dart';
import 'package:signature/signature.dart';

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
  final NoteController noteController = Get.put(NoteController());
  late TextEditingController titleController;
  late TextEditingController contentController;

  // Formatting State
  bool isBold = false;
  bool isItalic = false;
  bool isUnderlined = false;
  bool isStrikethrough = false;
  Color selectedColor = Colors.black;
  Color noteBgColor = Colors.white;
  List<File> selectedImages = []; // List to hold picked images

  int _lastTextLength = 0;

  // Track current folder selection in state
  dynamic currentFolderKey;

  // --- TABLE STATE ---
  bool showTable = false;
  List<List<String>> tableData = [
    ["", ""],
    ["", ""],
  ];

  @override
  void initState() {
    super.initState();

    currentFolderKey = widget.folderKey;

    titleController = TextEditingController(text: widget.existingNote?['title'] ?? "");
    contentController = TextEditingController(text: widget.existingNote?['subtitle'] ?? "");
    _lastTextLength = contentController.text.length;
    // Initialize the history with current content
    noteController.initializeHistory(contentController.text);

    // Load existing styles and background if editing
    if (widget.isEditing && widget.existingNote != null) {
      isBold = widget.existingNote?['isBold'] ?? false;
      isItalic = widget.existingNote?['isItalic'] ?? false;
      isUnderlined = widget.existingNote?['isUnderlined'] ?? false;
      isStrikethrough = widget.existingNote?['isStrikethrough'] ?? false;
      noteBgColor = Color(widget.existingNote?['bgColorValue'] ?? 0xFFFFFFFF);

      // If editing, use the folder key saved in the note data
      currentFolderKey = widget.existingNote?['folderKey'] ?? widget.folderKey;

      // Load Images from Hive (Strings to Files)
      List<dynamic>? imagePaths = widget.existingNote?['images'];
      if (imagePaths != null) {
        selectedImages = imagePaths.map((path) => File(path)).toList();
      }

      // Load Table Data
      showTable = widget.existingNote?['showTable'] ?? false;
      if (widget.existingNote?['tableData'] != null) {
        tableData = List<List<String>>.from(
          (widget.existingNote?['tableData'] as List).map((row) => List<String>.from(row)),
        );
      }

      int? colorVal = widget.existingNote?['colorValue'];
      if (colorVal != null) selectedColor = Color(colorVal);

      if (widget.existingNote?['drawingPoints'] != null) {
        savedPoints = (widget.existingNote?['drawingPoints'] as List).map((p) {
          return Point(
            Offset(p['x'], p['y']),
            PointType.values[p['t']],
            1.0,
          );
        }).toList();
      }
    }

    contentController.addListener(_handleAutoNumbering);

    // Listen for changes to record them in the controller
    contentController.addListener(() {
      noteController.recordChange(contentController.text);
    });
  }

  @override
  void dispose() {
    contentController.removeListener(_handleAutoNumbering);
    contentController.dispose();
    titleController.dispose();
    super.dispose();
  }

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
        } else if (previousLine.startsWith('-')) {
          _insertTextAtEnd("- ");
        }
      }
    }
    _lastTextLength = text.length;
  }

  List<Point>? savedPoints; // Add this variable

  // Modified Handwriting Trigger
  void _openHandwriting() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => HandwritingCanvas(
        initialPoints: savedPoints, // Pass existing points to edit
        onSave: (Uint8List bytes, List<Point> points) async {
          savedPoints = points; // Keep the points for future editing

          // Save image to file as you already do
          final tempDir = await getTemporaryDirectory();
          final file = await File('${tempDir.path}/hw_${DateTime.now().millisecondsSinceEpoch}.png').create();
          await file.writeAsBytes(bytes);

          setState(() => selectedImages.add(file));
        },
      ),
    );
  }

  void _insertTextAtEnd(String insertion) {
    contentController.text = contentController.text + insertion;
    contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: contentController.text.length),
    );
  }

  void _insertDashList() {
    final text = contentController.text;
    final selection = contentController.selection;
    final String insertion = (text.isEmpty || text.endsWith('\n')) ? "- " : "\n- ";
    contentController.text = text.replaceRange(selection.start, selection.end, insertion);
    contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + insertion.length),
    );
  }

  void _saveNote() async {
    // Prevent saving empty notes
    if (titleController.text.trim().isEmpty && contentController.text.trim().isEmpty) {
      Get.back();
      return;
    }

    final noteBox = Hive.box('student_notes');

    final noteData = {
      "title": titleController.text,
      "subtitle": contentController.text,
      "folderKey": currentFolderKey,
      "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "isPinned": widget.existingNote?['isPinned'] ?? false,
      "isBold": isBold,
      "isItalic": isItalic,
      "isUnderlined": isUnderlined,
      "isStrikethrough": isStrikethrough,
      "colorValue": selectedColor.value,
      "bgColorValue": noteBgColor.value,
      "images": selectedImages.map((file) => file.path).toList(),
      "showTable": showTable,
      "tableData": tableData,
      "drawingPoints": savedPoints?.map((p) => {'x': p.offset.dx, 'y': p.offset.dy, 't': p.type.index}).toList(),
    };

    Get.back(); // Close screen

    if (widget.isEditing && widget.noteKey != null) {
      await noteBox.put(widget.noteKey, noteData);
      Get.snackbar("Updated", "Note saved successfully", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } else {
      await noteBox.add(noteData);
      Get.snackbar("Success", "Note created", backgroundColor: AppColor().primaryColor, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }

    Get.back();
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

  void _shareNote() {
    noteController.shareNote(
      title: titleController.text,
      content: contentController.text,
      selectedImages: selectedImages,
    );
  }

  void _setText(String text) {
    contentController.text = text;
    contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
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
          Obx(() => _actionButton(
                asset: 'assets/images/undo.png',
                isEnabled: noteController.undoStack.length > 1,
                onTap: () {
                  final text = noteController.undo();
                  if (text != null) _setText(text);
                },
              )),
          Obx(() => _actionButton(
                asset: 'assets/images/redo.png',
                isEnabled: noteController.redoStack.isNotEmpty,
                onTap: () {
                  final text = noteController.redo();
                  if (text != null) _setText(text);
                },
              )),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            offset: const Offset(0, 50),
            color: Theme.of(context).cardColor,
            onSelected: (value) => _handleMenuSelection(value, context),
            itemBuilder: (context) => [
              _buildPopupItem('Share', Icons.share_outlined),
              _buildPopupItem('Move Note', Icons.folder_outlined),
              _buildPopupItem('Delete', Icons.delete_outline, color: Colors.red),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none),
                style: TextStyle(fontSize: context.isPhone ? 24 : 28, fontWeight: FontWeight.bold),
              ),
              if (selectedImages.isNotEmpty)
                SizedBox(
                  height: context.isPhone ? 120 : 150,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) => Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12, top: 10, left: 10),
                          width: context.isPhone ? 100 : 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: GestureDetector(
                            onTap: () => setState(() => selectedImages.removeAt(index)),
                            child: CircleAvatar(
                              radius: context.isPhone ? 13 : 16,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: context.isPhone ? 20 : 24, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              TextField(
                controller: contentController,
                maxLines: null,
                style: TextStyle(
                  fontSize: context.isPhone ? 18 : 20,
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
              if (showTable)
                EditableTableComponent(
                  tableData: tableData,
                  onCellChanged: (rowIndex, colIndex, value) {
                    tableData[rowIndex][colIndex] = value;
                  },
                  onAddRow: () {
                    setState(() {
                      // Add a new row with the same number of columns as existing rows
                      int currentCols = tableData[0].length;
                      tableData.add(List.generate(currentCols, (_) => ""));
                    });
                  },
                  onRemoveRow: (index) {
                    setState(() {
                      if (tableData.length > 1) {
                        tableData.removeAt(index);
                      } else {
                        showTable = false;
                      }
                    });
                  },
                  onAddColumn: () {
                    setState(() {
                      for (var row in tableData) {
                        row.add("");
                      }
                    });
                  },
                  onRemoveColumn: (colIndex) {
                    setState(() {
                      if (tableData[0].length > 1) {
                        for (var row in tableData) {
                          row.removeAt(colIndex);
                        }
                      } else {
                        Get.snackbar("Warning", "Table must have at least one column");
                      }
                    });
                  },
                  onDeleteTable: () {
                    setState(() {
                      showTable = false;
                      tableData = [
                        ["", ""]
                      ];
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomToolbar(),
    );
  }

  Widget _buildBottomToolbar() {
    return SafeArea(
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
                  _bottomIcon(Icons.image_outlined, () {
                    showMediaSheet(
                      context: context,
                      onImageSelected: (File image) {
                        setState(() => selectedImages.add(image));
                      },
                    );
                  }),
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
                      onHyphenPressed: _insertDashList,
                    );
                  }),
                  _bottomIcon(Icons.palette_outlined, () {
                    showPaletteSheet(
                      context: context,
                      selectedColor: noteBgColor,
                      onColorSelected: (color) => setState(() => noteBgColor = color),
                    );
                  }),
                  _bottomIcon(Icons.table_chart_outlined, () {
                    setState(() => showTable = !showTable);
                  }),
                  _bottomIcon(Icons.mode, _openHandwriting),
                ],
              ),
              IconButton(
                icon: Icon(Icons.send_outlined, color: Colors.blueAccent, size: context.isPhone ? 28 : 33),
                onPressed: _saveNote,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'Share':
        _shareNote();
        break;
      case 'Move Note':
        _showMoveFolderSheet();
        break;
      case 'Delete':
        await showConfirmDeleteDialog(
          context: context,
          title: 'Delete Note',
          subTitle: 'Are you sure you want to delete this note?',
          onConfirm: () async {
            final noteBox = Hive.box('student_notes');

            if (widget.isEditing && widget.noteKey != null) {
              await noteBox.delete(widget.noteKey);
              Get.back();
            }
            Get.close(2);
          },
        );
        break;
    }
  }

  void _showMoveFolderSheet() {
    final folderBox = Hive.box('folders_box');
    final List<MapEntry<dynamic, dynamic>> folders = folderBox.toMap().entries.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(
              title: "Move to Folder",
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  bool isSelected = currentFolderKey == folder.key;

                  String folderTitle = folder.value['title'] ?? "Unnamed Folder";

                  return ListTile(
                    leading: Icon(Icons.folder, color: isSelected ? AppColor().primaryColor : Colors.grey),
                    title: Text(folderTitle),
                    trailing: isSelected ? Icon(Icons.check, color: AppColor().primaryColor) : null,
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

  PopupMenuItem<String> _buildPopupItem(String title, IconData icon, {Color? color}) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: context.isPhone ? 20 : 25),
          SizedBox(width: context.isPhone ? 20 : 25),
          Text(title, style: TextStyle(fontSize: context.isPhone ? 16 : 18)),
        ],
      ),
    );
  }

  Widget _bottomIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Theme.of(context).iconTheme.color, size: context.isPhone ? 24 : 30),
      onPressed: onPressed,
    );
  }

  Widget _actionButton({
    required String asset,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    return IconButton(
      onPressed: isEnabled ? onTap : null,
      icon: Image.asset(
        asset,
        width: 24,
        height: 24,
        color: isEnabled ? AppColor().primaryColor : Colors.grey.shade400,
      ),
    );
  }
}
