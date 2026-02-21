import 'package:flutter/material.dart';

void showHandwritingSheet(BuildContext context) {
  // Mock data for the drawing tools
  final List<Map<String, dynamic>> drawingTools = [
    {'name': 'Highlighter', 'icon': Icons.edit_attributes, 'color': Colors.amber},
    {'name': 'Pencil', 'icon': Icons.edit, 'color': Colors.orangeAccent},
    {'name': 'Pen', 'icon': Icons.pending_actions_outlined, 'color': Colors.orange},
    {'name': 'Marker', 'icon': Icons.border_color, 'color': Colors.black87},
    {'name': 'Eraser', 'icon': Icons.auto_fix_normal, 'color': Colors.blueGrey},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Header with Cancel
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          // Scrollable Tools Row
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: drawingTools.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      // Representative Tool Graphics
                      // In a real app, use Image.asset() for the custom pen illustrations
                      Container(
                        height: 120,
                        width: 40,
                        decoration: BoxDecoration(
                          color: drawingTools[index]['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              drawingTools[index]['icon'], 
                              size: 30, 
                              color: drawingTools[index]['color']
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}