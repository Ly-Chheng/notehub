import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/focus_track/components/create_timer_component.dart';
import 'package:project_structure/views/focus_track/components/timer_detail_screen.dart';

class TimerComponent extends StatelessWidget {
  const TimerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.put(TimerController());

    return ValueListenableBuilder(
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
            // Use microtask to wait until the current frame is done building
            Future.microtask(() => Get.to(() => const CreateTimerScreen()));

            return const Center(child: Text("No Timers"));
          }

          // A timer is "Running" if Hive says it has time OR if the Controller has it active.
          final activeKeys = allKeys.where((k) {
            int rem = box.get(k)['remainingSeconds'] ?? 0;
            bool isCurrentlyRunning = controller.activeTimerKeys.contains(k);

            // If it's running in memory, it MUST jump to the "Running" section
            return rem > 0 || isCurrentlyRunning;
          }).toList();

          // A timer is "Recent" ONLY if it is at 0 AND it is not active in the controller.
          final recentKeys = allKeys.where((k) {
            int rem = box.get(k)['remainingSeconds'] ?? 0;
            bool isCurrentlyRunning = controller.activeTimerKeys.contains(k);

            return rem <= 0 && !isCurrentlyRunning;
          }).toList();

          // 2. SORTING (Keep your existing sorting logic)
          activeKeys.sort((a, b) => (box.get(b)['createdAt'] ?? '').compareTo(box.get(a)['createdAt'] ?? ''));
          recentKeys.sort((a, b) => (box.get(b)['completedAt'] ?? '').compareTo(box.get(a)['completedAt'] ?? ''));

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              if (activeKeys.isNotEmpty) ...[
                const _CategoryHeader(title: "Running"),
                ...activeKeys.map((key) => _buildTimerTile(context, controller, key, box.get(key))),
              ],
              if (recentKeys.isNotEmpty) ...[
                const _CategoryHeader(title: "Recents"),
                ...recentKeys.map((key) => _buildTimerTile(context, controller, key, box.get(key))),
              ],
            ],
          );
        });
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
              padding: const EdgeInsets.all(15),
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
                            style: TextStyle(
                                // color: isFinished ? Colors.grey : Colors.black,
                                fontSize: 14,
                                fontFamily: 'EN-REGULAR')),
                        Text(controller.formatTime(currentSec),
                            style: TextStyle(
                              fontSize: 32,
                              //color: isFinished ? Colors.white : Colors.black,
                              fontFamily: 'EN-REGULAR',
                            )),
                        Text("${controller.formatToHMS(data['totalSeconds'])} total",
                            style: TextStyle(
                                // color: isFinished ? Colors.grey : Colors.black54,
                                fontSize: 12,
                                fontFamily: 'EN-REGULAR')),
                      ],
                    ),
                  ),
                  _buildiPhoneCircle(controller, key, progress, isFinished, isRunning),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildiPhoneCircle(TimerController controller, dynamic key, double progress, bool isFinished, bool isRunning) {
    return GestureDetector(
      onTap: () => controller.toggleTimer(key),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.grey.withOpacity(0.1),
                  ))),
          SizedBox(
              width: 60, height: 60, child: CircularProgressIndicator(value: progress, strokeWidth: 4, valueColor: AlwaysStoppedAnimation(isFinished ? Colors.transparent : AppColor().primaryColor))),
          Icon(isFinished ? Icons.refresh : (isRunning ? Icons.pause : Icons.play_arrow), color: isFinished ? Colors.white : AppColor().primaryColor, size: 30),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  const _CategoryHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 20, bottom: 5),
      child: Text(title,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'EN-BOLD',
          )),
    );
  }
}
