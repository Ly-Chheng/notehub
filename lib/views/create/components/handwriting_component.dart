import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:project_structure/widgets/sheet_header.dart';
import 'package:signature/signature.dart';

class HandwritingCanvas extends StatefulWidget {
  final Function(Uint8List, List<Point>) onSave;
  final List<Point>? initialPoints;

  const HandwritingCanvas({
    super.key,
    required this.onSave,
    this.initialPoints,
  });

  @override
  State<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
      points: widget.initialPoints,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 25,
          ),
          SheetHeader(
            title: "Handwriting",
            saveText: "Done",
            onSave: () async {
              if (_controller.isNotEmpty) {
                final data = await _controller.toPngBytes();
                if (data != null) {
                  // Pass both image bytes and the raw points list back
                  widget.onSave(data, _controller.points);
                }
              }
              Navigator.pop(context);
            },
          ),

          // Canvas Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Signature(
                  controller: _controller,
                  backgroundColor: const Color(0xFFF9F9F9),
                ),
              ),
            ),
          ),

          // Toolbar
          Container(
            padding: const EdgeInsets.only(bottom: 30, top: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toolIcon(Icons.undo_rounded, () => _controller.undo()),
                _toolIcon(Icons.redo_rounded, () => _controller.redo()),
                _toolIcon(Icons.cleaning_services_rounded, () => _controller.clear()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolIcon(IconData icon, VoidCallback tap) {
    return IconButton(icon: Icon(icon, color: Colors.black87, size: 30), onPressed: tap);
  }
}
