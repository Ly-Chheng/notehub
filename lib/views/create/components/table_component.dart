// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class EditableTableComponent extends StatelessWidget {
//   final List<List<String>> tableData;
//   final Function(int rowIndex, int colIndex, String value) onCellChanged;
//   final VoidCallback onAddRow;
//   final Function(int rowIndex) onRemoveRow;
//   final VoidCallback onAddColumn;
//   final Function(int colIndex) onRemoveColumn; // New callback
//   final VoidCallback onDeleteTable;

//   const EditableTableComponent({
//     super.key,
//     required this.tableData,
//     required this.onCellChanged,
//     required this.onAddRow,
//     required this.onRemoveRow,
//     required this.onAddColumn,
//     required this.onRemoveColumn,
//     required this.onDeleteTable,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Calculate column count based on the first row
//     int columnCount = tableData.isNotEmpty ? tableData[0].length : 0;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Table(
//             // Dynamically set column widths: Data columns are flexible, last icon column is fixed
//             columnWidths: {
//               for (var i = 0; i < columnCount; i++) i: const FlexColumnWidth(),
//               columnCount: const FixedColumnWidth(40),
//             },
//             border: TableBorder.symmetric(
//               inside: BorderSide(color: Colors.grey.shade300, width: 1),
//             ),
//             children: [
//               // --- HEADER: COLUMN DELETE BUTTONS ---
//               TableRow(
//                 children: [
//                   ...List.generate(
//                       columnCount,
//                       (colIndex) => IconButton(
//                             onPressed: () => onRemoveColumn(colIndex),
//                             icon: Icon(Icons.remove_outlined, color: Colors.red, size: context.isPhone ? 20 : 25),
//                             tooltip: "Delete Column",
//                           )),
//                   const SizedBox.shrink(), // Empty space above the row-delete column
//                 ],
//               ),

//               // --- DATA ROWS ---
//               ...tableData.asMap().entries.map((rowEntry) {
//                 int rowIndex = rowEntry.key;

//                 return TableRow(
//                   decoration: rowIndex == 0 ? BoxDecoration(color: Colors.grey.withOpacity(0.1)) : null,
//                   children: [
//                     ...rowEntry.value.asMap().entries.map((colEntry) {
//                       int colIndex = colEntry.key;
//                       return Padding(
//                         padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 8 : 10),
//                         child: TextField(
//                           key: ValueKey('cell_$rowIndex\_$colIndex'),
//                           controller: TextEditingController(text: tableData[rowIndex][colIndex])
//                             ..selection = TextSelection.fromPosition(
//                               TextPosition(offset: tableData[rowIndex][colIndex].length),
//                             ),
//                           onChanged: (value) => onCellChanged(rowIndex, colIndex, value),
//                           style: TextStyle(
//                             fontSize: context.isPhone ? 16 : 18,
//                             fontFamily: 'EN-REGULAR',
//                             fontWeight: rowIndex == 0 ? FontWeight.bold : FontWeight.normal,
//                           ),
//                           decoration: const InputDecoration(
//                             border: InputBorder.none,
//                             // hintText: '...',
//                           ),
//                         ),
//                       );
//                     }).toList(),

//                     // Remove Row Button
//                     TableCell(
//                       verticalAlignment: TableCellVerticalAlignment.middle,
//                       child: IconButton(
//                         icon: Icon(Icons.remove_outlined, color: Colors.red, size: context.isPhone ? 20 : 25),
//                         onPressed: () => onRemoveRow(rowIndex),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ],
//           ),

//           // --- TABLE CONTROLS (BOTTOM) ---
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.grey.withOpacity(0.05),
//               border: Border(top: BorderSide(color: Colors.grey.shade300)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _actionButton(context, Icons.add, "Row", Colors.green, onAddRow),
//                 _actionButton(context, Icons.add, "Column", Colors.green, onAddColumn),
//                 _actionButton(context, Icons.delete, "All", Colors.red, onDeleteTable),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _actionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
//     return TextButton.icon(
//       onPressed: onTap,
//       icon: Icon(icon, size: context.isPhone ? 18 : 22, color: color),
//       label: Text(label, style: TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'EN-REGULAR')),
//     );
//   }
// }

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
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
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
              // --- TOP HEADER: COLUMN ACTIONS ---
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
                  const SizedBox.shrink(), // Corner space
                ],
              ),

              // --- DATA ROWS ---
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

                    // LEFT-SIDE ROW ACTION (iPhone style remove)
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

          // --- BOTTOM iOS STYLE TOOLBAR ---
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
          fontWeight: FontWeight.w600,
          fontFamily: 'EN-REGULAR',
        ),
      ),
    );
  }
}
