import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/focus_track/stopwatch_controller.dart';

class StopwatchScreen extends StatelessWidget {
  StopwatchScreen({super.key});

  final StopwatchController controller = Get.put(StopwatchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                _buildTimerDisplay(context),
                const SizedBox(height: 15),
                _buildLapList(),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: _buildControls(context),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context) {
    return Obx(() => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: context.isPhone ? 270 : 330,
              height: context.isPhone ? 270 : 330,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: CircularProgressIndicator(
                value: (controller.milliseconds.value % 60000) / 60000,
                strokeWidth: context.isPhone ? 10 : 12,
                backgroundColor: Colors.grey.shade100,
                strokeCap: StrokeCap.round,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4D7CFF)),
              ),
            ),
            Text(
              controller.formatTime(controller.milliseconds.value),
              style: TextStyle(
                fontFamily: 'EN-REGULAR',
                fontSize: context.isPhone ? 50 : 60,
                letterSpacing: -1,
              ),
            ),
          ],
        ));
  }

  Widget _buildLapList() {
    return SizedBox(
      height: 150,
      child: Obx(() => Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Lap", style: TextStyle(color: Colors.grey, fontFamily: 'EN-REGULAR')),
                  Text("Lap Time", style: TextStyle(color: Colors.grey, fontFamily: 'EN-REGULAR')),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.laps.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Lap ${controller.laps.length - index}", style: TextStyle(fontSize: context.isPhone ? 14 : 16, fontFamily: 'EN-REGULAR')),
                          Text(controller.laps[index], style: TextStyle(fontSize: context.isPhone ? 14 : 16, fontFamily: 'EN-BOLD')),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _roundButton(Icons.refresh, controller.resetStopwatch, context),
            GestureDetector(
              onTap: controller.startStopwatch,
              child: Icon(
                controller.isRunning.value ? Icons.stop_circle : Icons.play_circle_filled,
                size: context.isPhone ? 70 : 90,
                color: const Color(0xFF4D7CFF),
              ),
            ),
            _roundButton(Icons.flag_outlined, controller.addLap, context),
          ],
        ));
  }

  Widget _roundButton(IconData icon, VoidCallback onTap, BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }
}
// import 'dart:math' as Math;

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/controllers/focus_track/stopwatch_controller.dart';

// class StopwatchScreen extends StatelessWidget {
//   StopwatchScreen({super.key});

//   final StopwatchController controller = Get.put(StopwatchController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
//             child: Column(
//               children: [
//                 _buildTimerDisplay(context),
//                 const SizedBox(height: 20),
//                 _buildLapList(),
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 50),
//                   child: _buildControls(context),
//                 ),
//                 const SizedBox(height: 60),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTimerDisplay(BuildContext context) {
//     return Obx(() {
//       double progress = (controller.milliseconds.value % 60000) / 60000;
//       double size = context.isPhone ? 280 : 340;

//       return Stack(
//         alignment: Alignment.center,
//         children: [
//           // Custom Painted Circle Timer
//           CustomPaint(
//             size: Size(size, size),
//             painter: _TimerPainter(progress: progress),
//           ),
//           // Clock numbers
//           _buildClockFace(context, size / 2),
//           // Digital readout slightly below center
//           Positioned(
//             bottom: context.isPhone ? 40 : 50,
//             child: Text(
//               controller.formatTime(controller.milliseconds.value),
//               style: TextStyle(
//                 fontFamily: 'EN-REGULAR',
//                 fontSize: context.isPhone ? 24 : 28,
//                 color: Colors.black87,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       );
//     });
//   }

//   Widget _buildClockFace(BuildContext context, double radius) {
//     final numbers = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

//     return SizedBox(
//       width: radius * 2,
//       height: radius * 2,
//       child: Stack(
//         children: numbers.map((num) {
//           final angle = (num * 6) * Math.pi / 180 - Math.pi / 2;
//           final x = radius + (radius * 0.85 * Math.cos(angle));
//           final y = radius + (radius * 0.85 * Math.sin(angle));

