import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:signature/signature.dart';
import 'package:project_structure/widgets/sheet_header.dart';

class HandwritingCanvas extends StatefulWidget {
  final List<Map<String, dynamic>> initialLayers;
  final Function(String? filePath, List<Map<String, dynamic>> layers) onSave;

  const HandwritingCanvas({
    super.key,
    required this.onSave,
    this.initialLayers = const [],
  });

  @override
  State<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
  final GlobalKey _repaintKey = GlobalKey();
  List<SignatureController> _layers = [];
  late SignatureController _activeController;

  Color currentPenColor = Colors.black;
  double currentWidth = 2.0;
  bool isEraser = false;
  final Color canvasBgColor = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    _loadInitialLayers();
    _activeController = _createController();
  }

  void _loadInitialLayers() {
    for (var layer in widget.initialLayers) {
      final pointsData = layer['points'] as List;
      List<Point> points = pointsData.map((p) {
        return Point(Offset(p['x'], p['y']), PointType.values[p['t']], 1.0);
      }).toList();

      _layers.add(SignatureController(
        penStrokeWidth: (layer['width'] as num).toDouble(),
        penColor: Color(layer['color'] as int),
        points: points,
      ));
    }
  }

  SignatureController _createController() {
    return SignatureController(
      penStrokeWidth: isEraser ? 30.0 : currentWidth,
      penColor: isEraser ? canvasBgColor : currentPenColor,
      exportBackgroundColor: Colors.transparent,
    );
  }

  void _updateBrush({double? width, Color? color, bool? eraser}) {
    if (_activeController.isNotEmpty) {
      _layers.add(_activeController);
    } else {
      _activeController.dispose();
    }

    setState(() {
      if (width != null) currentWidth = width;
      if (color != null) currentPenColor = color;
      if (eraser != null) {
        isEraser = eraser;
      } else if (color != null || width != null) {
        isEraser = false;
      }
      _activeController = _createController();
    });
  }

  Future<void> _saveAndExit() async {
    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/draw_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(pngBytes);

      // Convert Controllers to Hive-compatible Maps
      List<SignatureController> allControllers = [..._layers, _activeController];
      List<Map<String, dynamic>> exportData = allControllers
          .where((c) => c.isNotEmpty)
          .map((c) => {
                'color': c.penColor.value,
                'width': c.penStrokeWidth,
                'points': c.points.map((p) => {'x': p.offset.dx, 'y': p.offset.dy, 't': p.type.index}).toList(),
              })
          .toList();

      widget.onSave(path, exportData);
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  @override
  void dispose() {
    for (var c in _layers) {
      c.dispose();
    }
    _activeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 100,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SheetHeader(title: "Handwriting", saveText: "Save", onSave: _saveAndExit),
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: Container(
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                decoration: BoxDecoration(color: canvasBgColor, borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  children: [
                    ..._layers.map((l) => Signature(controller: l, backgroundColor: Colors.transparent)),
                    Signature(controller: _activeController, backgroundColor: Colors.transparent),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [Colors.black, Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.amber, Colors.pink].map((c) => _colorCircle(c)).toList(),
            ),
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _toolBtn(
                  "Pen",
                  !isEraser && currentWidth == 2.0,
                  () => _updateBrush(width: 2.0),
                  imagePath: 'assets/images/pen.png',
                ),
                _toolBtn(
                  "Thin",
                  !isEraser && currentWidth == 1.0,
                  () => _updateBrush(width: 1.0),
                  imagePath: 'assets/images/pencle.png',
                ),
                _toolBtn(
                  "Highlighter",
                  !isEraser && currentWidth == 20.0,
                  () => _updateBrush(width: 20.0),
                  imagePath: 'assets/images/highlighter.png',
                ),
                _toolBtn(
                  "Eraser",
                  isEraser,
                  () => _updateBrush(eraser: true),
                  imagePath: 'assets/images/easer.png',
                ),
                IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {
                      setState(() {
                        if (_activeController.isNotEmpty) {
                          _activeController.undo();
                        } else if (_layers.isNotEmpty) {
                          _activeController = _layers.removeLast();
                        }
                      });
                    }),
                IconButton(
                    icon: const Icon(Icons.redo_outlined),
                    onPressed: () {
                      setState(() {
                        if (_activeController.isNotEmpty) {
                          _activeController.redo();
                        } else if (_layers.isNotEmpty) {
                          _activeController = _layers.removeLast();
                        }
                      });
                    }),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() {
                          _layers.clear();
                          _activeController.clear();
                        })),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorCircle(Color color) {
    bool isSelected = !isEraser && currentPenColor.value == color.value;
    return GestureDetector(
      onTap: () => _updateBrush(color: color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? AppColor().primaryColor : Colors.transparent, width: 1)),
        child: CircleAvatar(radius: 12, backgroundColor: color),
      ),
    );
  }

  Widget _toolBtn(String label, bool sel, VoidCallback tap, {String? imagePath, IconData? icon}) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                width: sel ? 55 : 30,
                height: sel ? 55 : 30,
                colorBlendMode: BlendMode.srcIn,
              )
            else if (icon != null)
              Icon(
                icon,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
