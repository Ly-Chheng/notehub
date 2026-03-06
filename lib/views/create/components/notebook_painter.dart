import 'package:flutter/material.dart';

enum PaperType { none, lines, grid }

class NotebookPainter extends CustomPainter {
  final PaperType type;
  final Color lineColor;

  NotebookPainter({required this.type, this.lineColor = const Color(0xFFE0E0E0)});

  @override
  void paint(Canvas canvas, Size size) {
    if (type == PaperType.none) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    const double spacing = 32.0; // Standard notebook spacing

    if (type == PaperType.lines) {
      // Draw horizontal lines only
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    } else if (type == PaperType.grid) {
      // Draw vertical lines
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
      // Draw horizontal lines
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant NotebookPainter oldDelegate) => 
      type != oldDelegate.type || lineColor != oldDelegate.lineColor;
}