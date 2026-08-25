import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/navigation_create_note/notebook_painter.dart';
import 'package:project_structure/widgets/custom_button.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/confirm_bottomsheet.dart';
import 'package:project_structure/widgets/custom_template.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class HandwritingCanvas extends StatefulWidget {
  final List<Map<String, dynamic>> initialLayers;
  final Function(String? filePath, List<Map<String, dynamic>> layers) onSave;
  final String noteId;

  const HandwritingCanvas({
    super.key,
    required this.onSave,
    this.initialLayers = const [],
    required this.noteId,
  });

  @override
  State<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
  final GlobalKey _repaintKey = GlobalKey();
  final List<SignatureController> _layers = [];
  late SignatureController _activeController;

  Color currentPenColor = Colors.black;
  double currentWidth = 2.0;
  bool isEraser = false;
  bool showColorPalette = false;
  bool showLines = false;
  int canvasMode = 0;

  late final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  late final canvasBgColor = isDarkMode ? const Color(0xFFF9F9F9) : const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    _loadInitialLayers();
    _activeController = _createController();

    _loadCanvasMode();
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

      List<SignatureController> allControllers = [..._layers, _activeController];
      List<Map<String, dynamic>> exportData = allControllers
          .where((c) => c.isNotEmpty)
          .map((c) => {
                'color': c.penColor.toARGB32(),
                'width': c.penStrokeWidth,
                'points': c.points.map((p) => {'x': p.offset.dx, 'y': p.offset.dy, 't': p.type.index}).toList(),
              })
          .toList();

      widget.onSave(path, exportData);
      Get.back();
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('cancel'.tr, style: text16(context).copyWith(color: Colors.red)),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                        icon: Image.asset(
                          'assets/images/undo.png',
                          width: context.isPhone ? 24 : 30,
                          height: context.isPhone ? 24 : 30,
                        ),
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
                        icon: Image.asset(
                          'assets/images/redo.png',
                          width: context.isPhone ? 24 : 30,
                          height: context.isPhone ? 24 : 30,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_activeController.isNotEmpty) {
                              _activeController.redo();
                            } else if (_layers.isNotEmpty) {
                              _activeController = _layers.removeLast();
                            }
                          });
                        }),
                    TextButton(
                        onPressed: _saveAndExit,
                        child: Text(
                          "save".tr,
                          style: text16(context).copyWith(color: AppColor().primaryColor),
                        ))
                  ],
                ),
              ],
            ),
            Expanded(
              child: RepaintBoundary(
                key: _repaintKey,
                child: Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(color: canvasBgColor),
                  // child: Stack(
                  //   children: [
                  //     ..._layers.map((l) => Signature(controller: l, backgroundColor: Colors.transparent)),
                  //     Signature(controller: _activeController, backgroundColor: Colors.transparent),
                  //   ],
                  // ),
                  child: Stack(
                    children: [
                      ..._layers.map((l) => Signature(controller: l, backgroundColor: Colors.transparent)),
                      Signature(controller: _activeController, backgroundColor: Colors.transparent),
                      if (canvasMode > 0)
                        IgnorePointer(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: NotebookPainter(mode: canvasMode),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(color: Theme.of(context).cardColor, child: _buildBottomActions()),
          ],
        ),
      ),
    );
  }

  void _pickCustomColor() {
    Color tempColor = currentPenColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'pick_a_color'.tr,
            style: text18(context),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentPenColor,
              onColorChanged: (color) => tempColor = color,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text('cancel'.tr, style: text16(context)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('apply'.tr, style: text16(context)),
                  onPressed: () {
                    _updateBrush(color: tempColor);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadCanvasMode() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      canvasMode = prefs.getInt(
            'canvas_mode_${widget.noteId}',
          ) ??
          0;
    });
  }

  Future<void> _saveCanvasMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'canvas_mode_${widget.noteId}',
      mode,
    );

    setState(() {
      canvasMode = mode;
    });
  }

  Widget _buildBottomActions() {
    final List<Color> colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.amber,
      Colors.pink,
    ];

    return SafeArea(
      child: Column(
        children: [
          if (showColorPalette) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickCustomColor,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: context.isPhone ? 5 : 10,
                      ),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor().gray,
                      ),
                      child: CircleAvatar(
                        radius: context.isPhone ? 12 : 14,
                        backgroundColor: AppColor().white,
                        child: Icon(
                          Icons.add,
                          color: AppColor().black,
                          size: context.isPhone ? 18 : 23,
                        ),
                      ),
                    ),
                  ),
                  // ...colors.map((c) => _colorCircle(c)).toList(),
                  ...colors.map((c) => _colorCircle(c)),
                  if (!colors.contains(currentPenColor) && !isEraser) _colorCircle(currentPenColor),
                ],
              ),
            ),
          ],
          SizedBox(
            height: 5,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                toolBtn(
                  "Pen",
                  !isEraser && currentWidth == 2.0,
                  () => _updateBrush(width: 2.0),
                  imagePath: 'assets/images/pen.png',
                ),
                toolBtn(
                  "Thin",
                  !isEraser && currentWidth == 1.0,
                  () => _updateBrush(width: 1.0),
                  imagePath: 'assets/images/pencle.png',
                ),
                toolBtn(
                  "Highlighter",
                  !isEraser && currentWidth == 20.0,
                  () => _updateBrush(width: 20.0),
                  imagePath: 'assets/images/highlighter.png',
                ),
                toolBtn(
                  "Eraser",
                  isEraser,
                  () => _updateBrush(eraser: true),
                  imagePath: 'assets/images/easer.png',
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      showColorPalette = !showColorPalette;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.color_lens,
                      size: showColorPalette ? 30 : 30,
                      color: AppColor().green,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    canvasMode == 0 ? Icons.grid_off : (canvasMode == 1 ? Icons.view_headline : Icons.grid_on),
                    size: 25,
                    color: canvasMode == 0 ? AppColor().gray : AppColor().primaryColor,
                  ),
                  onPressed: () {
                    ConfirmBottomSheet.show(
                      context: context,
                      title: "choose_template".tr,
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomTemplate(
                            label: "none".tr,
                            icon: Icons.close,
                            isSelected: canvasMode == 0,
                            onTap: () async {
                              await _saveCanvasMode(0);
                              Get.back();
                            },
                          ),
                          CustomTemplate(
                            label: "lines".tr,
                            icon: Icons.view_headline,
                            isSelected: canvasMode == 1,
                            onTap: () async {
                              await _saveCanvasMode(1);
                              Get.back();
                            },
                          ),
                          CustomTemplate(
                            label: "grid".tr,
                            icon: Icons.grid_on,
                            isSelected: canvasMode == 2,
                            onTap: () async {
                              await _saveCanvasMode(2);
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                GrobleButton(
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
    bool isSelected = !isEraser && currentPenColor == color;
    return GestureDetector(
      onTap: () => _updateBrush(color: color),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.isPhone ? 5 : 10,
        ),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? AppColor().primaryColor : Colors.transparent, width: 1)),
        child: CircleAvatar(radius: context.isPhone ? 12 : 14, backgroundColor: color),
      ),
    );
  }

  Widget toolBtn(String label, bool sel, VoidCallback tap, {String? imagePath, IconData? icon, BuildContext? context}) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath,
              width: sel ? 60 : 40,
              height: sel ? 60 : 40,
              colorBlendMode: BlendMode.srcIn,
            )
          else if (icon != null)
            Icon(
              icon,
              size: context!.isPhone ? 24 : 30,
            ),
        ],
      ),
    );
  }
}
