import 'package:flutter/material.dart';

enum PaperType { none, lines, collegeRuled, grid, engineering, dots }

class NotebookPainter extends CustomPainter {
  final PaperType type;
  final Color lineColor;
  final Color marginColor;

  NotebookPainter({
    required this.type,
    this.lineColor = const Color(0xFFE0E0E0),
    this.marginColor = const Color(0xFFFFCDD2),  
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (type == PaperType.none) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    final marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 1.5;

    double spacing = 32.0;
    bool hasVerticalMargin = false;

    // 1. Handle Dot Style separately
    if (type == PaperType.dots) {
      const double dotSpacing = 28.0;
      for (double x = dotSpacing; x < size.width; x += dotSpacing) {
        for (double y = dotSpacing; y < size.height; y += dotSpacing) {
          canvas.drawCircle(Offset(x, y), 1.0, paint);
        }
      }
      return;
    }

    // 2. Configure Spacing and Margins for Lines/Grids
    switch (type) {
      case PaperType.lines:
        spacing = 32.0;
        hasVerticalMargin = true;
        break;
      case PaperType.collegeRuled:
        spacing = 24.0;
        hasVerticalMargin = true;
        break;
      case PaperType.grid:
        spacing = 30.0;
        break;
      case PaperType.engineering:
        spacing = 15.0;
        break;
      default:
        break;
    }

    // 3. Draw Horizontal Lines
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 4. Draw Vertical Lines (only for grid/engineering)
    if (type == PaperType.grid || type == PaperType.engineering) {
      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    // 5. Draw Red Vertical Margin Line (Like the image you provided)
    if (hasVerticalMargin) {
      canvas.drawLine(const Offset(50, 0), Offset(50, size.height), marginPaint);
    }
  }

  @override
  bool shouldRepaint(covariant NotebookPainter oldDelegate) => type != oldDelegate.type || lineColor != oldDelegate.lineColor;
}
