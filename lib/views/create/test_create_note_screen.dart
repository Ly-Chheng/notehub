import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

// Core Utils & Project Imports
import 'package:project_structure/controllers/notes/test_note_controller.dart';
import 'package:project_structure/models/note/note_model.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/create/components/background_component.dart';
import 'package:project_structure/views/create/components/format_component.dart';

// Components
import 'package:project_structure/views/create/components/quill_editor_component.dart';
import 'package:project_structure/views/create/components/table_component.dart';
import 'package:project_structure/views/create/components/handwriting_component.dart';

// Widgets
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/popup_lists_menu.dart';

class CreateNoteScreen extends StatefulWidget {
  final bool isEditing;
  final NoteModel? existingNote;
  final int folderId;

  const CreateNoteScreen({
    super.key,
    this.isEditing = false,
    this.existingNote,
    required this.folderId,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final NoteController noteController = Get.find<NoteController>();
  late TextEditingController titleController;
  late QuillController _quillController;
  late FocusNode _editorFocusNode;

  Timer? _autoSaveTimer;
  late bool isEditingMode;
  int? currentNoteId;

  // State Variables
  Color? noteBgColor;
  bool isLocked = false;
  bool isPinned = false;
  bool showTable = false;
  List<File> selectedImages = [];
  List<List<String>> tableData = [
    ["", ""],
    ["", ""]
  ];
  List<Map<String, dynamic>> drawingLayers = [];

  @override
  void initState() {
    super.initState();
    _editorFocusNode = FocusNode();
    isEditingMode = widget.isEditing;
    currentNoteId = widget.existingNote?.id;

    // Load existing data if editing
    if (isEditingMode && widget.existingNote != null) {
      final note = widget.existingNote!;
      titleController = TextEditingController(text: note.title);
      isPinned = note.isPinned;
      isLocked = note.isLocked;
      noteBgColor = note.bgColor != 0 ? Color(note.bgColor) : null;
      showTable = note.showTable;
      tableData = List<List<String>>.from(note.tableData.map((e) => List<String>.from(e)));
      drawingLayers = List<Map<String, dynamic>>.from(note.drawingLayers);
      selectedImages = note.imagePaths.map((path) => File(path)).toList();

      try {
        var content = jsonDecode(note.content);
        _quillController = QuillController(
          document: Document.fromJson(content),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _quillController = QuillController.basic();
      }
    } else {
      titleController = TextEditingController();
      _quillController = QuillController.basic();
    }

    titleController.addListener(_triggerAutoSave);
    _quillController.addListener(_triggerAutoSave);
  }

  // --- Logic Methods ---

  void _triggerAutoSave() {
    if (_autoSaveTimer?.isActive ?? false) _autoSaveTimer!.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () => _saveNote(isAuto: true));
  }

  Future<void> _saveNote({required bool isAuto}) async {
    final String title = titleController.text.trim();
    final bool isDocEmpty = _quillController.document.isEmpty();

    if (title.isEmpty && isDocEmpty && selectedImages.isEmpty && !showTable && drawingLayers.isEmpty) {
      return;
    }

    final String contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    final int? savedId = await noteController.saveNoteSQLite(
      id: currentNoteId,
      folderId: widget.folderId,
      title: title,
      contentJson: contentJson,
      isLocked: isLocked,
      isPinned: isPinned,
      bgColor: noteBgColor?.value ?? 0,
      imagePaths: selectedImages.map((f) => f.path).toList(),
      showTable: showTable,
      tableData: tableData,
      drawingLayers: drawingLayers,
    );

    if (savedId != null && !isEditingMode) {
      setState(() {
        currentNoteId = savedId;
        isEditingMode = true;
      });
    }

    if (!isAuto) Get.back();
  }

  void _forceUnfocus() {
    _editorFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // --- Bottom Sheet Openers ---

  void _openPalette() {
    _forceUnfocus();
    showPaletteSheet(
      context: context,
      selectedColor: noteBgColor ?? Theme.of(context).scaffoldBackgroundColor,
      onColorSelected: (color) {
        setState(() => noteBgColor = color);
        _triggerAutoSave();
      },
    );
  }

  void _openFormatting() {
    _forceUnfocus();
    final attributes = _quillController.getSelectionStyle().attributes;

    showFormatSheet(
      context: context,
      isBold: attributes.containsKey(Attribute.bold.key),
      isItalic: attributes.containsKey(Attribute.italic.key),
      isUnderlined: attributes.containsKey(Attribute.underline.key),
      isStrikethrough: attributes.containsKey(Attribute.strikeThrough.key),
      selectedColor: Colors.black,
      selectedHighlightColor: Colors.yellow,
      onBoldChanged: (v) => _quillController.formatSelection(v ? Attribute.bold : Attribute.clone(Attribute.bold, null)),
      onItalicChanged: (v) => _quillController.formatSelection(v ? Attribute.italic : Attribute.clone(Attribute.italic, null)),
      onUnderlineChanged: (v) => _quillController.formatSelection(v ? Attribute.underline : Attribute.clone(Attribute.underline, null)),
      onStrikethroughChanged: (v) => _quillController.formatSelection(v ? Attribute.strikeThrough : Attribute.clone(Attribute.strikeThrough, null)),
      onColorChanged: (c) => _quillController.formatSelection(ColorAttribute('#${c.value.toRadixString(16).substring(2)}')),
      onHighlightColorChanged: (c) => _quillController.formatSelection(BackgroundAttribute('#${c.value.toRadixString(16).substring(2)}')),
      onBulletPressed: () => _quillController.formatSelection(Attribute.ul),
      onNumberedPressed: () => _quillController.formatSelection(Attribute.ol),
      onHyphenPressed: () => _quillController.formatSelection(Attribute.blockQuote),
      isLeftAligned: attributes[Attribute.align.key]?.value == 'left',
      isCenterAligned: attributes[Attribute.align.key]?.value == 'center',
      isRightAligned: attributes[Attribute.align.key]?.value == 'right',
      isJustifyAligned: attributes[Attribute.align.key]?.value == 'justify',
      onLeftAlignPressed: () => _quillController.formatSelection(Attribute.leftAlignment),
      onCenterAlignPressed: () => _quillController.formatSelection(Attribute.centerAlignment),
      onRightAlignPressed: () => _quillController.formatSelection(Attribute.rightAlignment),
      onJustifyAlignPressed: () => _quillController.formatSelection(Attribute.justifyAlignment),
      onFontSizeChanged: (s) {},
    );
  }

  void _openDrawing() {
    _forceUnfocus();
    Get.bottomSheet(
      HandwritingCanvas(
        initialLayers: drawingLayers,
        onSave: (path, layers) {
          setState(() {
            drawingLayers = layers;
            if (path != null) selectedImages.add(File(path));
          });
          _triggerAutoSave();
        },
      ),
      isScrollControlled: true,
    );
  }

  // --- Main UI Build ---

  @override
  Widget build(BuildContext context) {
    final Color effectiveBg = noteBgColor ?? Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = (effectiveBg.computeLuminance() > 0.5) ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: effectiveBg,
      appBar: customAppBar(
        context: context,
        title: isEditingMode ? "Edit Note" : "Create Note",
        leadingColor: textColor,
        actions: [
          if (isLocked) Icon(Icons.lock_outline, color: textColor),
          IconButton(
            icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: textColor),
            onPressed: () {
              setState(() => isPinned = !isPinned);
              _triggerAutoSave();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              buildPopupItem(context, 'Share', Icons.share_outlined),
              buildPopupItem(context, isLocked ? 'Unlock' : 'Lock', Icons.lock_outline),
              buildPopupItem(context, 'Delete', Icons.delete_outline, color: AppColor().red),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _forceUnfocus,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                maxLines: null,
                style: text22(context).copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
                  border: InputBorder.none,
                ),
              ),
              QuillEditorComponent(
                controller: _quillController,
                focusNode: _editorFocusNode,
                textColor: textColor,
              ),
              if (showTable)
                EditableTableComponent(
                  tableData: tableData,
                  noteBgColor: effectiveBg,
                  onCellChanged: (r, c, v) {
                    tableData[r][c] = v;
                    _triggerAutoSave();
                  },
                  onAddRow: () => setState(() {
                    tableData.add(List.generate(tableData[0].length, (_) => ""));
                    _triggerAutoSave();
                  }),
                  onAddColumn: () => setState(() {
                    for (var r in tableData) r.add("");
                    _triggerAutoSave();
                  }),
                  onRemoveRow: (i) => setState(() {
                    if (tableData.length > 1) tableData.removeAt(i);
                    _triggerAutoSave();
                  }),
                  onRemoveColumn: (i) => setState(() {
                    for (var r in tableData) if (r.length > 1) r.removeAt(i);
                    _triggerAutoSave();
                  }),
                  onDeleteTable: () => setState(() {
                    showTable = false;
                    _triggerAutoSave();
                  }),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomToolbar(textColor),
    );
  }

  Widget _buildBottomToolbar(Color iconColor) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.text_fields, color: iconColor), onPressed: _openFormatting),
            IconButton(icon: Icon(Icons.palette_outlined, color: iconColor), onPressed: _openPalette),
            IconButton(
              icon: Icon(Icons.table_chart_outlined, color: iconColor),
              onPressed: () {
                setState(() => showTable = !showTable);
                _triggerAutoSave();
              },
            ),
            IconButton(icon: Icon(Icons.mode_outlined, color: iconColor), onPressed: _openDrawing),
            IconButton(icon: Icon(Icons.check, color: AppColor().primaryColor), onPressed: () => _saveNote(isAuto: false)),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    if (value == 'Lock') {
      setState(() => isLocked = !isLocked);
      _triggerAutoSave();
    } else if (value == 'Delete') {
      // Handle delete
      Get.back();
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }
}
