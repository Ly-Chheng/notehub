import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/controllers/event_planner/event_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/views/event_planner/add_event_screen.dart';
import 'package:project_structure/views/event_planner/event_details_screen.dart';
import 'package:project_structure/widgets/custom_menu_item.dart.dart';
import 'package:project_structure/widgets/app_snack_bar.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/confirm_bottomsheet.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';

class UpcomingEventList extends StatefulWidget {
  const UpcomingEventList({super.key});

  @override
  State<UpcomingEventList> createState() => _UpcomingEventListState();
}

class _UpcomingEventListState extends State<UpcomingEventList> {
  final EventPlannerController _controller = Get.find<EventPlannerController>();
  late Future<List<EventModel>> _upcomingExamsFuture;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _refreshList();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _refreshList() {
    setState(() {
      _upcomingExamsFuture = _controller.fetchEvent(completed: false);
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  DateTime? _getEventDateTime(EventModel exam) {
    try {
      String combinedString = "${exam.date.trim()} ${exam.time.trim()}";
      return exam.time.toUpperCase().contains('AM') || exam.time.toUpperCase().contains('PM')
          ? DateFormat("yyyy-MM-dd h:mm a").parse(combinedString)
          : DateTime.parse("${exam.date.trim()} ${exam.time.split(':')[0].padLeft(2, '0')}:${exam.time.split(':')[1].padLeft(2, '0')}:00");
    } catch (_) {
      return null;
    }
  }

  Duration _calculateTimeRemaining(EventModel event) {
    final eventDateTime = _getEventDateTime(event);
    if (eventDateTime == null) return const Duration();
    final difference = eventDateTime.difference(DateTime.now());
    return difference.isNegative ? const Duration() : difference;
  }

  double _calculateProgress(EventModel event) {
    final targetTime = _getEventDateTime(event);
    if (targetTime == null) return 0.0;

    // Use a fallback creation time if your model doesn't store it (e.g., 7 days prior)
    // If your EventModel has a `createdAt` field, replace `subtract` line with: exam.createdAt
    final startTime = targetTime.subtract(const Duration(days: 7));
    final totalDuration = targetTime.difference(startTime).inSeconds;
    final elapsedDuration = DateTime.now().difference(startTime).inSeconds;

    if (totalDuration <= 0) return 1.0;

    double progress = elapsedDuration / totalDuration;
    return progress.clamp(0.0, 1.0);
  }

  String _getImageAsset(String? iconName) {
    final cleanName = iconName?.toLowerCase().trim();
    switch (cleanName) {
      case 'study':
      case 'work':
      case 'todo':
      case 'meeting':
        return 'assets/images/$cleanName.png';
      default:
        return 'assets/images/study.png';
    }
  }

  void _showActionBottomSheet(BuildContext context, EventModel event) {
    ConfirmBottomSheet.show(
      context: context,
      isFloating: true,
      title: "event".tr,
      content: SafeArea(
        child: Wrap(
          children: [
            buildActionItem(
              context,
              icon: Icons.check,
              color: AppColor().primaryColor,
              title: "completed".tr,
              onTap: () {
                Navigator.pop(context);
                if (event.id != null) {
                  showConfirmDialog(
                    context: context,
                    title: "make_completed".tr,
                    subTitle: "are_you_sure_make_completed".tr,
                    confirmText: "completed".tr,
                    onConfirm: () async {
                      await _controller.updateEventCompletionStatus(event.id!, true);
                      _refreshList();
                    },
                  );
                } else {
                  AppSnackbar.showError(title: "error".tr, message: "cannot_make_completed".tr);
                }
              },
            ),
            buildActionItem(
              context,
              icon: Icons.edit_outlined,
              color: AppColor().primaryColor,
              title: "edit".tr,
              onTap: () async {
                Navigator.pop(context);
                final result = await Get.to(() => AddEventScreen(event: event));
                if (result == true) _refreshList();
              },
            ),
            buildActionItem(
              context,
              icon: Icons.delete_outline,
              color: AppColor().red,
              title: "delete".tr,
              onTap: () {
                Navigator.pop(context);
                if (event.id != null) {
                  showConfirmDialog(
                    context: context,
                    title: "delete".tr,
                    subTitle: "delete_confirm".tr,
                    confirmText: "delete".tr,
                    onConfirm: () async {
                      await _controller.deleteEvent(event.id!);
                      _refreshList();
                    },
                  );
                } else {
                  AppSnackbar.showError(title: "error".tr, message: "cannot_delete_event".tr);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventModel>>(
      future: _upcomingExamsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: CustomNoData(
              message: "no_data".tr,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final Color baseColor = event.color != null ? Color(event.color!) : AppColor().primaryColor;

            final duration = _calculateTimeRemaining(event);
            final days = duration.inDays.toString().padLeft(2, '0');
            final hours = (duration.inHours % 24).toString().padLeft(2, '0');
            final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
            final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

            final double progressPercentage = _calculateProgress(event);

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventDetailsScreen(event: event)),
                ).then((_) => _refreshList()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: baseColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(width: 1, color: baseColor.withValues(alpha: 0.4)),
                            ),
                            child: Image.asset(
                              _getImageAsset(event.icon),
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        event.title,
                                        style: fix18(context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.more_horiz_outlined, color: AppColor().gray),
                                      onPressed: () => _showActionBottomSheet(context, event),
                                    ),
                                  ],
                                ),
                                Text("${event.date} | ${event.time}", style: fix16(context).copyWith(color: AppColor().gray)),
                                const SizedBox(height: 10)
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _countdownCard(days, "d".tr)),
                          const SizedBox(width: 20),
                          Expanded(child: _countdownCard(hours, "h".tr)),
                          const SizedBox(width: 20),
                          Expanded(child: _countdownCard(minutes, "m".tr)),
                          const SizedBox(width: 20),
                          Expanded(child: _countdownCard(seconds, "s".tr)),
                        ],
                      ),
                      // Overall Progress Bar Section
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("overall_progress".tr,
                              style: text14(context).copyWith(
                                color: AppColor().gray,
                              )),
                          Text(
                            "${(progressPercentage * 100).toStringAsFixed(0)}%",
                            style: fix16(context).copyWith(color: baseColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressPercentage,
                          minHeight: 10,
                          backgroundColor: baseColor.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(baseColor),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _countdownCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(
            value,
            style: fix18(context).copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: text16(context).copyWith(color: AppColor().gray)),
        ],
      ),
    );
  }
}
