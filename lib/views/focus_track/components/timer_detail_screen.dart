// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class TimerDetailScreen extends StatefulWidget {
//   final dynamic timerKey;
//   final Map data;
//   final int initialSeconds;
//   final bool isRunning;

//   const TimerDetailScreen({
//     super.key,
//     required this.timerKey,
//     required this.data,
//     required this.initialSeconds,
//     required this.isRunning,
//   });

//   @override
//   State<TimerDetailScreen> createState() => _TimerDetailScreenState();
// }

// class _TimerDetailScreenState extends State<TimerDetailScreen> {
//   late int _currentSeconds;
//   late bool _active;
//   Timer? _ticker;

//   @override
//   void initState() {
//     super.initState();
//     _currentSeconds = widget.initialSeconds;
//     _active = widget.isRunning;
//     if (_active) _startTicker();
//   }

//   void _startTicker() {
//     _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_currentSeconds > 0) {
//         setState(() => _currentSeconds--);
//       } else {
//         _ticker?.cancel();
//         setState(() => _active = false);
//       }
//     });
//   }

//   void _toggle() {
//     setState(() {
//       _active = !_active;
//       if (_active) _startTicker();
//       else _ticker?.cancel();
//     });
//   }

//   @override
//   void dispose() {
//     _ticker?.cancel();
//     super.dispose();
//   }

//   String _formatTime(int seconds) {
//     int h = seconds ~/ 3600;
//     int m = (seconds % 3600) ~/ 60;
//     int s = seconds % 60;
//     return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     double progress = _currentSeconds / widget.data['totalSeconds'];

//     return Scaffold(
//       backgroundColor: Colors.black, // iPhone detail is always dark
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           // THE LARGE IPHONE CIRCLE
//           Center(
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   width: 300,
//                   height: 300,
//                   child: CircularProgressIndicator(
//                     value: progress,
//                     strokeWidth: 8,
//                     backgroundColor: Colors.white10,
//                     valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
//                   ),
//                 ),
//                 Text(
//                   _formatTime(_currentSeconds),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 50,
//                     fontWeight: FontWeight.w200,
//                     fontFamily: 'monospace'
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // BOTTOM BUTTONS (Cancel & Pause)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _iphoneButton("Cancel", Colors.grey[800]!, Colors.white, () => Get.back()),
//                 _iphoneButton(
//                   _active ? "Pause" : "Resume",
//                   _active ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
//                   _active ? Colors.orange : Colors.green,
//                   _toggle
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _iphoneButton(String label, Color bg, Color textCol, VoidCallback tap) {
//     return GestureDetector(
//       onTap: tap,
//       child: Container(
//         width: 80,
//         height: 80,
//         decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
//         alignment: Alignment.center,
//         child: Text(label, style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';

class TimerDetailScreen extends StatelessWidget {
  final dynamic timerKey;
  final Map data;

  const TimerDetailScreen({super.key, required this.timerKey, required this.data});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find<TimerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Get.back())),
      body: Obx(() {
        int currentSec = controller.runningSeconds[timerKey] ?? 0;
        bool isRunning = controller.activeTimerKeys.contains(timerKey);
        double progress = currentSec / data['totalSeconds'];

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(width: 280, height: 280, child: CircularProgressIndicator(value: progress, strokeWidth: 10, valueColor: AlwaysStoppedAnimation(Colors.orange))),
                  Text(controller.formatTime(currentSec), style: TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.w200)),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton("Cancel", Colors.grey[800]!, Colors.white, () => Get.back()),
                _actionButton(isRunning ? "Pause" : "Resume", isRunning ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2), isRunning ? Colors.orange : Colors.green,
                    () => controller.toggleTimer(timerKey)),
              ],
            )
          ],
        );
      }),
    );
  }

  Widget _actionButton(String title, Color bg, Color txt, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(color: txt, fontWeight: FontWeight.bold))),
    );
  }
}
