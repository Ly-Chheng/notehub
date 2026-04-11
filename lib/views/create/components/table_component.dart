import 'package:flutter/cupertino.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_action_sheet.dart';

class EditableTableComponent extends StatefulWidget {
  final List<List<String>> tableData;
  final Function(int rowIndex, int colIndex, String value) onCellChanged;
  final VoidCallback onAddRow;
  final Function(int rowIndex) onRemoveRow;
  final VoidCallback onAddColumn;
  final Function(int colIndex) onRemoveColumn;
  final VoidCallback onDeleteTable;

  const EditableTableComponent({
    super.key,
    required this.tableData,
    required this.onCellChanged,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.onAddColumn,
    required this.onRemoveColumn,
    required this.onDeleteTable,
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
      title: 'Table Options',
      actions: [
        ActionSheetItem(
          label: 'Add Row',
          icon: CupertinoIcons.add_circled,
          color: AppColor().primaryColor,
          onTap: () => widget.onAddRow(),
        ),
        ActionSheetItem(
          label: 'Add Column',
          icon: CupertinoIcons.add_circled,
          color: AppColor().primaryColor,
          onTap: () => widget.onAddColumn(),
        ),
        ActionSheetItem(
          label: 'Delete Table',
          icon: CupertinoIcons.delete,
          color: AppColor().red,
          onTap: () => widget.onDeleteTable(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int columnCount = widget.tableData.isNotEmpty ? widget.tableData[0].length : 0;
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
                  width: 0.5,
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
                        child: Icon(CupertinoIcons.plus_circle_fill, color: AppColor().green, size: 22),
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

                              //   AUTO HEIGHT LOGIC
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              placeholder: "",
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                              decoration: null,
                              style: TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.label.resolveFrom(context),
                              ),
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: () => widget.onRemoveRow(rowIndex),
                          child: Container(
                            height: 45,
                            alignment: Alignment.center,
                            child: Icon(CupertinoIcons.minus_circle, color: AppColor().gray, size: 20),
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
        height: 40,
        alignment: Alignment.center,
        child: Icon(CupertinoIcons.minus_circle, size: 20, color: AppColor().gray),
      ),
    );
  }
}
