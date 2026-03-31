import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/components/background_component.dart';
import 'package:project_structure/views/create/components/format_component.dart';
import 'package:project_structure/views/create/components/handwriting_component.dart';
import 'package:project_structure/views/create/components/image_detail_component.dart';
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

  // Auto-Save Logic
  Timer? _autoSaveTimer;
  bool isAutoSaveEnabled = true;
  late bool isEditingMode;
  late int? currentNoteKey;

  // Formatting State
  bool isBold = false;
  bool isItalic = false;
  bool isUnderlined = false;
  bool isStrikethrough = false;
  Color selectedColor = Colors.black;
  Color? noteBgColor;
  PaperType selectedPaperType = PaperType.none;
  late QuillController _quillController;

  bool isLocked = false;
  late bool isPinned;
  List<Map<String, dynamic>> drawingLayers = [];

  List<File> selectedImages = [];
  dynamic currentFolderKey;
  bool showTable = false;

  List<List<String>> tableData = [
    ["", ""],
    ["", ""],
  ];

  @override
  void initState() {
    super.initState();
    isEditingMode = widget.isEditing;
    currentNoteKey = widget.noteKey;
    currentFolderKey = widget.folderKey;

    isPinned = widget.existingNote?['isPinned'] ?? false;

    titleController = TextEditingController(text: widget.existingNote?['title'] ?? "");

    if (isEditingMode && widget.existingNote != null) {
      final int? savedBgColor = widget.existingNote?['bgColorValue'];
      noteBgColor = savedBgColor != null ? Color(savedBgColor) : null;
    } else {
      noteBgColor = null;
    }

    // Initialize Quill
    if (isEditingMode && widget.existingNote?['subtitle'] != null) {
      try {
        var content = jsonDecode(widget.existingNote!['subtitle']);
        _quillController = QuillController(
          document: Document.fromJson(content),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _quillController = QuillController(
          document: Document()..insert(0, widget.existingNote!['subtitle']),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _quillController = QuillController.basic();
    }

    // Load Existing Metadata
    if (isEditingMode && widget.existingNote != null) {
      noteBgColor = Color(widget.existingNote?['bgColorValue'] ?? 0xFFFFFFFF);
      selectedPaperType = PaperType.values[widget.existingNote?['paperTypeIndex'] ?? 0];
      isLocked = widget.existingNote?['isLocked'] ?? false;

      List<dynamic>? imagePaths = widget.existingNote?['images'];
      if (imagePaths != null) {
        selectedImages = imagePaths.map((path) => File(path)).toList();
      }

      showTable = widget.existingNote?['showTable'] ?? false;
      if (widget.existingNote?['tableData'] != null) {
        tableData = List<List<String>>.from(
          (widget.existingNote?['tableData'] as List).map((row) => List<String>.from(row)),
        );
      }

      if (widget.existingNote?['drawingLayers'] != null) {
        final List<dynamic> rawLayers = widget.existingNote?['drawingLayers'];
        drawingLayers = rawLayers.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    }

    // CRITICAL: Both Title and Body must have the listener for Auto-Save
    titleController.addListener(_triggerAutoSave);
    _quillController.addListener(_triggerAutoSave);
  }

  void _triggerAutoSave() {
    if (!isAutoSaveEnabled) return;
    if (_autoSaveTimer?.isActive ?? false) _autoSaveTimer!.cancel();

    _autoSaveTimer = Timer(const Duration(seconds: 1), () {
      _saveNote(isAuto: true);
    });
  }

  Future<void> _saveNote({required bool isAuto}) async {
    final String currentTitle = titleController.text.trim();
    final bool isDocEmpty = _quillController.document.isEmpty();

    final bool isTableEmpty = tableData.every((row) => row.every((cell) => cell.trim().isEmpty));

    if (isAuto && currentTitle.isEmpty && isDocEmpty && (isTableEmpty || !showTable)) {
      return;
    }

    final noteBox = Hive.box('student_notes');
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    final noteData = {
      "title": currentTitle,
      "subtitle": contentJson,
      "isLocked": isLocked,
      "folderKey": currentFolderKey,
      "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "isPinned": isPinned,
      "colorValue": AppColor().primaryColor.value,
      "bgColorValue": noteBgColor?.value,
      "images": selectedImages.map((file) => file.path).toList(),
      "showTable": showTable,
      "tableData": tableData,
      "paperTypeIndex": selectedPaperType.index,
      "drawingLayers": drawingLayers,
    };

    if (isEditingMode && currentNoteKey != null) {
      await noteBox.put(currentNoteKey, noteData);
      debugPrint("Background Saved: Note ID $currentNoteKey");
    } else {
      final newKey = await noteBox.add(noteData);
      setState(() {
        currentNoteKey = newKey;
        isEditingMode = true;
      });
      debugPrint("Background Saved: New Note Created");
    }

    if (!isAuto) {
      Get.back();
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    titleController.removeListener(_triggerAutoSave);
    _quillController.removeListener(_triggerAutoSave);
    _quillController.dispose();
    titleController.dispose();
    super.dispose();
  }

  Future<File> _moveFileToPermanentStorage(File sourceFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = "${DateTime.now().millisecondsSinceEpoch}${p.extension(sourceFile.path)}";
    final String newPath = p.join(directory.path, fileName);
    return await sourceFile.copy(newPath);
  }

  // Future<File> _moveFileToPermanentStorage(File sourceFile) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final String fileName = "IMG_${DateTime.now().millisecondsSinceEpoch}.jpg";
  //   final String targetPath = p.join(directory.path, fileName);

  //   XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
  //     sourceFile.absolute.path,
  //     targetPath,
  //     quality: 40,
  //     minWidth: 800,
  //     minHeight: 800,
  //     rotate: 0,
  //     format: CompressFormat.jpeg,
  //   );

  //   if (compressedXFile != null) {
  //     return File(compressedXFile.path);
  //   } else {
  //     // Fallback: Copy original if compression fails
  //     return await sourceFile.copy(targetPath);
  //   }
  // }

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
            //   if (filePath != null) selectedImages.add(File(filePath));

            // If the user actually drew something and saved it
            if (filePath != null && layers.isNotEmpty) {
              selectedImages.add(File(filePath));
            } else if (layers.isEmpty) {
              // If layers are empty, the drawing is effectively deleted
              debugPrint("Drawing cleared");
            }
          });
          _triggerAutoSave();
        },
      ),
    );
  }

  Future<void> _handleLockToggle() async {
    try {
      if (!Hive.isBoxOpen('settings_box')) {
        await Hive.openBox('settings_box');
      }

      final settingsBox = Hive.box('settings_box');
      String? masterPass = settingsBox.get('master_password');

      if (masterPass == null) {
        final result = await Get.to(() => const CreatePasswordScreen());
        if (result == true) {
          setState(() => isLocked = true);
          _triggerAutoSave();
        }
        return;
      }

      if (isLocked) {
        _showUnlockDialog(masterPass);
      } else {
        setState(() => isLocked = true);
        _triggerAutoSave();
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
          _triggerAutoSave();
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

  void _shareNote() {
    _autoSaveTimer?.cancel();

    final rawText = _quillController.document.toPlainText();
    final plainText = rawText.replaceAll('\n', '').trim();

    final hasTitle = titleController.text.trim().isNotEmpty;
    final hasText = plainText.isNotEmpty;
    final hasImages = selectedImages.isNotEmpty;

    // Prevent empty share
    if (!hasTitle && !hasText && !hasImages) {
      return;
    }

    noteController.shareNote(
      title: titleController.text.trim(),
      content: hasText ? rawText.trim() : "",
      selectedImages: selectedImages,
    );
  }

  void _togglePin() {
    setState(() {
      isPinned = !isPinned;
    });

    _saveNote(isAuto: true);
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveBg = noteBgColor ?? Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: effectiveBg,
      resizeToAvoidBottomInset: true,
      appBar: customAppBar(
        title: widget.isEditing ? "Edit Note" : "Create Note",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          if (isLocked) Icon(Icons.lock_outline, color: AppColor().primaryColor, size: 20),
          AnimatedBuilder(
            animation: _quillController,
            builder: (context, _) => _actionButton(
              asset: 'assets/images/undo.png',
              isEnabled: _quillController.hasUndo,
              onTap: () {
                if (_quillController.hasUndo) {
                  _quillController.undo();
                }
              },
            ),
          ),
          AnimatedBuilder(
            animation: _quillController,
            builder: (context, _) => _actionButton(
              asset: 'assets/images/redo.png',
              isEnabled: _quillController.hasRedo,
              onTap: () {
                if (_quillController.hasRedo) {
                  _quillController.redo();
                }
              },
            ),
          ),
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
              buildPopupItem(context, isPinned ? 'Unpin' : 'Pin', isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              buildPopupItem(context, 'Share', Icons.share_outlined),
              buildPopupItem(context, 'Move Note', Icons.folder_outlined),
              buildPopupItem(context, isLocked ? 'Unlock Note' : 'Lock Note', isLocked ? Icons.lock_open : Icons.lock_outline),
              buildPopupItem(context, 'Delete', Icons.delete_outline, color: Colors.red),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: CustomPaint(
          painter: NotebookPainter(
            type: selectedPaperType,
            lineColor: const Color(0x339E9E9E),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    border: InputBorder.none,
                  ),
                  cursorColor: Theme.of(context).primaryColor,
                  style: TextStyle(
                    fontSize: context.isPhone ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                // if (selectedImages.isNotEmpty) _buildImagePreview(),
                if (selectedImages.any((file) => !file.path.contains('draw_'))) _buildImagePreview(),

                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: QuillEditor(
                    controller: _quillController,
                    scrollController: ScrollController(),
                    focusNode: FocusNode(),
                    config: QuillEditorConfig(
                      placeholder: "Start typing...",
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (showTable)
                  EditableTableComponent(
                    tableData: tableData,
                    onCellChanged: (rowIndex, colIndex, value) {
                      // 1. Update the local list
                      tableData[rowIndex][colIndex] = value;
                      // 2. Trigger the 1-second auto-save timer
                      _triggerAutoSave();
                    },
                    onAddRow: () {
                      setState(() {
                        int currentCols = tableData[0].length;
                        tableData.add(List.generate(currentCols, (_) => ""));
                      });
                      _triggerAutoSave();
                    },
                    onRemoveRow: (index) {
                      setState(() {
                        if (tableData.length > 1) {
                          tableData.removeAt(index);
                        } else {
                          showTable = false;
                        }
                      });
                      _triggerAutoSave();
                    },
                    onAddColumn: () {
                      setState(() {
                        for (var row in tableData) {
                          row.add("");
                        }
                      });
                      _triggerAutoSave();
                    },
                    onRemoveColumn: (colIndex) {
                      setState(() {
                        if (tableData[0].length > 1) {
                          for (var row in tableData) {
                            row.removeAt(colIndex);
                          }
                        }
                      });
                      _triggerAutoSave();
                    },
                    onDeleteTable: () {
                      setState(() {
                        showTable = false;
                        tableData = [
                          ["", ""]
                        ];
                      });
                      _triggerAutoSave();
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

  Widget _buildImagePreview() {
    // Filter list to show only photos (excluding drawings)
    final photoOnlyList = selectedImages.where((file) => !file.path.contains('draw_')).toList();

    if (photoOnlyList.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photoOnlyList.length,
        itemBuilder: (context, index) {
          final imageFile = photoOnlyList[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => ImageDetailScreen(imageFile: imageFile));
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      selectedImages.removeWhere((file) => file.path == imageFile.path);
                    });
                    _triggerAutoSave();
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _bottomIcon(Icons.camera_alt_outlined, () {
                      // 1. Calculate how many ACTUAL photos are currently in the list
                      final int photoCount = selectedImages.where((file) => !file.path.contains('draw_')).length;

                      // 2. Check the limit (only for photos)
                      if (photoCount >= 2) {
                        return;
                      }

                      showMediaSheet(
                        context: context,
                        onImageSelected: (File tempImage) async {
                          // 3. Re-check inside the callback to be safe
                          final int currentPhotoCount = selectedImages.where((file) => !file.path.contains('draw_')).length;

                          if (currentPhotoCount < 2) {
                            File permanentFile = await _moveFileToPermanentStorage(tempImage);
                            setState(() {
                              selectedImages.add(permanentFile);
                            });
                            _triggerAutoSave();
                          }
                        },
                      );
                    }),
                    _bottomIcon(Icons.text_fields, () {
                      _showFormattingSheet();
                    }),
                    _bottomIcon(Icons.palette_outlined, () {
                      showPaletteSheet(
                        context: context,
                        selectedColor: noteBgColor ?? Theme.of(context).scaffoldBackgroundColor,
                        onColorSelected: (Color color) {
                          setState(() {
                            noteBgColor = color;
                          });
                          _triggerAutoSave();
                        },
                      );
                    }),
                    _bottomIcon(Icons.table_chart_outlined, () {
                      setState(() => showTable = !showTable);
                      _triggerAutoSave();
                    }),
                    _bottomIcon(Icons.mode_outlined, _openHandwriting),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'Pin':
      case 'Unpin':
        _togglePin();
        break;
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
                    title: Text(folderTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: isSelected ? Icon(Icons.check, color: AppColor().primaryColor) : null,
                    onTap: () {
                      setState(() {
                        currentFolderKey = folder.key;
                      });

                      _saveNote(isAuto: true);

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
        noteController.deleteNote(
          noteKey: widget.noteKey,
          noteData: widget.existingNote,
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
      icon: Icon(icon, color: Theme.of(context).iconTheme.color, size: context.isPhone ? 25 : 30),
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

  void _showFormattingSheet() {
    final selectionStyle = _quillController.getSelectionStyle();
    final attributes = selectionStyle.attributes;
    showFormatSheet(
      context: context,
      isLeftAligned: selectionStyle.attributes[Attribute.align.key]?.value == 'left' || selectionStyle.attributes[Attribute.align.key] == null,
      isCenterAligned: selectionStyle.attributes[Attribute.align.key]?.value == 'center',
      isRightAligned: selectionStyle.attributes[Attribute.align.key]?.value == 'right',
      isJustifyAligned: attributes[Attribute.align.key]?.value == 'justify',
      isBold: selectionStyle.attributes.containsKey(Attribute.bold.key),
      isItalic: selectionStyle.attributes.containsKey(Attribute.italic.key),
      isUnderlined: selectionStyle.attributes.containsKey(Attribute.underline.key),
      isStrikethrough: selectionStyle.attributes.containsKey(Attribute.strikeThrough.key),
      selectedColor: Colors.black,
      onBoldChanged: (v) => _quillController.formatSelection(v ? Attribute.bold : Attribute.clone(Attribute.bold, null)),
      onItalicChanged: (v) => _quillController.formatSelection(v ? Attribute.italic : Attribute.clone(Attribute.italic, null)),
      onUnderlineChanged: (v) => _quillController.formatSelection(v ? Attribute.underline : Attribute.clone(Attribute.underline, null)),
      onStrikethroughChanged: (v) => _quillController.formatSelection(v ? Attribute.strikeThrough : Attribute.clone(Attribute.strikeThrough, null)),
      onLeftAlignPressed: () => _quillController.formatSelection(Attribute.leftAlignment),
      onCenterAlignPressed: () => _quillController.formatSelection(Attribute.centerAlignment),
      onRightAlignPressed: () => _quillController.formatSelection(Attribute.rightAlignment),
      onJustifyAlignPressed: () => _quillController.formatSelection(Attribute.justifyAlignment),
      onFontSizeChanged: (String size) {
        if (size == 'normal') {
          _quillController.formatSelection(Attribute.clone(Attribute.size, null));
        } else {
          _quillController.formatSelection(SizeAttribute(size));
        }
      },
      onColorChanged: (color) {
        final hex = '#${color.value.toRadixString(16).substring(2)}';
        _quillController.formatSelection(ColorAttribute(hex));
      },
      onBulletPressed: () => _quillController.formatSelection(Attribute.ul),
      onNumberedPressed: () => _quillController.formatSelection(Attribute.ol),
      onHyphenPressed: () => _quillController.formatSelection(Attribute.blockQuote),
    );
  }
}
