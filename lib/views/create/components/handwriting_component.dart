// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:project_structure/widgets/sheet_header.dart';
// import 'package:signature/signature.dart';

// class HandwritingCanvas extends StatefulWidget {
//   final Function(Uint8List, List<Point>) onSave;
//   final List<Point>? initialPoints;

//   const HandwritingCanvas({
//     super.key,
//     required this.onSave,
//     this.initialPoints,
//   });

//   @override
//   State<HandwritingCanvas> createState() => _HandwritingCanvasState();
// }

// class _HandwritingCanvasState extends State<HandwritingCanvas> {
//   late SignatureController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = SignatureController(
//       penStrokeWidth: 2,
//       penColor: Colors.black,
//       exportBackgroundColor: Colors.transparent,
//       points: widget.initialPoints,
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 100,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           SizedBox(
//             height: 25,
//           ),
//           SheetHeader(
//             title: "Handwriting",
//             saveText: "Done",
//             // onSave: () async {
//             //   if (_controller.isNotEmpty) {
//             //     final data = await _controller.toPngBytes();
//             //     if (data != null) {
//             //       // Pass both image bytes and the raw points list back
//             //       widget.onSave(data, _controller.points);
//             //     }
//             //   }
//             //   Navigator.pop(context);
//             // },
//             onSave: () async {
//               if (_controller.points.isNotEmpty) {
//                 final data = await _controller.toPngBytes();
//                 if (data != null) {
//                   widget.onSave(data, _controller.points);
//                 }
//               } else {
//                 // return empty points to parent
//                 widget.onSave(Uint8List(0), []);
//               }

//               Navigator.pop(context);
//             },
//           ),

//           // Canvas Area
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade200),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Signature(
//                   controller: _controller,
//                   backgroundColor: const Color(0xFFF9F9F9),
//                 ),
//               ),
//             ),
//           ),

//           // Toolbar
//           Container(
//             padding: const EdgeInsets.only(bottom: 30, top: 10),
//             color: Colors.white,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _toolIcon(Icons.undo_rounded, () => _controller.undo()),
//                 _toolIcon(Icons.redo_rounded, () => _controller.redo()),
//                 _toolIcon(Icons.cleaning_services_rounded, () => _controller.clear()),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _toolIcon(IconData icon, VoidCallback tap) {
//     return IconButton(icon: Icon(icon, color: Colors.black87, size: 30), onPressed: tap);
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:signature/signature.dart';
import 'package:project_structure/widgets/sheet_header.dart';

class HandwritingCanvas extends StatefulWidget {
  final Function(String? filePath, List<Point> points) onSave;
  final List<Point>? initialPoints;

  const HandwritingCanvas({super.key, required this.onSave, this.initialPoints});

  @override
  State<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      points: widget.initialPoints,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SheetHeader(
            title: "Handwriting",
            saveText: "Done",
            onSave: () async {
              if (_controller.isNotEmpty) {
                final Uint8List? data = await _controller.toPngBytes();
                if (data != null) {
                  // Save bytes to a physical file
                  final directory = await getApplicationDocumentsDirectory();
                  final path = '${directory.path}/draw_${DateTime.now().millisecondsSinceEpoch}.png';
                  await File(path).writeAsBytes(data);
                  widget.onSave(path, _controller.points);
                }
              } else {
                // If the user cleared the canvas, return null
                widget.onSave(null, []);
              }
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Signature(controller: _controller, backgroundColor: const Color(0xFFF9F9F9)),
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          IconButton(
              icon: Icon(
                Icons.undo,
                color: AppColor().primaryColor,
              ),
              onPressed: () => _controller.undo()),
          IconButton(
            icon: Icon(
              Icons.redo_rounded,
              color: AppColor().primaryColor,
            ),
            onPressed: () => _controller.redo(),
          ),
          Spacer(),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _controller.clear()),
        ],
      ),
    );
  }
}
