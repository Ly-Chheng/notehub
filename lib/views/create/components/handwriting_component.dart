import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class HandwritingCanvas extends StatefulWidget {
  final Function(Uint8List) onSave;

  const HandwritingCanvas({super.key, required this.onSave});

  @override
  State<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                const Text("Handwriting", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () async {
                    if (_controller.isNotEmpty) {
                      final data = await _controller.toPngBytes();
                      if (data != null) widget.onSave(data);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Signature(
              controller: _controller,
              backgroundColor: const Color(0xFFF5F5F5),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toolIcon(Icons.undo, () => _controller.undo()),
                _toolIcon(Icons.redo, () => _controller.redo()),
                _toolIcon(Icons.delete_outline, () => _controller.clear()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolIcon(IconData icon, VoidCallback tap) {
    return IconButton(icon: Icon(icon, color: Colors.black54), onPressed: tap);
  }
}
