// import 'dart:async';
// import 'package:flutter/material.dart';

// class StopwatchScreen extends StatefulWidget {
//   const StopwatchScreen({super.key});

//   @override
//   _StopwatchScreenState createState() => _StopwatchScreenState();
// }

// class _StopwatchScreenState extends State<StopwatchScreen> {
//   Timer? _timer;
//   int _milliseconds = 0;
//   bool _isRunning = false;
//   List<String> _laps = [];

//   void _startStopwatch() {
//     if (_isRunning) {
//       _timer?.cancel();
//     } else {
//       _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
//         setState(() {
//           _milliseconds += 10;
//         });
//       });
//     }
//     setState(() => _isRunning = !_isRunning);
//   }

//   void _resetStopwatch() {
//     _timer?.cancel();
//     setState(() {
//       _milliseconds = 0;
//       _isRunning = false;
//       _laps.clear();
//     });
//   }

//   void _addLap() {
//     setState(() {
//       _laps.insert(0, _formatTime(_milliseconds));
//     });
//   }

//   String _formatTime(int ms) {
//     int hundreds = (ms % 1000) ~/ 10;
//     int seconds = (ms ~/ 1000) % 60;
//     int minutes = (ms ~/ 60000) % 60;
//     return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${hundreds.toString().padLeft(2, '0')}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const Spacer(),
//               _buildTimerDisplay(),
//               const Spacer(),
//               _buildLapList(),
//               const SizedBox(height: 20),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 50),
//                 child: _buildControls(),
//               ),
//               const SizedBox(height: 60),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTimerDisplay() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Container(
//           width: 250,
//           height: 250,
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.transparent,
//             boxShadow: [
//               BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 15),
//               BoxShadow(color: Color(0x1A000000), offset: Offset(5, 5), blurRadius: 15),
//             ],
//           ),
//           child: CircularProgressIndicator(
//             value: (_milliseconds % 60000) / 60000, // Syncs with seconds
//             strokeWidth: 10,
//             backgroundColor: Theme.of(context).cardColor,
//             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF0F2F9)),
//           ),
//         ),
//         Text(
//           _formatTime(_milliseconds),
//           style: const TextStyle(fontFamily: 'EN-BOLD',fontSize: 54, fontWeight: FontWeight.w300, letterSpacing: -1),
//         ),
//       ],
//     );
//   }

//   Widget _buildLapList() {
//     return SizedBox(
//       height: 150,
//       child: Column(
//         children: [
//           const Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("Lap", style: TextStyle(color: Colors.grey, fontFamily: 'EN-REGULAR')),
//               Text("Lap Time", style: TextStyle(color: Colors.grey, fontFamily: 'EN-REGULAR')),
//             ],
//           ),
//           const Divider(height: 20),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _laps.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("Lap ${_laps.length - index}", style: TextStyle(fontFamily: 'EN-REGULAR')),
//                       Text(_laps[index], style: const TextStyle(fontFamily: 'EN-BOLD')),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildControls() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _roundButton(Icons.refresh, _resetStopwatch),
//         GestureDetector(
//           onTap: _startStopwatch,
//           child: Icon(
//             _isRunning ? Icons.stop_circle : Icons.play_circle_filled,
//             size: 70,
//             color: const Color(0xFF4D7CFF),
//           ),
//         ),
//         _roundButton(Icons.flag_outlined, _addLap),
//       ],
//     );
//   }

//   Widget _roundButton(IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//           boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
//         ),
//         child: Icon(icon, color: Colors.black87, size: 24),
//       ),
//     );
//   }
// }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              _buildTimerDisplay(context),
              const Spacer(),
              _buildLapList(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: _buildControls(context),
              ),
              const SizedBox(height: 60),
            ],
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
              width: context.isPhone ? 250 : 330,
              height: context.isPhone ? 250 : 330,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: CircularProgressIndicator(
                value: (controller.milliseconds.value % 60000) / 60000,
                strokeWidth: context.isPhone ? 10 : 15,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4D7CFF)),
              ),
            ),
            Text(
              controller.formatTime(controller.milliseconds.value),
              style: TextStyle(
                fontFamily: 'EN-BOLD',
                fontSize: context.isPhone ? 50 : 60,
                fontWeight: FontWeight.w300,
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
            _roundButton(Icons.refresh, controller.resetStopwatch),
            GestureDetector(
              onTap: controller.startStopwatch,
              child: Icon(
                controller.isRunning.value ? Icons.stop_circle : Icons.play_circle_filled,
                size: context.isPhone ? 70 : 90,
                color: const Color(0xFF4D7CFF),
              ),
            ),
            _roundButton(Icons.flag_outlined, controller.addLap),
          ],
        ));
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }
}
