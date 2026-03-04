// // This component is responsible for displaying active timers from Hive and updating them in real-time.
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class TimerComponent extends StatefulWidget {
//   const TimerComponent({super.key});

//   @override
//   State<TimerComponent> createState() => _TimerComponentState();
// }

// class _TimerComponentState extends State<TimerComponent> {
//   final Box noteBox = Hive.box('student_notes');
//   Timer? _globalTimer;

//   // We track remaining seconds locally to avoid excessive Hive writes
//   Map<int, int> _runningSeconds = {};

//   @override
//   void initState() {
//     super.initState();
//     // Start a master timer that updates the UI every second
//     _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _runningSeconds.forEach((key, value) {
//           if (value > 0) _runningSeconds[key] = value - 1;
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _globalTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: noteBox.listenable(),
//       builder: (context, Box box, _) {
//         // FILTER: Only show items where type is 'timer'
//         final timerKeys = box.keys.where((k) => box.get(k)['type'] == 'timer').toList();

//         if (timerKeys.isEmpty) return const Center(child: Text("No timers found."));

//         return ListView.builder(
//           itemCount: timerKeys.length,
//           itemBuilder: (context, index) {
//             final key = timerKeys[index];
//             final data = box.get(key);

//             // Initialize local seconds if not already present
//             if (!_runningSeconds.containsKey(key)) {
//               _runningSeconds[key] = data['remainingSeconds'];
//             }

//             int currentSec = _runningSeconds[key]!;
//             double progress = currentSec / data['totalSeconds'];

//             return Container(
//               margin: const EdgeInsets.all(10),
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Color(data['bgColorValue']),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(data['title'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//                         Text(_formatTime(currentSec), style: const TextStyle(color: Colors.white, fontSize: 32)),
//                       ],
//                     ),
//                   ),
//                   _buildProgressCircle(progress, currentSec == 0),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   String _formatTime(int seconds) {
//     int h = seconds ~/ 3600;
//     int m = (seconds % 3600) ~/ 60;
//     int s = seconds % 60;
//     return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
//   }

//   Widget _buildProgressCircle(double progress, bool isFinished) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         CircularProgressIndicator(
//           value: progress,
//           strokeWidth: 6,
//           backgroundColor: Colors.white24,
//           valueColor: AlwaysStoppedAnimation<Color>(isFinished ? Colors.red : Colors.white),
//         ),
//         Icon(isFinished ? Icons.notifications_active : Icons.timer, color: Colors.white),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/focus_track/components/create_timer_component.dart';
import 'package:project_structure/views/focus_track/components/timer_detail_screen.dart';

class TimerComponent extends StatefulWidget {
  const TimerComponent({super.key});

  @override
  State<TimerComponent> createState() => _TimerComponentState();
}

class _TimerComponentState extends State<TimerComponent> {
  // final Box noteBox = Hive.box('student_notes');
  final Box timerBox = Hive.box('timer_box');
  Timer? _globalTimer;

  // Local state to manage ticking without constant database writes
  final Map<int, int> _runningSeconds = {};
  final Set<int> _activeTimerKeys = {};

  @override
  void initState() {
    super.initState();
    // iPhone logic: A single master timer for all active countdowns
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        for (var key in _activeTimerKeys.toList()) {
          if (_runningSeconds.containsKey(key) && _runningSeconds[key]! > 0) {
            _runningSeconds[key] = _runningSeconds[key]! - 1;
          } else {
            // Timer Finished: Transition to the "Red" state
            _activeTimerKeys.remove(key);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    super.dispose();
  }

  void _handleToggle(int key, int currentSec) {
    setState(() {
      if (currentSec <= 0) {
        // iPhone "Reset" logic: if finished, clicking the icon restarts the timer
        final data = timerBox.get(key);
        _runningSeconds[key] = data['totalSeconds'];
      } else {
        if (_activeTimerKeys.contains(key)) {
          _activeTimerKeys.remove(key);
        } else {
          _activeTimerKeys.add(key);
        }
      }
    });
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: timerBox.listenable(),
      builder: (context, Box box, _) {
        final timerKeys = box.keys.where((k) => box.get(k)['type'] == 'timer').toList();

        if (timerKeys.isEmpty) {
          return const Center(child: Text("No Timers", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          itemCount: timerKeys.length,
          itemBuilder: (context, index) {
            final key = timerKeys[index];
            final data = box.get(key);

            // Sync Hive data with local running state
            if (!_runningSeconds.containsKey(key)) {
              _runningSeconds[key] = data['remainingSeconds'] ?? data['totalSeconds'];
            }

            int currentSec = _runningSeconds[key]!;
            bool isFinished = currentSec <= 0;
            bool isRunning = _activeTimerKeys.contains(key);
            double progress = data['totalSeconds'] > 0 ? currentSec / data['totalSeconds'] : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Slidable(
                key: ValueKey(key),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        _activeTimerKeys.remove(key);
                        Get.to(() => CreateTimerScreen(isEditing: true, timerKey: key, existingTimer: data));
                      },
                      backgroundColor: Colors.blue,
                      icon: Icons.edit,
                      label: 'Edit',
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        _activeTimerKeys.remove(key);
                        _runningSeconds.remove(key);
                        box.delete(key);
                      },
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      label: 'Delete',
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Detail Screen
                    Get.to(() => TimerDetailScreen(
                          timerKey: key,
                          data: data,
                          // Pass the current local running state
                          initialSeconds: _runningSeconds[key]!,
                          isRunning: isRunning,
                        ));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      // iPhone Style: Turns black/grey when finished
                      color: isFinished ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'] ?? "Timer",
                                style: TextStyle(color: isFinished ? Colors.grey : Colors.black, fontFamily: 'EN-REGULAR', fontSize: 16),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _formatTime(currentSec),
                                style: TextStyle(
                                  color: isFinished ? Colors.orange : Colors.black,
                                  fontSize: 30,
                                  fontFamily: 'EN-REGULAR',
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildiPhoneCircle(key, progress, isFinished, isRunning, currentSec),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildiPhoneCircle(int key, double progress, bool isFinished, bool isRunning, int currentSec) {
    return GestureDetector(
      onTap: () => _handleToggle(key, currentSec),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ring
          SizedBox(
            width: 65,
            height: 65,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black.withOpacity(0.1)),
            ),
          ),
          // Active Progress Ring
          SizedBox(
            width: 65,
            height: 65,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFinished ? Colors.transparent : AppColor().primaryColor,
              ),
            ),
          ),
          // Play/Pause/Reset Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFinished ? Colors.orange.withOpacity(0.2) : Colors.black.withOpacity(0.15),
            ),
            child: Icon(
              isFinished ? Icons.refresh : (isRunning ? Icons.pause : Icons.play_arrow),
              color: isFinished ? Colors.orange : Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
