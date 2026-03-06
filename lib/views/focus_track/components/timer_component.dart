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
        final timerKeys = box.keys.where((k) => box.get(k)['type'] == 'timer').toList();

        if (timerKeys.isEmpty) return const Center(child: Text("No Timers"));

        return ListView.builder(
          itemCount: timerKeys.length,
          itemBuilder: (context, index) {
            final key = timerKeys[index];
            final data = box.get(key);

            // Initialization point
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
                        onPressed: (context) {
                          // We pause the timer before editing to avoid sync issues
                          controller.activeTimerKeys.remove(key);

                          Get.to(() => CreateTimerScreen(
                                isEditing: true,
                                timerKey: key,
                                existingTimer: data,
                              ));
                        },
                        backgroundColor: AppColor().primaryColor,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) => controller.deleteTimer(key),
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
                        color: isFinished ? const Color(0xFF1C1C1E) : Theme.of(context).cardColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? "Timer",
                                  style: TextStyle(color: isFinished ? Colors.grey : Colors.black, fontSize: 14, fontFamily: 'EN-REGULAR'),
                                ),
                                Text(controller.formatTime(currentSec), style: TextStyle(fontSize: 32, color: isFinished ? Colors.white : Colors.black, fontFamily: 'EN-REGULAR')),
                                // SHOW DYNAMIC TOTAL TIME
                                Text("${controller.formatToHMS(data['totalSeconds'])} total",
                                    style: TextStyle(color: isFinished ? Colors.grey : Colors.black54, fontSize: 14, fontFamily: 'EN-REGULAR')),
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
          },
        );
      },
    );
  }

  Widget _buildiPhoneCircle(TimerController controller, dynamic key, double progress, bool isFinished, bool isRunning) {
    return GestureDetector(
      onTap: () => controller.toggleTimer(key),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(width: 60, height: 60, child: CircularProgressIndicator(value: 1.0, strokeWidth: 4, valueColor: AlwaysStoppedAnimation(Colors.grey.shade200))),
          SizedBox(
              width: 60, height: 60, child: CircularProgressIndicator(value: progress, strokeWidth: 4, valueColor: AlwaysStoppedAnimation(isFinished ? Colors.transparent : AppColor().primaryColor))),
          Icon(
            isFinished ? Icons.refresh : (isRunning ? Icons.pause : Icons.play_arrow),
            color: isFinished ? Colors.white : AppColor().primaryColor,
            size: 30,
          ),
        ],
      ),
    );
  }
}
