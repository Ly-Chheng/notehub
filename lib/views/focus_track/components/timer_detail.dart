import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';
import 'package:project_structure/models/focus_track/timer_model.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class TimerDetailScreen extends StatelessWidget {
  final dynamic timerKey;
  final TimerModel data;

  const TimerDetailScreen({super.key, required this.timerKey, required this.data});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find<TimerController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: data.title,
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
      ),
      body: Obx(() {
        int currentSec = controller.runningSeconds[timerKey] ?? data.remainingSeconds;
        bool isRunning = controller.activeTimerKeys.contains(timerKey);

        double progress = data.totalSeconds > 0 ? currentSec / data.totalSeconds : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                      width: context.isPhone ? 280 : 350,
                      height: context.isPhone ? 280 : 350,
                      child: CircularProgressIndicator(
                          value: progress, strokeWidth: context.isPhone ? 10 : 12, valueColor: AlwaysStoppedAnimation(AppColor().primaryColor), backgroundColor: Colors.grey.shade300)),
                  Text(controller.formatTime(currentSec), style: TextStyle(fontSize: context.isPhone ? 45 : 55, fontFamily: 'EN-SEMIBOLD', color: Theme.of(context).textTheme.bodyLarge!.color)),
                ],
              ),
            ),
            SizedBox(height: context.isPhone ? 100 : 150),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  Icon(Icons.close, color: AppColor().white, size: context.isPhone ? 40 : 50),
                  Colors.grey[800]!,
                  AppColor().white,
                  () {
                    controller.activeTimerKeys.remove(timerKey);

                    controller.runningSeconds[timerKey] = 0;

                    data.remainingSeconds = 0;
                    data.completedAt = DateTime.now();
                    data.save();

                    Get.back();
                  },
                ),
                _actionButton(
                  Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    color: isRunning ? AppColor().primaryColor : AppColor().green,
                    size: context.isPhone ? 40 : 50,
                  ),
                  isRunning ? AppColor().primaryColor.withValues(alpha: 0.2) : AppColor().green.withValues(alpha: 0.2),
                  isRunning ? AppColor().primaryColor : AppColor().green,
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
        width: 70,
        height: 70,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}
