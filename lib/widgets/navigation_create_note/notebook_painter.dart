import 'package:flutter/material.dart';

class NotebookPainter extends CustomPainter {
  final int mode;
  final double spacing;
  final double marginX;
  final Color lineColor;
  final Color marginColor;

  NotebookPainter({
    required this.mode,
    this.spacing = 40.0,
    this.marginX = 40.0,
    this.lineColor = Colors.blue,
    this.marginColor = Colors.red,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mode == 0) return;

    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final marginPaint = Paint()
      ..color = marginColor.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    if (mode == 2) {
      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          linePaint,
        );
      }
    }

    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant NotebookPainter oldDelegate) {
    return oldDelegate.mode != mode || oldDelegate.spacing != spacing || oldDelegate.marginX != marginX || oldDelegate.lineColor != lineColor || oldDelegate.marginColor != marginColor;
  }
}
