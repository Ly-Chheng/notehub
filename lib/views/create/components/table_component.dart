import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditableTableComponent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    int columnCount = tableData.isNotEmpty ? tableData[0].length : 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Table(
            columnWidths: {
              for (var i = 0; i < columnCount; i++) i: const FlexColumnWidth(),
              columnCount: const FixedColumnWidth(35), // Side actions
            },
            border: TableBorder.all(color: Colors.black12, width: 1),
            children: [
              TableRow(
                children: [
                  ...List.generate(
                    columnCount,
                    (index) => _headerCell(
                      context,
                      icon: Icons.horizontal_rule_rounded,
                      onTap: () => onRemoveColumn(index),
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox.shrink(), 
                ],
              ),

              ...tableData.asMap().entries.map((rowEntry) {
                int rowIndex = rowEntry.key;
                return TableRow(
                  children: [
                    ...rowEntry.value.asMap().entries.map((colEntry) {
                      int colIndex = colEntry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: TextField(
                          key: ValueKey('cell_$rowIndex\_$colIndex'),
                          controller: TextEditingController(text: tableData[rowIndex][colIndex])
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: tableData[rowIndex][colIndex].length),
                            ),
                          onChanged: (value) => onCellChanged(rowIndex, colIndex, value),
                          maxLines: null, // Allow expanding height like iPhone notes
                          style: TextStyle(
                            fontSize: context.isPhone ? 16 : 18,
                            fontFamily: 'EN-REGULAR',
                          ),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      );
                    }).toList(),

                    _headerCell(
                      context,
                      icon: Icons.remove_circle_outline,
                      onTap: () => onRemoveRow(rowIndex),
                      color: Colors.red.shade300,
                    ),
                  ],
                );
              }).toList(),
            ],
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _textActionButton(context, "Add Row", onAddRow),
                _textActionButton(context, "Add Column", onAddColumn),
                _textActionButton(context, "Delete All", onDeleteTable, isDestructive: true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _headerCell(BuildContext context, {required IconData icon, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _textActionButton(BuildContext context, String text, VoidCallback onTap, {bool isDestructive = false}) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isDestructive ? Colors.red : Colors.blueAccent,
          fontFamily: 'EN-REGULAR',
        ),
      ),
    );
  }
}
