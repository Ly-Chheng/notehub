import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class EditableTableComponent extends StatefulWidget {
  final List<List<String>> tableData;
  final Function(int rowIndex, int colIndex, String value) onCellChanged;
  final Function(int targetIndex) onAddRow;
  final Function(int rowIndex) onRemoveRow;
  final Function(int targetIndex) onAddColumn;
  final Function(int colIndex) onRemoveColumn;
  final VoidCallback onDeleteTable;
  final Color? noteBgColor;
  final Color accentColor;

  const EditableTableComponent({
    super.key,
    required this.tableData,
    required this.onCellChanged,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.onAddColumn,
    required this.onRemoveColumn,
    required this.onDeleteTable,
    this.noteBgColor,
    this.accentColor = const Color.fromARGB(255, 37, 132, 233),
  });

  @override
  State<EditableTableComponent> createState() => _EditableTableComponentState();
}

class _EditableTableComponentState extends State<EditableTableComponent> {
  int? _selectedRow;
  int? _selectedCol;

  late List<List<TextEditingController>> _controllers;
  late List<List<FocusNode>> _focusNodes;

  @override
  void initState() {
    super.initState();
    _initControllersAndNodes();
  }

  void _initControllersAndNodes() {
    _controllers = List.generate(
      widget.tableData.length,
      (r) => List.generate(
        widget.tableData[r].length,
        (c) => TextEditingController(text: _stripMarkdown(widget.tableData[r][c])),
      ),
    );

    _focusNodes = List.generate(
      widget.tableData.length,
      (r) => List.generate(
        widget.tableData[r].length,
        (c) {
          final node = FocusNode();
          node.addListener(() {
            if (node.hasFocus) {
              setState(() {
                _selectedRow = r;
                _selectedCol = c;
              });
            }
          });
          return node;
        },
      ),
    );
  }

