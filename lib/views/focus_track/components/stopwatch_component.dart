import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/focus_track/stopwatch_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              children: [
                SizedBox(
                  height: context.isPhone ? 30 : 40,
                ),
                _buildTimerDisplay(context),
                SizedBox(
                  height: context.isPhone ? 30 : 40,
                ),
                _buildLapList(context),
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
                backgroundColor: const Color(0x1A9E9E9E),
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor().primaryColor),
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

  Widget _buildLapList(BuildContext context) {
    return SizedBox(
      height: context.isPhone ? 150 : 220,
      child: Obx(() => Column(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: EdgeInsets.all(context.isPhone ? 8 : 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Lap", style: text16(context)),
                      Text("Lap Time", style: text16(context)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.laps.length,
                  itemBuilder: (context, index) {
                    final lap = controller.laps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Lap ${lap.lapNumber}", style: text16(context)),
                          Text(lap.formattedTime, style: text16(context)),
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
          _roundButton(Icons.refresh, (isAtZero || isRunning) ? null : controller.resetStopwatch, context),
          GestureDetector(
            onTap: controller.startStopwatch,
            child: Icon(
              isRunning ? Icons.stop_circle : Icons.play_circle_filled,
              size: context.isPhone ? 60 : 90,
              color: AppColor().primaryColor,
            ),
          ),
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
        padding: EdgeInsets.all(context.isPhone ? 8 : 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: isDisabled ? [] : const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Icon(
          icon,
          color: isDisabled ? AppColor().gray : Colors.black87,
          size: context.isPhone ? 24 : 30,
        ),
      ),
    );
  }
}