//           return Positioned(
//             left: x - 10, // Adjust for text width
//             top: y - 10,  // Adjust for text height
//             child: Text(
//               "$num",
//               style: TextStyle(
//                 fontSize: context.isPhone ? 18 : 22,
//                 fontFamily: 'EN-REGULAR',
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildLapList() {
//     return SizedBox(
//       height: 150,
//       child: Obx(() => Column(
//             children: [
//               const Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Lap", style: TextStyle(color: Colors.grey, fontFamily: 'EN-REGULAR')),
//                   Text("Lap Time", style: TextStyle(color: Colors.grey, fontFamily: 'EN-REGULAR')),
//                 ],
//               ),
//               const Divider(height: 20),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: controller.laps.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Lap ${controller.laps.length - index}",
//                             style: TextStyle(
//                               fontSize: context.isPhone ? 14 : 16,
//                               fontFamily: 'EN-REGULAR',
//                             ),
//                           ),
//                           Text(
//                             controller.laps[index],
//                             style: TextStyle(
//                               fontSize: context.isPhone ? 14 : 16,
//                               fontFamily: 'EN-BOLD',
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           )),
//     );
//   }

//   Widget _buildControls(BuildContext context) {
//     return Obx(() => Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _roundButton(Icons.refresh, controller.resetStopwatch, context),
//             GestureDetector(
//               onTap: controller.startStopwatch,
//               child: Icon(
//                 controller.isRunning.value ? Icons.stop_circle : Icons.play_circle_filled,
//                 size: context.isPhone ? 70 : 90,
//                 color: const Color(0xFF4D7CFF),
//               ),
//             ),
//             _roundButton(Icons.flag_outlined, controller.addLap, context),
//           ],
//         ));
//   }

//   Widget _roundButton(IconData icon, VoidCallback onTap, BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           shape: BoxShape.circle,
//           boxShadow: const [
//             BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
//           ],
//         ),
//         child: Icon(icon, color: Colors.black87, size: 24),
//       ),
//     );
//   }
// }

// // Custom painter for the circular timer
// class _TimerPainter extends CustomPainter {
//   final double progress;

//   _TimerPainter({required this.progress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;

//     // Draw background circle
//     final backgroundPaint = Paint()
//       ..color = Colors.grey.shade300
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 12;
//     canvas.drawCircle(center, radius - 6, backgroundPaint);

//     // Draw progress arc
//     final progressPaint = Paint()
//       ..color = const Color(0xFF0079C1)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 12
//       ..strokeCap = StrokeCap.round;

//     double sweepAngle = 2 * Math.pi * progress;
//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius - 6),
//       -Math.pi / 2, // start from top
//       sweepAngle,
//       false,
//       progressPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant _TimerPainter oldDelegate) {
//     return oldDelegate.progress != progress;
//   }
// }


// import 'dart:math' as Math;

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/controllers/focus_track/stopwatch_controller.dart';

// class StopwatchScreen extends StatelessWidget {
//   StopwatchScreen({super.key});

//   final StopwatchController controller = Get.put(StopwatchController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
//             child: Column(
//               children: [
//                 _buildClockDisplay(context),
//                 const SizedBox(height: 20),
//                 _buildLapList(),
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 50),
//                   child: _buildControls(context),
//                 ),
//                 const SizedBox(height: 60),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildClockDisplay(BuildContext context) {
//     double size = context.isPhone ? 280 : 340;

//     return Obx(() {
//       return SizedBox(
//         width: size,
//         height: size,
//         child: CustomPaint(
//           painter: _ClockPainter(milliseconds: controller.milliseconds.value),
//         ),
//       );
//     });
//   }

