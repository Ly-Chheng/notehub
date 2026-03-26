import 'package:flutter/cupertino.dart';

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
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Table Options',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'EN-REGULAR',
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              widget.onAddRow();
            },
            child: const Text(
              'Add Row',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'EN-REGULAR',
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              widget.onAddColumn();
            },
            child: const Text(
              'Add Column',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'EN-REGULAR',
              ),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteTable();
            },
            child: const Text(
              'Delete Table',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'EN-REGULAR',
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'EN-BOLD',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int columnCount = widget.tableData.isNotEmpty ? widget.tableData[0].length : 0;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border.all(color: CupertinoColors.separator.resolveFrom(context), width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Table(
            columnWidths: {
              for (var i = 0; i < columnCount; i++) i: const FlexColumnWidth(),
              columnCount: const FixedColumnWidth(40),
            },
            border: TableBorder(
              horizontalInside: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5),
              verticalInside: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5),
            ),
            children: [
              // Header Row
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
                    child: const Icon(CupertinoIcons.plus_circle_fill, color: CupertinoColors.activeGreen, size: 22),
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

                          // --- AUTO HEIGHT LOGIC ---
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,

                          placeholder: "...",
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                          decoration: null,
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      );
                    }).toList(),
                    GestureDetector(
                      onTap: () => widget.onRemoveRow(rowIndex),
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        child: const Icon(CupertinoIcons.minus_circle_fill, color: CupertinoColors.destructiveRed, size: 20),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
          // Bottom Bar
          // Container(
          //   padding: const EdgeInsets.symmetric(vertical: 4),
          //   decoration: BoxDecoration(
          //     border: Border(top: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5)),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       _iosActionButton(CupertinoIcons.add, "Row", widget.onAddRow),
          //       _iosActionButton(CupertinoIcons.trash, "Clear All", widget.onDeleteTable, isDestructive: true),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _deleteHeader({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.minus_circle, size: 18, color: CupertinoColors.systemGrey),
      ),
    );
  }

  Widget _iosActionButton(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? CupertinoColors.destructiveRed : CupertinoColors.activeBlue;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
    );
  }
}
