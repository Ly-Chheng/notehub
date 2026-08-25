import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/controllers/home/folder_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/functions/format_file_size.dart';
import 'package:project_structure/models/note/note_model.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/note/create_note/components/bottom_toolbar.dart';
import 'package:project_structure/views/note/create_note/components/move_note.dart';
import 'package:project_structure/views/note/create_note/components/note_format.dart';
import 'package:project_structure/views/note/create_note/components/popup_menu.dart';
import 'package:project_structure/views/note/create_note/components/share_note.dart';
import 'package:project_structure/widgets/navigation_create_note/background_note.dart';
import 'package:project_structure/widgets/navigation_create_note/media_component.dart';
import 'package:project_structure/views/note/create_note/components/quill/quill_editor.dart';
import 'package:project_structure/views/note/create_note/components/quill/quill_table.dart';
import 'package:project_structure/widgets/navigation_create_note/handwriting.dart';
import 'package:project_structure/widgets/navigation_create_note/template_library.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
import 'package:project_structure/widgets/action_button.dart';

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
  final FolderController folderController = Get.find<FolderController>();
  final LockController lockController = Get.put(LockController());

  late final TextEditingController titleController;
  late final QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();

  Timer? _autoSaveTimer;
  bool isAutoSaveEnabled = true;
  bool isSessionUnlocked = false;
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

  int? currentNoteId;

  @override
  void initState() {
    super.initState();

    currentNoteId = widget.existingNote?.id;

    if (widget.isEditing && widget.existingNote != null) {
      final note = widget.existingNote!;

      titleController = TextEditingController(text: note.title);

      isPinned = note.isPinned;
      isLocked = note.isLocked;
      noteBgColor = (note.bgColor > 0) ? Color(note.bgColor) : null;
      showTable = note.showTable;

      if (note.tableData.isNotEmpty) {
        tableData = note.tableData.map((row) => List<String>.from(row as List)).toList();
      }

      if (note.drawingLayers.isNotEmpty) {
        drawingLayers = List<Map<String, dynamic>>.from(note.drawingLayers);
      }

      if (note.imagePaths.isNotEmpty) {
        selectedImages = note.imagePaths.map((path) => File(path)).toList();
      }

      try {
        final contentJson = note.content;
        final decoded = jsonDecode(contentJson);
        _quillController = QuillController(
          document: Document.fromJson(decoded),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        debugPrint("Error parsing Quill content: $e");
        _quillController = QuillController.basic();
      }
    } else {
      titleController = TextEditingController();
      _quillController = QuillController.basic();
    }

    titleController.addListener(_triggerAutoSave);
    _quillController.addListener(_triggerAutoSave);
  }

  void _triggerAutoSave() {
    if (!isAutoSaveEnabled) return;
    if (_autoSaveTimer?.isActive ?? false) _autoSaveTimer!.cancel();

    _autoSaveTimer = Timer(const Duration(milliseconds: 800), () {
      _saveNote(isAuto: true);
    });
  }

  Map<String, List<String>> _extractEmbeddedMedia() {
    final List<String> images = [];
    final List<String> videos = [];
    final List<String> files = [];

    for (final operation in _quillController.document.toDelta().toJson()) {
      if (operation.containsKey('insert') && operation['insert'] is Map) {
        final insertMap = operation['insert'] as Map;

        if (insertMap.containsKey('image')) {
          images.add(insertMap['image'].toString());
        }

        if (insertMap.containsKey('video')) {
          videos.add(insertMap['video'].toString());
        }

        if (insertMap.containsKey('custom')) {
          final customData = insertMap['custom'];
          if (customData is Map && customData['type'] == 'file') {
            files.add(customData['data']?.toString() ?? '');
          }
        }
      }
    }
    return {'images': images, 'videos': videos, 'files': files};
  }

  Future<void> _saveNote({bool isAuto = false}) async {
    try {
      final String title = titleController.text.trim();

      final String plainText = _quillController.document.toPlainText().replaceAll('\n', '').trim();
      final bool isTextContentEmpty = plainText.isEmpty;

      final mediaData = _extractEmbeddedMedia();
      final List<String> activeImagePaths = mediaData['images']!;
      final List<String> activeVideoPaths = mediaData['videos']!;
      final List<String> activeFilePaths = mediaData['files']!;

      final drawingPaths = selectedImages.map((f) => f.path).where((path) => path.contains('draw_')).toList();
      activeImagePaths.addAll(drawingPaths);

      selectedImages = activeImagePaths.map((path) => File(path)).toList();

      bool isEmpty = title.isEmpty && isTextContentEmpty && activeImagePaths.isEmpty && activeVideoPaths.isEmpty && activeFilePaths.isEmpty && !showTable && drawingLayers.isEmpty;

      if (isEmpty) {
        if (isAuto && currentNoteId != null) {
          await noteController.moveToTrash(currentNoteId!, widget.folderId);
          currentNoteId = null;
        }

        if (!isAuto) Get.back();
        return;
      }

      final String contentJson = jsonEncode(_quillController.document.toDelta().toJson());

      final savedId = await noteController.saveNoteSQLite(
        id: currentNoteId,
        folderId: widget.folderId,
        title: title,
        contentJson: contentJson,
        isLocked: isLocked,
        isPinned: isPinned,
        bgColor: noteBgColor?.toARGB32() ?? 0,
        imagePaths: activeImagePaths,
        showTable: showTable,
        tableData: tableData,
        drawingLayers: drawingLayers,
      );

      if (savedId != null) {
        currentNoteId = savedId;
      }

      if (!isAuto) {
        Get.back(result: true);
      }
    } catch (e, stackTrace) {
      debugPrint("Error saving note: $e");
      debugPrint(stackTrace.toString());
    }
  }

  void _applyTemplate(List<dynamic> deltaJson) {
    _quillController.document = Document.fromJson(deltaJson);
    _triggerAutoSave();
  }

  Future<void> _handleLockToggle() async {
    final settings = await lockController.getSecuritySettings();
    String? storedPass = settings?['master_password'];

    if (storedPass == null || storedPass.isEmpty) {
      final result = await Get.to(() => const CreatePasswordScreen());
      if (result == true) {
        setState(() {
          isLocked = true;
          isSessionUnlocked = true;
        });
        _triggerAutoSave();
      }
    } else {
      if (isLocked) {
        _showVerifyUnlockDialog(
            storedPass: storedPass,
            onSuccess: () {
              setState(() {
                isLocked = false;
                isSessionUnlocked = true;
              });
              _triggerAutoSave();
            });
      } else {
        setState(() {
          isLocked = true;
          isSessionUnlocked = false;
        });
        _triggerAutoSave();
      }
    }
  }

  void _showVerifyUnlockDialog({required String storedPass, required VoidCallback onSuccess}) {
    final verifyController = TextEditingController();

    showConfirmDialog(
      context: context,
      title: "unlock_note".tr,
      subTitle: "remove_protection_desc".tr,
      confirmText: "verify".tr,
      controller: verifyController,
      obscureText: true,
      hintText: "password".tr,
      onConfirm: () {
        if (verifyController.text == storedPass) {
          onSuccess();
        } else {
          Get.snackbar(
            "Error",
            "Incorrect Password",
            backgroundColor: AppColor().red,
            colorText: AppColor().white,
            snackPosition: SnackPosition.TOP,
          );
        }
      },
    );
  }

  void _handleMenuSelection(String value) {
    _forceUnfocus();
    switch (value) {
      case 'lock_note':
      case 'unlock_note':
        _handleLockToggle();
        break;
      case 'pin':
        setState(() => isPinned = true);
        _triggerAutoSave();
        break;
      case 'unpin':
        setState(() => isPinned = false);
        _triggerAutoSave();
        break;
      case 'delete':
        _showDeleteDialog();
        break;
      case 'share':
        _shareNote();
        break;
      case 'move_note':
        _showMoveSheet();
        break;
    }
  }

  void _forceUnfocus() {
    _editorFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _openPalette() {
    _forceUnfocus();
    backgroundNote(
      context: context,
      selectedColor: noteBgColor ?? Theme.of(context).scaffoldBackgroundColor,
      onColorSelected: (color) {
        setState(() => noteBgColor = color);
        _triggerAutoSave();
      },
    );
  }

  void _handleImageSelection() {
    _forceUnfocus();

    showMediaSheet(
      context: context,
      onMediaSelected: (File tempMedia, String type) async {
        File permanentFile = await _moveFileToPermanentStorage(tempMedia);

        setState(() {
          selectedImages.add(permanentFile);
        });

        int insertionIndex = _quillController.selection.baseOffset;

        if (type == 'image') {
          _quillController.document.insert(
            insertionIndex,
            BlockEmbed.image(permanentFile.path),
          );
          insertionIndex += 1;

          _quillController.document.insert(insertionIndex, '\n');
          insertionIndex += 1;
        } else if (type == 'video') {
          _quillController.document.insert(
            insertionIndex,
            BlockEmbed.video(permanentFile.path),
          );
          insertionIndex += 1;

          _quillController.document.insert(insertionIndex, '\n');
          insertionIndex += 1;
        } else if (type == 'file') {
          final String fileName = p.basename(permanentFile.path);
          final int fileSizeBytes = await permanentFile.length();
          final String formattedSize = formatFileSize(fileSizeBytes);

          final String fileDataJson = jsonEncode({
            'path': permanentFile.path,
            'name': fileName,
            'size': formattedSize,
          });

          _quillController.document.insert(
            insertionIndex,
            BlockEmbed.custom(
              CustomBlockEmbed(
                'file',
                fileDataJson,
              ),
            ),
          );
          insertionIndex += 1;

          _quillController.document.insert(insertionIndex, '\n');
          insertionIndex += 1;
        }

        _quillController.document.insert(insertionIndex + 1, '\n');
        _quillController.updateSelection(
          TextSelection.collapsed(offset: insertionIndex),
          ChangeSource.local,
        );

        _triggerAutoSave();
      },
      onTextScanned: (String scannedText) {
        if (scannedText.isEmpty) return;

        // Insert text at cursor position
        final int index = _quillController.selection.baseOffset;
        _quillController.document.insert(index, scannedText);

        // Move cursor to end of inserted text
        _quillController.updateSelection(
          TextSelection.collapsed(offset: index + scannedText.length),
          ChangeSource.local,
        );

        _triggerAutoSave();
      },
    );
  }

  Future<File> _moveFileToPermanentStorage(File sourceFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = "${DateTime.now().millisecondsSinceEpoch}${p.extension(sourceFile.path)}";
    final String newPath = p.join(directory.path, fileName);
    return await sourceFile.copy(newPath);
  }

  void _openFormatting() {
    _forceUnfocus();
    NoteFormat.openFormattingSheet(context, _quillController);
  }

  void _openDrawing() {
    _forceUnfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: double.infinity),
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(0))),
      builder: (BuildContext context) {
        return HandwritingCanvas(
          initialLayers: drawingLayers,
          noteId: currentNoteId?.toString() ?? 'new_note',
          onSave: (path, layers) {
            setState(() {
              drawingLayers = layers;

              if (layers.isEmpty) {
                selectedImages.removeWhere((file) => file.path.contains('draw_'));
              } else if (path != null) {
                selectedImages.removeWhere((file) => file.path.contains('draw_'));
                selectedImages.add(File(path));
              }
            });
            _triggerAutoSave();
          },
        );
      },
    );
  }

  void _shareNote() {
    _forceUnfocus();
    _autoSaveTimer?.cancel();

    ShareNote.showShareOptions(
      context: context,
      title: titleController.text,
      content: _quillController.document.toPlainText(),
      selectedImages: selectedImages,
      noteController: noteController,
      quillController: _quillController,
    );
  }

  bool get _isNoteEmpty {
    final String plainText = _quillController.document.toPlainText().replaceAll('\n', '').trim();
    final mediaData = _extractEmbeddedMedia();

    return titleController.text.trim().isEmpty &&
        plainText.isEmpty &&
        mediaData['images']!.isEmpty &&
        mediaData['videos']!.isEmpty &&
        mediaData['files']!.isEmpty &&
        !showTable &&
        drawingLayers.isEmpty &&
        !selectedImages.any((file) => file.path.contains('draw_'));
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveBg = noteBgColor ?? Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = (effectiveBg.computeLuminance() > 0.5) ? AppColor().black : AppColor().white;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _autoSaveTimer?.cancel();
        await _saveNote(isAuto: false);
      },
      child: Scaffold(
        backgroundColor: effectiveBg,
        appBar: customAppBar(
          title: widget.isEditing ? "edit_note".tr : "create_note".tr,
          context: context,
          actions: [
            if (isLocked) Icon(Icons.lock_outline, color: AppColor().primaryColor, size: context.isPhone ? 20 : 25),
            AnimatedBuilder(
              animation: _quillController,
              builder: (context, _) => actionButton(
                asset: 'assets/images/undo.png',
                isEnabled: _quillController.hasUndo,
                onTap: () {
                  _forceUnfocus();
                  _quillController.undo();
                },
              ),
            ),
            AnimatedBuilder(
              animation: _quillController,
              builder: (context, _) => actionButton(
                asset: 'assets/images/redo.png',
                isEnabled: _quillController.hasRedo,
                onTap: () {
                  _forceUnfocus();
                  _quillController.redo();
                },
              ),
            ),
            AnimatedBuilder(
              animation: Listenable.merge([titleController, _quillController]),
              builder: (context, _) {
                return NotePopupMenu(
                  isEmpty: _isNoteEmpty,
                  isPinned: isPinned,
                  isLocked: isLocked,
                  onOpened: _forceUnfocus,
                  onSelected: (v) => _handleMenuSelection(v),
                );
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: _forceUnfocus,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'title'.tr,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    border: InputBorder.none,
                    hintStyle: fix18(context).copyWith(color: textColor),
                  ),
                  style: fix18(context).copyWith(color: textColor),
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
                    onCellChanged: (row, col, value) {
                      tableData[row][col] = value;
                      _triggerAutoSave();
                    },
                    onAddRow: (targetIndex) {
                      setState(() {
                        int colCount = tableData.isNotEmpty ? tableData[0].length : 2;
                        List<String> newRow = List.generate(colCount, (_) => "");

                        // Insert at target index (above/below) or append if at end
                        if (targetIndex >= tableData.length) {
                          tableData.add(newRow);
                        } else {
                          tableData.insert(targetIndex, newRow);
                        }
                      });
                      _triggerAutoSave();
                    },
                    onAddColumn: (targetIndex) {
                      setState(() {
                        for (var row in tableData) {
                          // Insert at target index (before/after) or append if at end
                          if (targetIndex >= row.length) {
                            row.add("");
                          } else {
                            row.insert(targetIndex, "");
                          }
                        }
                      });
                      _triggerAutoSave();
                    },
                    onRemoveRow: (index) {
                      setState(() {
                        if (tableData.length > 1) tableData.removeAt(index);
                      });
                      _triggerAutoSave();
                    },
                    onRemoveColumn: (index) {
                      setState(() {
                        if (tableData[0].length > 1) {
                          for (var row in tableData) {
                            row.removeAt(index);
                          }
                        }
                      });
                      _triggerAutoSave();
                    },
                    onDeleteTable: () {
                      setState(() {
                        showTable = false;
                        tableData = [
                          ["", ""],
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
        bottomNavigationBar: BottomToolbar(
          showTable: showTable,
          onImagePressed: _handleImageSelection,
          onFormatPressed: _openFormatting,
          onPalettePressed: () {
            _openPalette();
            _triggerAutoSave();
          },
          onTablePressed: () {
            setState(() => showTable = !showTable);
            _triggerAutoSave();
          },
          onDrawingPressed: () {
            _openDrawing();
            _triggerAutoSave();
          },
          onTemplatePressed: () {
            TemplateLibrary.show(context, (templateData) {
              _applyTemplate(templateData);
            });
          },
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showConfirmDialog(
      context: context,
      title: "delete_note".tr,
      subTitle: "delete_note_confirm".tr,
      confirmText: "delete".tr,
      onConfirm: () async {
        if (currentNoteId != null) {
          await noteController.moveToTrash(currentNoteId!, widget.folderId);
        }
        Get.back(result: true);
      },
    );
  }

  void _showMoveSheet() {
    if (currentNoteId == null) return;

    MoveNote.showMoveSheet(
      context: context,
      currentNoteId: currentNoteId!,
      currentFolderId: widget.folderId,
      noteController: noteController,
      folderController: folderController,
    );
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
