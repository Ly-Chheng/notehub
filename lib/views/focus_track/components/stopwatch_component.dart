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
                const SizedBox(height: 30),
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
              width: context.isPhone ? 250 : 330,
              height: context.isPhone ? 250 : 330,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: CircularProgressIndicator(
                value: (controller.milliseconds.value % 60000) / 60000,
                strokeWidth: context.isPhone ? 10 : 12,
                backgroundColor: Colors.grey.withOpacity(0.1),
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
              Container(
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Lap", style: TextStyle(fontFamily: 'EN-REGULAR', fontSize: 16)),
                      Text("Lap Time", style: TextStyle(fontFamily: 'EN-REGULAR', fontSize: 16)),
                    ],
                  ),
                ),
              ),
              // const Divider(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.laps.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Lap ${controller.laps.length - index}", style: TextStyle(fontSize: context.isPhone ? 12 : 14, fontFamily: 'EN-REGULAR')),
                          Text(controller.laps[index], style: TextStyle(fontSize: context.isPhone ? 12 : 14, fontFamily: 'EN-REGULAR')),
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
    return Obx(() {
      bool isRunning = controller.isRunning.value;
      bool isAtZero = controller.milliseconds.value == 0;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. REFRESH: Gray/Disabled if at 00:00:00 OR if currently Running
          _roundButton(Icons.refresh, (isAtZero || isRunning) ? null : controller.resetStopwatch, context),

          GestureDetector(
            onTap: controller.startStopwatch,
            child: Icon(
              isRunning ? Icons.stop_circle : Icons.play_circle_filled,
              size: context.isPhone ? 55 : 90,
              color: const Color(0xFF4D7CFF),
            ),
          ),

          // 2. FLAG: Gray/Disabled if at 00:00:00 OR if NOT Running
          _roundButton(Icons.flag_outlined, (isAtZero || !isRunning) ? null : controller.addLap, context),
        ],
      );
    });
  }

  Widget _roundButton(IconData icon, VoidCallback? onTap, BuildContext context) {
    bool isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: isDisabled ? [] : const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Icon(icon,
            // If disabled, color is gray; otherwise black87
            color: isDisabled ? Colors.grey : Colors.black87,
            size: 20),
      ),
    );
  }
}
