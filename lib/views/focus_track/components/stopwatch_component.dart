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
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4D7CFF)),
              ),
            ),
            Text(
              controller.formatTime(controller.milliseconds.value),
              style: TextStyle(
                fontFamily: 'EN-REGULAR',
                fontSize: context.isPhone ? 55 : 60,
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
