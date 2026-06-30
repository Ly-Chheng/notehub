import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_action_sheet.dart';

class EditableTableComponent extends StatefulWidget {
  final List<List<String>> tableData;
  final Function(int rowIndex, int colIndex, String value) onCellChanged;
  final VoidCallback onAddRow;
  final Function(int rowIndex) onRemoveRow;
  final VoidCallback onAddColumn;
  final Function(int colIndex) onRemoveColumn;
  final VoidCallback onDeleteTable;
  final Color? noteBgColor;

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
  });

  @override
  State<EditableTableComponent> createState() => _EditableTableComponentState();
}

class _EditableTableComponentState extends State<EditableTableComponent> {
  late List<List<FocusNode>> _focusNodes;

  @override
  void initState() {
    super.initState();
    _initFocusNodes();
  }

  void _initFocusNodes() {
    _focusNodes = List.generate(
      widget.tableData.length,
      (r) => List.generate(
        widget.tableData.isNotEmpty ? widget.tableData[0].length : 0,
        (c) => FocusNode(),
      ),
    );
  }

  @override
  void didUpdateWidget(EditableTableComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.tableData.length != _focusNodes.length || (widget.tableData.isNotEmpty && _focusNodes.isNotEmpty && widget.tableData[0].length != _focusNodes[0].length)) {
      _initFocusNodes();
    }
  }

  @override
  void dispose() {
    for (var row in _focusNodes) {
      for (var node in row) {
        node.dispose();
      }
    }
    super.dispose();
  }

  void _showAddMenu(BuildContext context) {
    ActionSheet.show(
      context,
      title: 'table_options'.tr,
      actions: [
        ActionSheetItem(
          label: 'add_row'.tr,
          icon: Icons.add,
          color: AppColor().primaryColor,
          onTap: () => widget.onAddRow(),
        ),
        ActionSheetItem(
          label: 'add_column'.tr,
          icon: Icons.add,
          color: AppColor().primaryColor,
          onTap: () => widget.onAddColumn(),
        ),
        ActionSheetItem(
          label: 'delete_table'.tr,
          icon: Icons.delete,
          color: AppColor().red,
          onTap: () => widget.onDeleteTable(),
        ),
      ],
    );
  }

  Color _getContrastColor(Color? bgColor) {
    // if (bgColor == null || bgColor.value == 0) {
    if (bgColor == null || bgColor.toARGB32() == 0) {
      return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    }
    return ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    int columnCount = widget.tableData.isNotEmpty ? widget.tableData[0].length : 0;
    final Color textColor = _getContrastColor(widget.noteBgColor);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(160),
                columnWidths: {
                  columnCount: const FixedColumnWidth(50),
                },
                border: TableBorder.all(
                  color: CupertinoColors.separator.resolveFrom(context),
                  width: 1,
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: CupertinoColors.tertiarySystemFill.resolveFrom(context)),
                    children: [
                      ...List.generate(
                        columnCount,
                        (index) => _deleteHeader(onTap: () => widget.onRemoveColumn(index)),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _showAddMenu(context),
                        child: Icon(Icons.add_circle_outline, color: AppColor().green, size: 22),
                      ),
                    ],
                  ),
                  // Data Rows
                  ...widget.tableData.asMap().entries.map((rowEntry) {
                    int rowIndex = rowEntry.key;
                    return TableRow(
                      children: [
                        ...rowEntry.value.asMap().entries.map((colEntry) {
                          int colIndex = colEntry.key;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: CupertinoTextField(
                              focusNode: _focusNodes[rowIndex][colIndex],
                              controller: TextEditingController(text: widget.tableData[rowIndex][colIndex])
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: widget.tableData[rowIndex][colIndex].length),
                                ),
                              onChanged: (value) => widget.onCellChanged(rowIndex, colIndex, value),
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              placeholder: "",
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                              decoration: null,
                              style: TextStyle(
                                fontSize: context.isPhone ? 16 : 18,
                                color: textColor,
                                fontFamily: 'EN-REGULAR',
                                fontFamilyFallback: const ['KH-REGULAR'],
                              ),
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: () => widget.onRemoveRow(rowIndex),
                          child: Container(
                            height: 45,
                            alignment: Alignment.center,
                            child: Icon(Icons.remove_circle_outline, color: AppColor().gray, size: context.isPhone ? 20 : 25),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _deleteHeader({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.isPhone ? 40 : 50,
        alignment: Alignment.center,
        child: Icon(CupertinoIcons.minus_circle, size: context.isPhone ? 20 : 25, color: AppColor().gray),
      ),
    );
  }
}
