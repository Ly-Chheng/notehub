import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';
import 'package:project_structure/core/services/sound_servies.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/models/focus_track/timer_model.dart';
import 'package:project_structure/views/focus_track/components/create_timer.dart';
import 'package:project_structure/views/focus_track/components/timer_detail.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
import 'package:project_structure/widgets/custom_slidableasction.dart';
import 'package:project_structure/widgets/custome_no_data.dart';

class TimerList extends StatelessWidget {
  const TimerList({super.key});

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
                    message: "no_data".tr,
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
                  _glassHeader("running".tr, AppColor().primaryColor, context),
                  ...activeTimers.map((timer) => _buildTimerTile(context, controller, timer)),
                ],
                SizedBox(
                  height: 10,
                ),
                if (recentTimers.isNotEmpty) ...[
                  _glassHeader("recents".tr, AppColor().green, context),
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
        padding: Layout.padding(),
        child: Slidable(
          key: ValueKey(timer.key),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              AppSlidableAction(
                onPressed: () {
                  controller.activeTimerKeys.remove(timer.key);
                  Get.to(() => CreateTimerScreen(isEditing: true, timerKey: timer.key, existingTimer: timer));
                },
                icon: Icons.edit,
                label: 'edit'.tr,
                iconSize: 20,
                backgroundColor: AppColor().green,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), topLeft: Radius.circular(20)),
              ),
              AppSlidableAction(
                onPressed: () {
                  showConfirmDialog(
                    context: context,
                    title: "delete_timer".tr,
                    subTitle: "delete_timer_confirm".tr,
                    confirmText: "delete".tr,
                    onConfirm: () {
                      controller.deleteTimer(timer.key);
                    },
                  );
                },
                icon: Icons.delete,
                label: 'delete'.tr,
                backgroundColor: AppColor().red,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), topRight: Radius.circular(20)),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => Get.to(() => TimerDetailScreen(timerKey: timer.key, data: timer)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: Layout.cardDecoration(radius: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(timer.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text16(context).copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            )),
                        Text(controller.formatTime(currentSec),
                            style: TextStyle(
                              fontSize: context.isPhone ? 30 : 32,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'EN-BOLD',
                            )),
                        Text("${'total'.tr} ${controller.formatToHMS(timer.totalSeconds)}",
                            style: text10.copyWith(
                              color: isFinished ? AppColor().gray : Theme.of(context).colorScheme.onSurface.withAlpha(150),
                            )),
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
    final size = context.isPhone ? 55.0 : 65.0;
    return GestureDetector(
      onTap: () {
        SoundService.stopSound();
        if (timer.remainingSeconds <= 0 && !isRunning) {
          timer.remainingSeconds = timer.totalSeconds;
          timer.save();
          controller.runningSeconds[timer.key] = timer.totalSeconds;
        }
        controller.toggleTimer(timer.key);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.grey.withAlpha(30),
                  ))),
          SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(value: progress, strokeWidth: 5, valueColor: AlwaysStoppedAnimation(isFinished ? Colors.transparent : AppColor().primaryColor))),
          Icon(
            isFinished ? Icons.refresh : (isRunning ? Icons.pause : Icons.play_arrow),
            color: isFinished ? AppColor().gray : AppColor().primaryColor,
            size: context.isPhone ? 30 : 35,
          ),
        ],
      ),
    );
  }

  Widget _glassHeader(String title, Color color, BuildContext context) {
    return Padding(
      padding: Layout.padding(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: text18(context),
            ),
          ],
        ),
      ),
    );
  }
}