  @override
  void didUpdateWidget(EditableTableComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tableData.length != _controllers.length || (widget.tableData.isNotEmpty && _controllers.isNotEmpty && widget.tableData[0].length != _controllers[0].length)) {
      _disposeControllersAndNodes();
      _initControllersAndNodes();
    } else {
      for (int r = 0; r < widget.tableData.length; r++) {
        for (int c = 0; c < widget.tableData[r].length; c++) {
          final cleanText = _stripMarkdown(widget.tableData[r][c]);
          if (_controllers[r][c].text != cleanText) {
            _controllers[r][c].text = cleanText;
          }
        }
      }
    }
  }

  void _disposeControllersAndNodes() {
    for (var row in _controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    for (var row in _focusNodes) {
      for (var node in row) {
        node.dispose();
      }
    }
  }

  void _applyFormatToTarget({required String formatType, int? targetRow, int? targetCol}) {
    setState(() {
      if (targetRow != null) {
        for (int c = 0; c < widget.tableData[targetRow].length; c++) {
          final oldVal = widget.tableData[targetRow][c];
          final newVal = _toggleMarkdownFormat(oldVal, formatType);
          widget.onCellChanged(targetRow, c, newVal);
        }
      } else if (targetCol != null) {
        for (int r = 0; r < widget.tableData.length; r++) {
          final oldVal = widget.tableData[r][targetCol];
          final newVal = _toggleMarkdownFormat(oldVal, formatType);
          widget.onCellChanged(r, targetCol, newVal);
        }
      }
    });
  }

  String _toggleMarkdownFormat(String rawText, String formatType) {
    String clean = _stripMarkdown(rawText);
    bool hasBold = rawText.contains('**');
    bool hasItalic = rawText.contains('*') && !hasBold;
    bool hasUnderline = rawText.contains('<u>');

    if (formatType == 'bold') hasBold = !hasBold;
    if (formatType == 'italic') hasItalic = !hasItalic;
    if (formatType == 'underline') hasUnderline = !hasUnderline;

    String result = clean;
    if (hasBold) result = '**$result**';
    if (hasItalic) result = '*$result*';
    if (hasUnderline) result = '<u>$result</u>';

    return result;
  }

  @override
  void dispose() {
    _disposeControllersAndNodes();
    super.dispose();
  }

  String _stripMarkdown(String text) {
    return text.replaceAll('**', '').replaceAll('*', '').replaceAll('<u>', '').replaceAll('</u>', '');
  }

  TextStyle _getCellTextStyle(String text, Color textColor) {
    bool isBold = text.contains('**');
    bool isItalic = text.contains('*') && !isBold;
    bool isUnderline = text.contains('<u>');

    return TextStyle(
      fontSize: context.isPhone ? 15 : 17,
      color: textColor,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
      fontFamily: 'EN-REGULAR',
      fontFamilyFallback: const ['KH-REGULAR'],
    );
  }

  // WORKING COPY / CUT / PASTE LOGIC

  Future<void> _copyRow(int rowIndex) async {
    final rowText = widget.tableData[rowIndex].map((cell) => _stripMarkdown(cell)).join('\t');
    await Clipboard.setData(ClipboardData(text: rowText));
  }

  Future<void> _cutRow(int rowIndex) async {
    await _copyRow(rowIndex);
    for (int c = 0; c < widget.tableData[rowIndex].length; c++) {
      _controllers[rowIndex][c].clear();
      widget.onCellChanged(rowIndex, c, '');
    }
    setState(() {});
  }

  Future<void> _pasteRow(int rowIndex) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      final items = data.text!.split(RegExp(r'[\t\n\r]+'));
      for (int c = 0; c < widget.tableData[rowIndex].length && c < items.length; c++) {
        final val = items[c].trim();
        _controllers[rowIndex][c].text = val;
        widget.onCellChanged(rowIndex, c, val);
      }
      setState(() {});
    }
  }

  Future<void> _copyColumn(int colIndex) async {
    final colValues = widget.tableData.map((row) => _stripMarkdown(row[colIndex])).toList();
    final colText = colValues.join('\n');
    await Clipboard.setData(ClipboardData(text: colText));
  }

  Future<void> _cutColumn(int colIndex) async {
    await _copyColumn(colIndex);
    for (int r = 0; r < widget.tableData.length; r++) {
      _controllers[r][colIndex].clear();
      widget.onCellChanged(r, colIndex, '');
    }
    setState(() {});
  }

  Future<void> _pasteColumn(int colIndex) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      final items = data.text!.split(RegExp(r'[\t\n\r]+'));
      for (int r = 0; r < widget.tableData.length && r < items.length; r++) {
        final val = items[r].trim();
        _controllers[r][colIndex].text = val;
        widget.onCellChanged(r, colIndex, val);
      }
      setState(() {});
    }
  }

  Color _getContrastColor(Color? bgColor) {
    if (bgColor == null || bgColor.toARGB32() == 0) {
      return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    }
    return ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    int rowCount = widget.tableData.length;
    int colCount = rowCount > 0 ? widget.tableData[0].length : 0;
    final Color textColor = _getContrastColor(widget.noteBgColor);

    if (rowCount == 0 || colCount == 0) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => widget.onAddRow(0),
          icon: const Icon(Icons.add),
          label: const Text('Add Table'),
        ),
      );
    }

    //   const double colWidth = 140.0;
    //   const double rowHandleWidth = 28.0;

    const double rowHandleWidth = 28.0;
    const double horizontalPadding = 10.0;

    return LayoutBuilder(builder: (context, constraints) {
      final double availableWidth = constraints.maxWidth - rowHandleWidth - (horizontalPadding * 2);

      // Calculate Column Width:
      // - 1 or 2 Columns: Expand dynamically to fit full phone screen width (50% each for 2 columns)
      // - 3+ Columns: Use fixed width (140.0) with horizontal scroll enabled
      final double colWidth = (colCount <= 2)
          ? (colCount > 0 ? availableWidth / colCount : availableWidth)
          : context.isPhone
              ? 140.0
              : 220.0;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: rowHandleWidth),
                  ...List.generate(colCount, (colIndex) {
                    final isColSelected = _selectedCol == colIndex;
                    return SizedBox(
                      width: colWidth,
                      height: 24,
                      child: Center(
                        child: _buildColumnHandle(colIndex, isColSelected),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 4),
              ...List.generate(rowCount, (rowIndex) {
                final isRowSelected = _selectedRow == rowIndex;

                return IntrinsicHeight(
                  child: SizedBox(
                    // decoration: BoxDecoration(
                    //   border: isRowSelected ? Border.all(color: widget.accentColor, width: 2) : null,
                    //   borderRadius: isRowSelected ? BorderRadius.circular(4) : null,
                    // ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: rowHandleWidth,
                          child: Center(
                            child: _buildRowHandle(rowIndex, isRowSelected),
                          ),
                        ),
                        ...List.generate(colCount, (colIndex) {
                          final isCellSelected = isRowSelected && _selectedCol == colIndex;
                          final rawCellData = widget.tableData[rowIndex][colIndex];

                          return Container(
                            width: colWidth,
                            decoration: BoxDecoration(
                              color: isCellSelected ? widget.accentColor.withValues(alpha: 0.1) : Colors.transparent,
                              border: Border.all(
                                color: CupertinoColors.systemGrey4.resolveFrom(context),
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                            child: CupertinoTextField(
                              controller: _controllers[rowIndex][colIndex],
                              focusNode: _focusNodes[rowIndex][colIndex],
                              onChanged: (val) {
                                String formatted = val;
                                if (rawCellData.contains('**')) formatted = '**$val**';
                                if (rawCellData.contains('*') && !rawCellData.contains('**')) formatted = '*$val*';
                                if (rawCellData.contains('<u>')) formatted = '<u>$formatted</u>';
                                widget.onCellChanged(rowIndex, colIndex, formatted);
                              },
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                              decoration: null,
                              style: _getCellTextStyle(rawCellData, textColor),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildColumnHandle(int colIndex, bool isSelected) {
    if (!isSelected) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white.withValues(alpha: 0.95),
      elevation: 8,
      onSelected: (value) => _handleColumnAction(value, colIndex),
      itemBuilder: (context) => [
        _buildPopupMenuItem(value: 'delete', label: 'delete_column'.tr, icon: CupertinoIcons.rectangle_badge_xmark),
        // _buildPopupMenuItem(value: 'add_after', label: 'Add Column After', icon: CupertinoIcons.plus_rectangle),
        // _buildPopupMenuItem(value: 'add_before', label: 'Add Column Before', icon: CupertinoIcons.plus_rectangle),
        _buildPopupMenuItem(value: 'add_column', label: 'add_column'.tr, icon: CupertinoIcons.plus_rectangle),
        const PopupMenuDivider(height: 1),
        _buildFormatMenuItem(targetCol: colIndex),
        const PopupMenuDivider(height: 1),
        _buildPopupMenuItem(value: 'copy', label: 'copy'.tr, icon: CupertinoIcons.doc_on_doc),
        _buildPopupMenuItem(value: 'paste', label: 'paste'.tr, icon: CupertinoIcons.doc_on_clipboard),
        _buildPopupMenuItem(value: 'cut', label: 'cut'.tr, icon: CupertinoIcons.scissors),
      ],
      child: Container(
        height: 22,
        width: 50 - 8,
        decoration: BoxDecoration(
          color: widget.accentColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        child: const Icon(Icons.more_horiz, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildRowHandle(int rowIndex, bool isSelected) {
    if (!isSelected) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(30, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white.withValues(alpha: 0.95),
      elevation: 8,
      onSelected: (value) => _handleRowAction(value, rowIndex),
      itemBuilder: (context) => [
        _buildPopupMenuItem(value: 'delete', label: 'delete_row'.tr, icon: CupertinoIcons.rectangle_stack_badge_minus),
        // _buildPopupMenuItem(value: 'add_below', label: 'add_row_below'.tr, icon: CupertinoIcons.rectangle_stack_badge_plus),
        // _buildPopupMenuItem(value: 'add_above', label: 'add_row_above'.tr, icon: CupertinoIcons.rectangle_stack_badge_plus),
        _buildPopupMenuItem(value: 'add_row', label: 'add_row'.tr, icon: CupertinoIcons.rectangle_stack_badge_plus),
        const PopupMenuDivider(height: 1),
        _buildFormatMenuItem(targetRow: rowIndex),
        const PopupMenuDivider(height: 1),
        _buildPopupMenuItem(value: 'copy', label: 'copy'.tr, icon: CupertinoIcons.doc_on_doc),
        _buildPopupMenuItem(value: 'paste', label: 'paste'.tr, icon: CupertinoIcons.doc_on_clipboard),
        _buildPopupMenuItem(value: 'cut', label: 'cut'.tr, icon: CupertinoIcons.scissors),
      ],
      child: Container(
        width: 22,
        height: 38,
        decoration: BoxDecoration(
          color: widget.accentColor,
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
        ),
        child: const Icon(Icons.more_vert, size: 16, color: Colors.white),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: text16(context).copyWith(color: Colors.black87)),
          Icon(icon, size: 18, color: Colors.black54),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildFormatMenuItem({int? targetRow, int? targetCol}) {
    return PopupMenuItem<String>(
      enabled: false,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Icon(Icons.chevron_right, size: 18, color: Colors.black54),
              // SizedBox(width: 4),
              Text('format'.tr, style: text16(context).copyWith(color: Colors.black87)),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _applyFormatToTarget(formatType: 'bold', targetRow: targetRow, targetCol: targetCol);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text('B', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _applyFormatToTarget(formatType: 'italic', targetRow: targetRow, targetCol: targetCol);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text('I', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: Colors.black87)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _applyFormatToTarget(formatType: 'underline', targetRow: targetRow, targetCol: targetCol);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text('U', style: TextStyle(decoration: TextDecoration.underline, fontSize: 16, color: Colors.black87)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleColumnAction(String action, int colIndex) async {
    switch (action) {
      case 'delete':
        widget.onRemoveColumn(colIndex);
        break;
      // case 'add_after':
      //   widget.onAddColumn(colIndex + 1);
      //   break;
      // case 'add_before':
      //   widget.onAddColumn(colIndex);
      //   break;
      case 'add_column':
        widget.onAddColumn(colIndex + 1);
        break;
      case 'copy':
        await _copyColumn(colIndex);
        break;
      case 'cut':
        await _cutColumn(colIndex);
        break;
      case 'paste':
        await _pasteColumn(colIndex);
        break;
    }
  }

  void _handleRowAction(String action, int rowIndex) async {
    switch (action) {
      case 'delete':
        widget.onRemoveRow(rowIndex);
        break;
      // case 'add_below':
      //   widget.onAddRow(rowIndex + 1);
      //   break;
      // case 'add_above':
      //   widget.onAddRow(rowIndex);
      //   break;
      case 'add_row':
        widget.onAddRow(rowIndex + 1);
        break;
      case 'copy':
        await _copyRow(rowIndex);
        break;
      case 'cut':
        await _cutRow(rowIndex);
        break;
      case 'paste':
        await _pasteRow(rowIndex);
        break;
    }
  }
}
