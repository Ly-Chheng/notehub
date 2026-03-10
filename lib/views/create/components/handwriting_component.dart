import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:signature/signature.dart';
import 'package:project_structure/widgets/sheet_header.dart';

class HandwritingCanvas extends StatefulWidget {
  final Function(String? filePath, List<Point> points, Color color, double width) onSave;
  final List<Point>? initialPoints;
  final Color? initialColor;
  final double? initialWidth;

  const HandwritingCanvas({
    super.key,
    required this.onSave,
    this.initialPoints,
    this.initialColor,
    this.initialWidth,
  });

  @override
  State<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
  late SignatureController _controller;
  late Color currentPenColor;
  late double currentWidth;

  @override
  void initState() {
    super.initState();
    // Initialize with passed values from Hive or defaults
    currentPenColor = widget.initialColor ?? Colors.black;
    currentWidth = widget.initialWidth ?? 3.0;

    _initController(widget.initialPoints);
  }

  void _initController(List<Point>? points) {
    _controller = SignatureController(
      penStrokeWidth: currentWidth,
      penColor: currentPenColor,
      exportBackgroundColor: Colors.white,
      points: points,
    );
  }

  // Updates the brush style while maintaining the current drawing
  void _updateBrush({double? width, Color? color}) {
    final existingPoints = _controller.points;
    setState(() {
      if (width != null) currentWidth = width;
      if (color != null) currentPenColor = color;

      _controller.dispose();
      _initController(existingPoints);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.97,
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
                  final directory = await getApplicationDocumentsDirectory();
                  final path = '${directory.path}/draw_${DateTime.now().millisecondsSinceEpoch}.png';
                  await File(path).writeAsBytes(data);

                  // Return all data to the main screen
                  widget.onSave(path, _controller.points, currentPenColor, currentWidth);
                }
              } else {
                widget.onSave(null, [], currentPenColor, currentWidth);
              }
              Navigator.pop(context);
            },
          ),

          // Tool & Color Selection Bar

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Signature(
                  controller: _controller,
                  backgroundColor: const Color(0xFFF9F9F9),
                ),
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildToolBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _toolButton(
                imagePath: 'assets/images/pen.png', // your pen image
                label: "Pen",
                isSelected: currentWidth == 4.0,
                onTap: () => _updateBrush(width: 4.0),
              ),
              _toolButton(
                imagePath: 'assets/images/pencle.png', // your pen image
                label: "Pencle",
                isSelected: currentWidth == 1,
                onTap: () => _updateBrush(width: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toolButton({
    String? imagePath, // optional image asset path
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath,
              width: context.isPhone ? 40 : 50,
              height: context.isPhone ? 40 : 50,
              //color: isSelected ? AppColor().primaryColor : Colors.grey,
              colorBlendMode: BlendMode.srcIn, // tint the image
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: context.isPhone ? 10 : 12,
              fontFamily: 'EN-REHURE',
              color: isSelected ? AppColor().primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorCircle(Color color) {
    // bool isSelected = currentPenColor == color;
    // Compare using .value to ensure accuracy (int vs int)
    bool isSelected = currentPenColor.value == color.value;
    return GestureDetector(
      onTap: () => _updateBrush(color: color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? AppColor().primaryColor : Colors.transparent, width: 1.5),
        ),
        child: CircleAvatar(radius: context.isPhone ? 9 : 12, backgroundColor: color),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _colorCircle(Colors.black),
                _colorCircle(Colors.red),
                _colorCircle(Colors.blue),
                _colorCircle(Colors.green),
                _colorCircle(Colors.grey),
                _colorCircle(Colors.black54),
                _colorCircle(Colors.pink),
                _colorCircle(Colors.orange),
                _colorCircle(Colors.yellow),
                _colorCircle(Colors.purple),
                _colorCircle(Colors.brown),
                _colorCircle(Colors.cyan),
                _colorCircle(Colors.teal),
                _colorCircle(Colors.indigo),
                _colorCircle(Colors.lime),
                _colorCircle(Colors.amber),
              ],
            ),
          ),
          Row(
            children: [
              _buildToolBar(),
              const Spacer(),
              IconButton(
                  icon: Icon(
                    Icons.undo,
                    color: AppColor().primaryColor,
                    size: context.isPhone ? 20 : 24,
                  ),
                  onPressed: () => _controller.undo()),
              IconButton(
                  icon: Icon(
                    Icons.redo_rounded,
                    color: AppColor().primaryColor,
                    size: context.isPhone ? 20 : 24,
                  ),
                  onPressed: () => _controller.redo()),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: context.isPhone ? 20 : 24,
                ),
                onPressed: () => _controller.clear(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
