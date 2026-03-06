import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class TimerDetailScreen extends StatelessWidget {
  final dynamic timerKey;
  final Map data;

  const TimerDetailScreen({super.key, required this.timerKey, required this.data});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find<TimerController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "Timer Detail",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
      ),
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
                  SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(value: progress, strokeWidth: 10, valueColor: AlwaysStoppedAnimation(AppColor().primaryColor), backgroundColor: Colors.grey.shade300)),
                  Text(controller.formatTime(currentSec), style: TextStyle(fontSize: 55, fontFamily: 'EN-REGULAR', color: Theme.of(context).textTheme.bodyLarge!.color)),
                ],
              ),
            ),
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button with X icon
                _actionButton(
                  const Icon(Icons.close, color: Colors.white, size: 30),
                  Colors.grey[800]!,
                  Colors.white,
                  () => Get.back(),
                ),

                // Play/Pause Button with dynamic icons
                _actionButton(
                  Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    color: isRunning ? AppColor().primaryColor : Colors.green,
                    size: 35,
                  ),
                  isRunning ? AppColor().primaryColor.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  isRunning ? AppColor().primaryColor : Colors.green,
                  () => controller.toggleTimer(timerKey),
                ),
              ],
            )
          ],
        );
      }),
    );
  }

  Widget _actionButton(Widget icon, Color bg, Color iconColor, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
        ),
        alignment: Alignment.center,
        child: icon, 
      ),
    );
  }
}
