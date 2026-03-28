import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/focus_track/components/create_timer_component.dart';
import 'package:project_structure/views/focus_track/components/timer_detail_screen.dart';
import 'package:project_structure/widgets/custom_header.dart';

class TimerComponent extends StatelessWidget {
  const TimerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.put(TimerController());

    return SlidableAutoCloseBehavior(
      closeWhenOpened: true,
      child: ValueListenableBuilder(
          valueListenable: controller.timerBox.listenable(),
          builder: (context, Box box, _) {
            final allKeys = box.keys.where((k) {
              final data = box.get(k);
              if (data is Map) {
                return data['type'] == 'timer';
              }
              return false;
            }).toList();

            if (allKeys.isEmpty) {
              Future.microtask(() => Get.to(() => const CreateTimerScreen()));

              return Center(
                child: Text("No timer"),
              );
            }

            final activeKeys = allKeys.where((k) {
              int rem = box.get(k)['remainingSeconds'] ?? 0;
              bool isCurrentlyRunning = controller.activeTimerKeys.contains(k);

              return rem > 0 || isCurrentlyRunning;
            }).toList();

            final recentKeys = allKeys.where((k) {
              int rem = box.get(k)['remainingSeconds'] ?? 0;
              bool isCurrentlyRunning = controller.activeTimerKeys.contains(k);

              return rem <= 0 && !isCurrentlyRunning;
            }).toList();

            activeKeys.sort((a, b) => (box.get(b)['createdAt'] ?? '').compareTo(box.get(a)['createdAt'] ?? ''));
            recentKeys.sort((a, b) => (box.get(b)['completedAt'] ?? '').compareTo(box.get(a)['completedAt'] ?? ''));

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                if (activeKeys.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: customHeader("Running"),
                  ),
                  ...activeKeys.map((key) => _buildTimerTile(context, controller, key, box.get(key))),
                ],
                if (recentKeys.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: customHeader("Recents"),
                  ),
                  ...recentKeys.map((key) => _buildTimerTile(context, controller, key, box.get(key))),
                ],
              ],
            );
          }),
    );
  }

  Widget _buildTimerTile(BuildContext context, TimerController controller, dynamic key, Map data) {
    controller.initTimerState(key, data['remainingSeconds'] ?? data['totalSeconds']);

    return Obx(() {
      int currentSec = controller.runningSeconds[key] ?? data['totalSeconds'];
      bool isRunning = controller.activeTimerKeys.contains(key);
      bool isFinished = currentSec <= 0;
      double progress = data['totalSeconds'] > 0 ? currentSec / data['totalSeconds'] : 0.0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Slidable(
          key: ValueKey(key),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) {
                  controller.activeTimerKeys.remove(key);
                  Get.to(() => CreateTimerScreen(isEditing: true, timerKey: key, existingTimer: data));
                },
                backgroundColor: AppColor().primaryColor,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (_) => controller.deleteTimer(key),
                backgroundColor: Colors.red,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => Get.to(() => TimerDetailScreen(timerKey: key, data: data)),
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
                        Text(data['title'] ?? "Timer",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: isFinished ? Colors.grey : Theme.of(context).colorScheme.onSurface, fontSize: context.isPhone ? 14 : 16, fontFamily: 'EN-REGULAR')),
                        Text(controller.formatTime(currentSec),
                            style: TextStyle(
                              fontSize: context.isPhone ? 28 : 32,
                              color: isFinished ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'EN-REGULAR',
                            )),
                        Text("${controller.formatToHMS(data['totalSeconds'])} total",
                            style: TextStyle(
                                color: isFinished ? Colors.grey : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: context.isPhone ? 12 : 14, fontFamily: 'EN-REGULAR')),
                      ],
                    ),
                  ),
                  _buildiPhoneCircle(controller, key, progress, isFinished, isRunning, context),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildiPhoneCircle(TimerController controller, dynamic key, double progress, bool isFinished, bool isRunning, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.toggleTimer(key),
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
                    Colors.grey.withValues(alpha: 0.1),
                  ))),
          SizedBox(
              width: context.isPhone ? 55 : 65,
              height: context.isPhone ? 55 : 65,
              child: CircularProgressIndicator(value: progress, strokeWidth: 4, valueColor: AlwaysStoppedAnimation(isFinished ? Colors.transparent : AppColor().primaryColor))),
          Icon(
            isFinished ? Icons.refresh : (isRunning ? Icons.pause : Icons.play_arrow),
            color: isFinished ? Colors.white : AppColor().primaryColor,
            size: context.isPhone ? 30 : 35,
          ),
        ],
      ),
    );
  }
}
