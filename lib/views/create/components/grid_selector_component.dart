import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';

void showGridSelector(BuildContext context, NoteController controller) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Row(children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red)))]),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _gridOption(Icons.not_interested, "", () => controller.updateGrid('none')),
                    _gridOption(Icons.reorder, "", () => controller.updateGrid('lines')),
                    _gridOption(Icons.grid_4x4, "", () => controller.updateGrid('grid')),
                    _gridOption(Icons.list, "", () => controller.updateGrid('listed')),
                    _gridOption(Icons.straighten, "", () => controller.updateGrid('graph')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

Widget _gridOption(IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: () {
      onTap();
      Get.back();
    },
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12), // Space around the icon
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Icon(icon, color: Colors.black, size: 70),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    ),
  );
}
