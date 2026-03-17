import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/components/background_component.dart';
import 'package:project_structure/views/create/components/format_component.dart';
import 'package:project_structure/views/create/components/handwriting_component.dart';
import 'package:project_structure/views/create/components/media_component.dart';
import 'package:project_structure/views/create/components/notebook_painter.dart';
import 'package:project_structure/views/create/components/table_component.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/popup_lists_menu.dart';
import 'package:project_structure/widgets/sheet_header.dart';

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
  PaperType selectedPaperType = PaperType.none;

  bool isLocked = false;

  List<Map<String, dynamic>> drawingLayers = [];

  List<File> selectedImages = [];
  int _lastTextLength = 0;
  dynamic currentFolderKey;
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
    noteController.initializeHistory(contentController.text);

    // Load existing styles and background if editing
    if (widget.isEditing && widget.existingNote != null) {
      isBold = widget.existingNote?['isBold'] ?? false;
      isItalic = widget.existingNote?['isItalic'] ?? false;
      isUnderlined = widget.existingNote?['isUnderlined'] ?? false;
      isStrikethrough = widget.existingNote?['isStrikethrough'] ?? false;
      noteBgColor = Color(widget.existingNote?['bgColorValue'] ?? 0xFFFFFFFF);
      int paperIndex = widget.existingNote?['paperTypeIndex'] ?? 0;
      selectedPaperType = PaperType.values[paperIndex];
      isLocked = widget.existingNote?['isLocked'] ?? false;

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

      // Load Multi-Layer Drawing Data with strict casting
      if (widget.existingNote?['drawingLayers'] != null) {
        final List<dynamic> rawLayers = widget.existingNote?['drawingLayers'];
        drawingLayers = rawLayers.map((item) => Map<String, dynamic>.from(item as Map)).toList();
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

        RegExp regExp = RegExp(r'^(\d+)\.\s');
        Match? match = regExp.firstMatch(previousLine);

        if (match != null) {
          int lastNumber = int.parse(match.group(1)!);
          String nextNumberPrefix = "${lastNumber + 1}. ";
          _insertTextAtEnd(nextNumberPrefix);
        } else if (previousLine.startsWith('•')) {
          _insertTextAtEnd("• ");
        } else if (previousLine.startsWith('-')) {
          _insertTextAtEnd("- ");
        }
      }
    }
    _lastTextLength = text.length;
  }

  void _openHandwriting() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HandwritingCanvas(
        initialLayers: drawingLayers,
        onSave: (String? filePath, List<Map<String, dynamic>> layers) {
          setState(() {
            drawingLayers = layers;
            selectedImages.removeWhere((file) => file.path.contains('draw_'));
            if (filePath != null) selectedImages.add(File(filePath));
          });
        },
      ),
    );
  }

  Widget _paperStyleTile(String title, IconData icon, PaperType type) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selectedPaperType == type ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        setState(() => selectedPaperType = type);
        Navigator.pop(context);
      },
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

  Future<void> _handleLockToggle() async {
    try {
      if (!Hive.isBoxOpen('settings_box')) {
        await Hive.openBox('settings_box');
      }

      final settingsBox = Hive.box('settings_box');
      String? masterPass = settingsBox.get('master_password');

      // Case 1: Set new password if none exists
      if (masterPass == null) {
        final result = await Get.to(() => const CreatePasswordScreen());
        if (result == true) {
          setState(() => isLocked = true);
          Get.snackbar("Security", "Master password set and note locked.");
        }
        return;
      }

      // Case 2: Toggle off (requires password)
      if (isLocked) {
        _showUnlockDialog(masterPass);
      }
      // Case 3: Toggle on
      else {
        setState(() => isLocked = true);
        Get.snackbar("Locked", "Note is now protected.");
      }
    } catch (e) {
      Get.snackbar("Error", "Could not access security settings.");
    }
  }

  void _showUnlockDialog(String correctPass) {
    final passController = TextEditingController();

    showConfirmDialog(
      context: context,
      title: "Unlock Note",
      subTitle: "Enter Master Password",
      confirmText: "Unlock",
      controller: passController,
      obscureText: true,
      hintText: "Master Password",
      onConfirm: () {
        if (passController.text == correctPass) {
          setState(() => isLocked = false);
        } else {
          Get.snackbar(
            "Error",
            "Wrong Password",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
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
      "isLocked": isLocked,
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
      "paperTypeIndex": selectedPaperType.index,
      "drawingLayers": drawingLayers,
    };

    Get.back();

    if (widget.isEditing && widget.noteKey != null) {
      await noteBox.put(widget.noteKey, noteData);
      Get.snackbar("Updated", "Note saved successfully", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } else {
      await noteBox.add(noteData);
      Get.snackbar("Success", "Note created", backgroundColor: AppColor().primaryColor, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }

    Get.back();
  }

  //  FORMATTING
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
          if (isLocked) Icon(Icons.lock_outline, color: AppColor().primaryColor, size: 20),
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
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor().primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                Icons.more_vert_outlined,
                color: AppColor().primaryColor,
                size: 20,
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            offset: const Offset(0, 50),
            color: Theme.of(context).cardColor,
            onSelected: (value) => _handleMenuSelection(value, context),
            itemBuilder: (context) => [
              buildPopupItem(context, 'Share', Icons.share_outlined),
              buildPopupItem(context, isLocked ? 'Unlock Note' : 'Lock Note', isLocked ? Icons.lock_open : Icons.lock_outline),
              buildPopupItem(context, 'Move Note', Icons.folder_outlined),
              buildPopupItem(context, 'Delete', Icons.delete_outline, color: Colors.red),
            ],
          ),
        ],
      ),
      body: CustomPaint(
        painter: NotebookPainter(
          type: selectedPaperType,
          lineColor: const Color(0x339E9E9E),
        ),
        child: Padding(
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
                  Builder(
                    builder: (context) {
                      final photoFiles = selectedImages.where((file) => !file.path.contains('draw_')).toList();
                      if (photoFiles.isEmpty) return const SizedBox();

                      return SizedBox(
                        height: context.isPhone ? 120 : 150,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          scrollDirection: Axis.horizontal,
                          itemCount: photoFiles.length,
                          itemBuilder: (context, index) {
                            final file = photoFiles[index];
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 12, top: 10, left: 10),
                                  width: context.isPhone ? 100 : 130,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImages.remove(file);
                                      });
                                    },
                                    child: CircleAvatar(
                                      radius: context.isPhone ? 13 : 16,
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.close, size: context.isPhone ? 20 : 24, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                TextField(
                  controller: contentController,
                  maxLines: null,
                  style: TextStyle(
                    fontSize: context.isPhone ? 16 : 18,
                    height: 1.78,
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
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
                      _bottomIcon(Icons.mode_outlined, _openHandwriting),
                      _bottomIcon(Icons.grid_3x3, _showPaperStyleSheet),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: AppColor().primaryColor, size: context.isPhone ? 24 : 30),
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
      case 'Lock Note':
      case 'Unlock Note':
        _handleLockToggle();
        break;
      case 'Move Note':
        _showMoveFolderSheet();
        break;
      case 'Delete':
        await _deleteCurrentNote();
        break;
    }
  }

  void _showPaperStyleSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            const SheetHeader(title: "Paper Style"),
            _paperStyleTile("Blank", Icons.not_interested, PaperType.none),
            _paperStyleTile("Standard Lines", Icons.reorder, PaperType.lines),
            _paperStyleTile("College Ruled", Icons.format_line_spacing, PaperType.collegeRuled),
            _paperStyleTile("Standard Grid", Icons.grid_3x3, PaperType.grid),
            _paperStyleTile("Small Graph", Icons.grid_on, PaperType.engineering),
            _paperStyleTile("Dot Matrix", Icons.more_horiz, PaperType.dots),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showMoveFolderSheet() {
    final folderBox = Hive.box('folders_box');
    final List<MapEntry<dynamic, dynamic>> folders = folderBox.toMap().entries.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
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

  Future<void> _deleteCurrentNote() async {
    await showConfirmDialog(
      context: context,
      title: 'Delete Note',
      subTitle: 'Are you sure you want to delete this note and all its attachments?',
      confirmText: "Delete",
      onConfirm: () {
        // Delegate logic to controller
        noteController.deleteNote(
          noteKey: widget.noteKey,
          images: selectedImages,
          onSuccess: () {
            if (Get.isOverlaysOpen) Get.back();
            Get.back();
          },
        );
      },
    );
  }

  Widget _bottomIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Theme.of(context).iconTheme.color, size: context.isPhone ? 20 : 30),
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
