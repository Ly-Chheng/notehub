import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/models/focus_track/timer_model.dart';
import 'package:project_structure/views/focus_track/components/create_timer_component.dart';
import 'package:project_structure/views/focus_track/components/timer_detail_screen.dart';
import 'package:project_structure/widgets/custom_header.dart';
import 'package:project_structure/widgets/custome_no_data.dart';

class TimerComponent extends StatelessWidget {
  const TimerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.put(TimerController());

    return SlidableAutoCloseBehavior(
      closeWhenOpened: true,
      child: ValueListenableBuilder(
          valueListenable: controller.timerBox.listenable(),
          builder: (context, Box<TimerModel> box, _) {
            final List<TimerModel> allTimers = box.values.toList();

            if (allTimers.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomNoData(
                    message: "No time",
                    imagePath: "assets/images/no_time.png",
                  ),
                ],
              );
            }

            // FILTERING LOGIC
            final activeTimers = allTimers.where((t) {
              bool isCurrentlyRunning = controller.activeTimerKeys.contains(t.key);
              return t.remainingSeconds > 0 || isCurrentlyRunning;
            }).toList();

            final recentTimers = allTimers.where((t) {
              bool isCurrentlyRunning = controller.activeTimerKeys.contains(t.key);
              return t.remainingSeconds <= 0 && !isCurrentlyRunning;
            }).toList();

            // SORTING
            activeTimers.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
            recentTimers.sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 15),
              children: [
                if (activeTimers.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: customHeader("Running", context),
                  ),
                  ...activeTimers.map((timer) => _buildTimerTile(context, controller, timer)),
                ],
                SizedBox(
                  height: 10,
                ),
                if (recentTimers.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: customHeader("Recents", context),
                  ),
                  ...recentTimers.map((timer) => _buildTimerTile(context, controller, timer)),
                ],
              ],
            );
          }),
    );
  }

  Widget _buildTimerTile(BuildContext context, TimerController controller, TimerModel timer) {
    controller.initTimerState(timer.key, timer.remainingSeconds > 0 ? timer.remainingSeconds : timer.totalSeconds);

    return Obx(() {
      int currentSec = controller.runningSeconds[timer.key] ?? timer.totalSeconds;
      bool isRunning = controller.activeTimerKeys.contains(timer.key);
      bool isFinished = currentSec <= 0 && !isRunning;
      double progress = timer.totalSeconds > 0 ? currentSec / timer.totalSeconds : 0.0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Slidable(
          key: ValueKey(timer.key),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) {
                  controller.activeTimerKeys.remove(timer.key);
                  Get.to(() => CreateTimerScreen(isEditing: true, timerKey: timer.key, existingTimer: timer));
                },
                backgroundColor: AppColor().primaryColor,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (_) => controller.deleteTimer(timer.key),
                backgroundColor: AppColor().red,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => Get.to(() => TimerDetailScreen(timerKey: timer.key, data: timer)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: isFinished ? Colors.black : Theme.of(context).cardColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(timer.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: isFinished ? AppColor().gray : Theme.of(context).colorScheme.onSurface, fontSize: context.isPhone ? 16 : 18, fontFamily: 'EN-REGULAR')),
                        Text(controller.formatTime(currentSec),
                            style: TextStyle(
                              fontSize: context.isPhone ? 28 : 32,
                              color: isFinished ? AppColor().white : Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'EN-SEMIBOLD',
                            )),
                        Text("${controller.formatToHMS(timer.totalSeconds)} total",
                            style:
                                TextStyle(color: isFinished ? AppColor().gray : Theme.of(context).colorScheme.onSurface.withAlpha(150), fontSize: context.isPhone ? 12 : 14, fontFamily: 'EN-REGULAR')),
                      ],
                    ),
                  ),
                  _buildiPhoneCircle(controller, timer, progress, isFinished, isRunning, context),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildiPhoneCircle(TimerController controller, TimerModel timer, double progress, bool isFinished, bool isRunning, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (timer.remainingSeconds <= 0 && !isRunning) {
          timer.remainingSeconds = timer.totalSeconds;
          timer.save();
        }
        controller.toggleTimer(timer.key);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
              width: context.isPhone ? 55 : 65,
              height: context.isPhone ? 55 : 65,
              child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.grey.withAlpha(30),
                  ))),
          SizedBox(
              width: context.isPhone ? 55 : 65,
              height: context.isPhone ? 55 : 65,
              child: CircularProgressIndicator(value: progress, strokeWidth: 4, valueColor: AlwaysStoppedAnimation(isFinished ? Colors.transparent : AppColor().primaryColor))),
          Icon(
            isFinished ? Icons.refresh : (isRunning ? Icons.pause : Icons.play_arrow),
            color: isFinished ? AppColor().white : AppColor().primaryColor,
            size: context.isPhone ? 30 : 35,
          ),
        ],
      ),
    );
  }
}
