import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/controllers/notes/folder_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/functions/format_file_size.dart';
import 'package:project_structure/models/note/note_model.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/create/components/background_component.dart';
import 'package:project_structure/views/create/components/format_component.dart';
import 'package:project_structure/views/create/components/media_component.dart';
import 'package:project_structure/views/create/components/quill_editor_component.dart';
import 'package:project_structure/views/create/components/table_component.dart';
import 'package:project_structure/views/create/components/handwriting_component.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/multi_style.dart';

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

  // Note State
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

    // Initialize data for editing or new note
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

      // Quill Editor Content
      try {
        final contentJson = note.content ?? '[]';
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

    _autoSaveTimer = Timer(const Duration(milliseconds: 0), () {
      _saveNote(isAuto: true);
    });
  }

  // Helper method to look deeply for all content embeddings inside Quill document
  Map<String, List<String>> _extractEmbeddedMedia() {
    final List<String> images = [];
    final List<String> videos = [];
    final List<String> files = [];

    for (final operation in _quillController.document.toDelta().toJson()) {
      if (operation.containsKey('insert') && operation['insert'] is Map) {
        final insertMap = operation['insert'] as Map;

        // Check for Image
        if (insertMap.containsKey('image')) {
          images.add(insertMap['image'].toString());
        }
        // Check for Video
        if (insertMap.containsKey('video')) {
          videos.add(insertMap['video'].toString());
        }
        // Check for Custom File block type
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
    final String title = titleController.text.trim();

    final String plainText = _quillController.document.toPlainText().replaceAll('\n', '').trim();
    final bool isTextContentEmpty = plainText.isEmpty;

    final mediaData = _extractEmbeddedMedia();
    final List<String> activeImagePaths = mediaData['images']!;
    final List<String> activeVideoPaths = mediaData['videos']!;
    final List<String> activeFilePaths = mediaData['files']!;

    final drawingPaths = selectedImages.map((f) => f.path).where((path) => path.contains('draw_')).toList();
    activeImagePaths.addAll(drawingPaths);

    setState(() {
      selectedImages = activeImagePaths.map((path) => File(path)).toList();
    });
    bool isEmpty = title.isEmpty && isTextContentEmpty && activeImagePaths.isEmpty && activeVideoPaths.isEmpty && activeFilePaths.isEmpty && !showTable && drawingLayers.isEmpty;

    if (isEmpty) {
      if (isAuto && currentNoteId != null) {
        await noteController.moveToTrash(currentNoteId!, widget.folderId);
        // currentNoteId = null;
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
      bgColor: noteBgColor?.value ?? 0,
      imagePaths: activeImagePaths,
      showTable: showTable,
      tableData: tableData,
      drawingLayers: drawingLayers,
    );

    if (savedId != null && !widget.isEditing) {
      currentNoteId = savedId;
    }

    if (!isAuto) {
      Get.back(result: true);
    }
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
      case 'Lock Note':
      case 'Unlock Note':
        _handleLockToggle();
        break;
      case 'Pin':
        setState(() => isPinned = true);
        _triggerAutoSave();
        break;
      case 'Unpin':
        setState(() => isPinned = false);
        _triggerAutoSave();
        break;
      case 'Delete':
        _showDeleteDialog();
        break;
      case 'Share':
        _shareNote();
        break;
      case 'Move Note':
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
    showPaletteSheet(
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
          // FIX: No '\n' added above the image block
          _quillController.document.insert(
            insertionIndex,
            BlockEmbed.image(permanentFile.path),
          );
          insertionIndex += 1;

          // Append a newline AFTER the block component so users can type beneath it
          _quillController.document.insert(insertionIndex, '\n');
          insertionIndex += 1;
        } else if (type == 'video') {
          // FIX: No '\n' added above the video block
          _quillController.document.insert(
            insertionIndex,
            BlockEmbed.video(permanentFile.path),
          );
          insertionIndex += 1;

          // Append a newline AFTER the block component
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

          // FIX: Insert the custom file element directly at the cursor index
          // with NO '\n' added above it.
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

          // Only append a newline AFTER the block component layout so
          // that users can select line text right beneath it.
          _quillController.document.insert(insertionIndex, '\n');
          insertionIndex += 1;
        }

        _quillController.updateSelection(
          TextSelection.collapsed(offset: insertionIndex),
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
    final selectionStyle = _quillController.getSelectionStyle();
    final attributes = selectionStyle.attributes;
    Color currentHighlightColor = Colors.transparent;
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
      selectedColor: Colors.transparent,
      selectedHighlightColor: currentHighlightColor,
      onBoldChanged: (v) => _quillController.formatSelection(v ? Attribute.bold : Attribute.clone(Attribute.bold, null)),
      onItalicChanged: (v) => _quillController.formatSelection(v ? Attribute.italic : Attribute.clone(Attribute.italic, null)),
      onUnderlineChanged: (v) => _quillController.formatSelection(v ? Attribute.underline : Attribute.clone(Attribute.underline, null)),
      onStrikethroughChanged: (v) => _quillController.formatSelection(v ? Attribute.strikeThrough : Attribute.clone(Attribute.strikeThrough, null)),
      onLeftAlignPressed: () => _quillController.formatSelection(Attribute.leftAlignment),
      onCenterAlignPressed: () => _quillController.formatSelection(Attribute.centerAlignment),
      onRightAlignPressed: () => _quillController.formatSelection(Attribute.rightAlignment),
      onJustifyAlignPressed: () => _quillController.formatSelection(Attribute.justifyAlignment),
      onHighlightColorChanged: (color) {
        final hex = '#${color.value.toRadixString(16).substring(2)}';
        _quillController.formatSelection(BackgroundAttribute(hex));
      },
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

  void _openDrawing() {
    _forceUnfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: double.infinity),
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return HandwritingCanvas(
          initialLayers: drawingLayers,
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
    final rawText = _quillController.document.toPlainText();
    final hasImages = selectedImages.isNotEmpty;
    final bool hasText = titleController.text.trim().isNotEmpty || rawText.trim().isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: double.infinity),
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SheetHeader(title: ""),
                Wrap(
                  children: [
                    if (hasText)
                      ListTile(
                        leading: Icon(
                          Icons.text_snippet,
                          color: AppColor().primaryColor,
                          size: context.isPhone ? 20 : 25,
                        ),
                        title: Text(
                          "text".tr,
                          style: text16(context),
                        ),
                        onTap: () {
                          Get.back();
                          noteController.shareNote(
                            title: titleController.text,
                            content: rawText,
                            selectedImages: selectedImages,
                            mode: ShareMode.text,
                          );
                        },
                      ),
                    if (hasImages)
                      ListTile(
                        leading: Icon(
                          Icons.image,
                          color: AppColor().green,
                          size: context.isPhone ? 20 : 25,
                        ),
                        title: Text(
                          "photos".tr,
                          style: text16(context),
                        ),
                        onTap: () {
                          Get.back();
                          noteController.shareNote(
                            title: titleController.text,
                            content: rawText,
                            selectedImages: selectedImages,
                            mode: ShareMode.photo,
                          );
                        },
                      ),
                    if (hasText)
                      ListTile(
                        leading: Icon(
                          Icons.insert_drive_file,
                          color: AppColor().orange,
                          size: context.isPhone ? 20 : 25,
                        ),
                        title: Text("file_txt".tr, style: text16(context)),
                        onTap: () {
                          Get.back();
                          noteController.shareNote(
                            title: titleController.text,
                            content: rawText,
                            selectedImages: selectedImages,
                            mode: ShareMode.file,
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomToolbar(Color iconColor) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: UnconstrainedBox(
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 15 : 40, vertical: context.isPhone ? 3 : 10),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(40), boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 5,
                spreadRadius: 0,
                offset: Offset(0, 3),
              )
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomIcon(Icons.image_outlined, () {
                  _handleImageSelection();
                }),
                _bottomIcon(Icons.text_fields, _openFormatting),
                _bottomIcon(Icons.palette_outlined, () {
                  _openPalette();
                  _triggerAutoSave();
                }),
                _bottomIcon(
                  showTable ? Icons.table_chart_outlined : Icons.table_chart_outlined,
                  () {
                    setState(() => showTable = !showTable);
                    _triggerAutoSave();
                  },
                ),
                _bottomIcon(Icons.mode_outlined, () {
                  _openDrawing();
                  _triggerAutoSave();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomIcon(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 5 : 20),
      child: IconButton(
        icon: Icon(icon, color: Theme.of(context).iconTheme.color, size: context.isPhone ? 25 : 35),
        onPressed: () {
          onPressed();
          FocusScope.of(context).unfocus();
        },
      ),
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
    final Color textColor = (effectiveBg.computeLuminance() > 0.5) ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: effectiveBg,
      appBar: customAppBar(
        title: widget.isEditing ? "edit_note".tr : "create_note".tr,
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
                _forceUnfocus();
                _quillController.undo();
              },
            ),
          ),
          AnimatedBuilder(
            animation: _quillController,
            builder: (context, _) => _actionButton(
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
              final bool isEmpty = _isNoteEmpty;

              return PopupMenuButton<String>(
                color: Theme.of(context).cardColor,
                enabled: !isEmpty,
                onOpened: _forceUnfocus,
                icon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: isEmpty ? AppColor().gray : AppColor().primaryColor, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(Icons.more_vert_outlined, color: isEmpty ? AppColor().gray : AppColor().primaryColor, size: 18),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                offset: const Offset(0, 50),
                onSelected: (v) => _handleMenuSelection(v),
                itemBuilder: (context) => [
                  buildPopupItem(context, isPinned ? 'Unpin' : 'Pin', isPinned ? Icons.push_pin_outlined : Icons.push_pin_outlined),
                  buildPopupItem(context, 'Share', Icons.share_outlined),
                  buildPopupItem(context, 'Move Note', Icons.folder_outlined),
                  buildPopupItem(context, isLocked ? 'Unlock Note' : 'Lock Note', isLocked ? Icons.lock_open : Icons.lock_outline),
                  buildPopupItem(context, 'Delete', Icons.delete_outline, color: AppColor().red),
                ],
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
                  hintStyle: TextStyle(fontSize: AppFontSize(context).titleSize, fontFamily: 'EN-BOLD', fontFamilyFallback: const ['KH-BOLD'], color: textColor),
                ),
                style: TextStyle(fontSize: AppFontSize(context).titleSize, fontFamily: 'EN-BOLD', fontFamilyFallback: const ['KH-BOLD'], color: textColor),
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
                  onAddRow: () {
                    setState(() {
                      tableData.add(List.generate(tableData[0].length, (_) => ""));
                    });
                    _triggerAutoSave();
                  },
                  onAddColumn: () {
                    setState(() {
                      for (var row in tableData) row.add("");
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
                        for (var row in tableData) row.removeAt(index);
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
      bottomNavigationBar: _buildBottomToolbar(textColor),
    );
  }

  Widget _actionButton({required String asset, required bool isEnabled, required VoidCallback onTap}) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Image.asset(
          asset,
          width: 22,
          height: 22,
          color: isEnabled ? AppColor().primaryColor : AppColor().gray,
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

    ConfirmBottomSheet.show(
      context: context,
      title: "move_to_folder".tr,
      showTopCancel: true,
      content: Flexible(
        child: Obx(() {
          final folders = folderController.folders.where((f) => f.id != widget.folderId).toList();

          if (folders.isEmpty) {
            return const CustomNoData(
              message: "No data",
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];

              return ListTile(
                leading: Icon(
                  Icons.folder,
                  color: AppColor().primaryColor,
                ),
                title: Text(folder.title),
                onTap: () async {
                  await noteController.moveNote(
                    currentNoteId!,
                    folder.id!,
                  );

                  Get.back();
                  Get.back(result: true);
                },
              );
            },
          );
        }),
      ),
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