//   Widget _buildLapList() {
//     return SizedBox(
//       height: 150,
//       child: Obx(() => Column(
//             children: [
//               const Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Lap", style: TextStyle(color: Colors.grey, fontFamily: 'EN-REGULAR')),
//                   Text("Lap Time", style: TextStyle(color: Colors.grey, fontFamily: 'EN-REGULAR')),
//                 ],
//               ),
//               const Divider(height: 20),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: controller.laps.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Lap ${controller.laps.length - index}",
//                             style: TextStyle(
//                               fontSize: context.isPhone ? 14 : 16,
//                               fontFamily: 'EN-REGULAR',
//                             ),
//                           ),
//                           Text(
//                             controller.laps[index],
//                             style: TextStyle(
//                               fontSize: context.isPhone ? 14 : 16,
//                               fontFamily: 'EN-BOLD',
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           )),
//     );
//   }

//   Widget _buildControls(BuildContext context) {
//     return Obx(() => Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _roundButton(Icons.refresh, controller.resetStopwatch, context),
//             GestureDetector(
//               onTap: controller.startStopwatch,
//               child: Icon(
//                 controller.isRunning.value ? Icons.stop_circle : Icons.play_circle_filled,
//                 size: context.isPhone ? 70 : 90,
//                 color: const Color(0xFF4D7CFF),
//               ),
//             ),
//             _roundButton(Icons.flag_outlined, controller.addLap, context),
//           ],
//         ));
//   }

//   Widget _roundButton(IconData icon, VoidCallback onTap, BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           shape: BoxShape.circle,
//           boxShadow: const [
//             BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
//           ],
//         ),
//         child: Icon(icon, color: Colors.black87, size: 24),
//       ),
//     );
//   }
// }

// // Clock Painter
// class _ClockPainter extends CustomPainter {
//   final int milliseconds;

//   _ClockPainter({required this.milliseconds});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;

//     final Paint circlePaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;

//     final Paint borderPaint = Paint()
//       ..color = Colors.grey.shade400
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4;

//     // Draw clock face
//     canvas.drawCircle(center, radius, circlePaint);
//     canvas.drawCircle(center, radius, borderPaint);

//     // Draw numbers
//     final textPainter = TextPainter(
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr,
//     );

//     for (int i = 1; i <= 12; i++) {
//       double angle = (i * 30) * Math.pi / 180 - Math.pi / 2;
//       final offset = Offset(
//         center.dx + radius * 0.8 * Math.cos(angle),
//         center.dy + radius * 0.8 * Math.sin(angle),
//       );
//       textPainter.text = TextSpan(
//         text: "$i",
//         style: TextStyle(
//           fontSize: 18,
//           color: Colors.black87,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'EN-REGULAR',
//         ),
//       );
//       textPainter.layout();
//       textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
//     }

//     // Convert milliseconds to total seconds
//     double totalSeconds = milliseconds / 1000;

//     // Draw second hand
//     double secondAngle = (totalSeconds % 60) * 6 * Math.pi / 180 - Math.pi / 2;
//     final secondHand = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 2
//       ..strokeCap = StrokeCap.round;
//     canvas.drawLine(center, center + Offset(radius * 0.9 * Math.cos(secondAngle), radius * 0.9 * Math.sin(secondAngle)), secondHand);

//     // Draw minute hand
//     double minuteAngle = ((totalSeconds / 60) % 60) * 6 * Math.pi / 180 - Math.pi / 2;
//     final minuteHand = Paint()
//       ..color = Colors.black87
//       ..strokeWidth = 4
//       ..strokeCap = StrokeCap.round;
//     canvas.drawLine(center, center + Offset(radius * 0.7 * Math.cos(minuteAngle), radius * 0.7 * Math.sin(minuteAngle)), minuteHand);

//     // Draw center dot
//     final centerDot = Paint()..color = Colors.black87;
//     canvas.drawCircle(center, 5, centerDot);
//   }

//   @override
//   bool shouldRepaint(covariant _ClockPainter oldDelegate) {
//     return oldDelegate.milliseconds != milliseconds;
//   }
// }