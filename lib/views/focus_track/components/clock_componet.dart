import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/focus_track/clock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class ClockScreen extends StatelessWidget {
  ClockScreen({super.key});

  final ClockController controller = Get.put(ClockController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: 'Classic Clock',
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
      ),
      body: Center(
        child: Obx(() {
          return controller.isAnalog.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: ClassicClockPainter(controller.dateTime.value),
                      ),
                    ),
                    SizedBox(height: 60),
                    DigitalClock(dateTime: controller.dateTime.value),
                  ],
                )
              : DigitalClock(dateTime: controller.dateTime.value);
        }),
      ),
    );
  }
}

class DigitalClock extends StatelessWidget {
  final DateTime dateTime;

  const DigitalClock({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hour = twoDigits(dateTime.hour);
    final minute = twoDigits(dateTime.minute);
    final second = twoDigits(dateTime.second);

    return Text(
      "$hour:$minute:$second",
      style: const TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
        fontFamily: 'Courier',
      ),
    );
  }
}

class ClassicClockPainter extends CustomPainter {
  final DateTime dateTime;
  ClassicClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fillBrush = Paint()..color = Colors.white;
    final outlineBrush = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final centerFillBrush = Paint()..color = Colors.black;

    final secHandBrush = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final minHandBrush = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final hourHandBrush = Paint()
      ..color = Colors.black
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final dashBrush = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // Draw clock face
    canvas.drawCircle(center, radius, fillBrush);
    canvas.drawCircle(center, radius, outlineBrush);

    // Draw tick marks
    for (int i = 0; i < 60; i++) {
      final angle = i * 6 * pi / 180;
      final outerRadius = radius;
      final innerRadius = i % 5 == 0 ? radius - 15 : radius - 10;
      final p1 = Offset(center.dx + outerRadius * cos(angle - pi / 2), center.dy + outerRadius * sin(angle - pi / 2));
      final p2 = Offset(center.dx + innerRadius * cos(angle - pi / 2), center.dy + innerRadius * sin(angle - pi / 2));
      canvas.drawLine(p1, p2, dashBrush);
    }

    // Draw numbers
    final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    for (int i = 1; i <= 12; i++) {
      final angle = i * 30 * pi / 180;
      final x = center.dx + (radius - 40) * cos(angle - pi / 2);
      final y = center.dy + (radius - 40) * sin(angle - pi / 2);
      textPainter.text = TextSpan(text: '$i', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    // Draw hour hand
    final hourX = center.dx + 50 * cos((dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180 - pi / 2);
    final hourY = center.dy + 50 * sin((dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180 - pi / 2);
    canvas.drawLine(center, Offset(hourX, hourY), hourHandBrush);

    // Draw minute hand
    final minX = center.dx + 70 * cos((dateTime.minute + dateTime.second / 60) * 6 * pi / 180 - pi / 2);
    final minY = center.dy + 70 * sin((dateTime.minute + dateTime.second / 60) * 6 * pi / 180 - pi / 2);
    canvas.drawLine(center, Offset(minX, minY), minHandBrush);

    // Draw second hand
    final secX = center.dx + 90 * cos((dateTime.second + dateTime.millisecond / 1000) * 6 * pi / 180 - pi / 2);
    final secY = center.dy + 90 * sin((dateTime.second + dateTime.millisecond / 1000) * 6 * pi / 180 - pi / 2);
    canvas.drawLine(center, Offset(secX, secY), secHandBrush);

    // Draw center dot
    canvas.drawCircle(center, 5, centerFillBrush);
  }

  @override
  bool shouldRepaint(covariant ClassicClockPainter oldDelegate) => true;
}
