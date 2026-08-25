// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';

// class ImageZoom extends StatelessWidget {
//   final String imagePath;
//   const ImageZoom({super.key, required this.imagePath});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(
//         title: "",
//         context: context,
//       ),
//       body: Center(
//         child: InteractiveViewer(
//           panEnabled: true,
//           minScale: 1,
//           maxScale: 5,
//           child: imagePath.startsWith('http') ? Image.network(imagePath) : Image.file(File(imagePath)),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageZoom extends StatefulWidget {
  final String imagePath;
  const ImageZoom({super.key, required this.imagePath});

  @override
  State<ImageZoom> createState() => _ImageZoomState();
}

class _ImageZoomState extends State<ImageZoom> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final position = details.localPosition;
    const double targetScale = 3.0;

    final Matrix4 endMatrix;

    if (_transformationController.value != Matrix4.identity()) {
      endMatrix = Matrix4.identity();
    } else {
      endMatrix = Matrix4.identity()
        ..translate(-position.dx * (targetScale - 1), -position.dy * (targetScale - 1))
        ..scale(targetScale);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTapDown: _onDoubleTapDown,
            onDoubleTap: () {},
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: SizedBox.expand(
              child: InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: true,
                minScale: 1.0,
                maxScale: 5.0,
                child: widget.imagePath.startsWith('http')
                    ? Image.network(
                        widget.imagePath,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showControls ? 1.0 : 0.0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () {
                    if (_showControls) Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
