import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/focus_track/stopwatch_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';

class StopwatchScreen extends StatelessWidget {
  StopwatchScreen({super.key});

  final StopwatchController controller = Get.put(StopwatchController());

  @override
  Widget build(BuildContext context) {
    final size = context.isPhone ? 20.0 : 40.0;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: Layout.padding(),
          child: Column(
            children: [
              SizedBox(height: size),
              _buildTimerDisplay(context),
              SizedBox(height: size),
              Expanded(
                child: _buildLapList(context),
              ),
              SizedBox(height: 20),
              _glowCircle(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context) {
    final size = context.isPhone ? 280.0 : 300.0;
    return Obx(() => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
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
                fontSize: context.isPhone ? 40 : 50,
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
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.isPhone ? 12 : 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("lap".tr, style: text16(context)),
                      Text("lap_time".tr, style: text16(context)),
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
                          Text("${lap.lapNumber}", style: text16(context)),
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

  Widget _glowCircle(BuildContext context) {
    return Obx(() {
      bool isRunning = controller.isRunning.value;
      bool isAtZero = controller.milliseconds.value == 0;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _roundButton(Icons.refresh, (isAtZero || isRunning) ? null : controller.resetStopwatch, context),
          GestureDetector(
            onTap: controller.startStopwatch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: AppColor().primaryColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColor().primaryColor.withValues(alpha: 0.5), blurRadius: 20)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  isRunning ? Icons.pause : Icons.play_arrow,
                  size: context.isPhone ? 50 : 60,
                  color: AppColor().white,
                ),
              ),
            ),
          ),
          _roundButton(Icons.flag_outlined, (isAtZero || !isRunning) ? null : controller.addLap, context),
        ],
      );
    });
  }

  Widget _roundButton(IconData icon, VoidCallback? onTap, BuildContext context) {
    bool isDisabled = onTap == null;
    final activeIconColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.isPhone ? 5 : 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: isDisabled ? [] : const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Icon(
          icon,
          color: isDisabled ? AppColor().gray : activeIconColor,
          size: context.isPhone ? 24 : 30,
        ),
      ),
    );
  }
}
