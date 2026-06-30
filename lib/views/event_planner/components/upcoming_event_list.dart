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
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';
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
      _upcomingExamsFuture = _controller.fetchExams(completed: false);
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  Duration _calculateTimeRemaining(EventModel exam) {
    try {
      String combinedString = "${exam.date.trim()} ${exam.time.trim()}";
      DateTime examDateTime = exam.time.toUpperCase().contains('AM') || exam.time.toUpperCase().contains('PM')
          ? DateFormat("yyyy-MM-dd h:mm a").parse(combinedString)
          : DateTime.parse("${exam.date.trim()} ${exam.time.split(':')[0].padLeft(2, '0')}:${exam.time.split(':')[1].padLeft(2, '0')}:00");

      final difference = examDateTime.difference(DateTime.now());
      return difference.isNegative ? const Duration() : difference;
    } catch (_) {
      return const Duration();
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName?.toLowerCase().trim()) {
      case 'school': case 'education': return Icons.school;
      case 'category': return Icons.category;
      case 'assignment': return Icons.assignment;
      case 'book': return Icons.book;
      default: return Icons.school;
    }
  }

  void _showActionBottomSheet(BuildContext context, EventModel exam) {
    ConfirmBottomSheet.show(
      context: context,
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
                if (exam.id != null) {
                  showConfirmDialog(
                    context: context,
                    title: "make_completed".tr,
                    subTitle: "are_you_sure_make_completed".tr,
                    confirmText: "completed".tr,
                    onConfirm: () async {
                      await _controller.updateExamCompletionStatus(exam.id!, true);
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
                final result = await Get.to(() => AddEventScreen(exam: exam));
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
                if (exam.id != null) {
                  showConfirmDialog(
                    context: context,
                    title: "delete".tr,
                    subTitle: "delete_confirm".tr,
                    confirmText: "delete".tr,
                    onConfirm: () async {
                      await _controller.deleteExam(exam.id!);
                      _refreshList();
                    },
                  );
                } else {
                  AppSnackbar.showError(title: "error".tr, message: "cannot_delete_exam".tr);
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

        final exams = snapshot.data ?? [];
        if (exams.isEmpty) {
          return Center(child: Text("No upcoming exams scheduled.", style: const TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final exam = exams[index];
            final Color baseColor = exam.color != null ? Color(exam.color!) : AppColor().primaryColor;

            final duration = _calculateTimeRemaining(exam);
            final days = duration.inDays.toString().padLeft(2, '0');
            final hours = (duration.inHours % 24).toString().padLeft(2, '0');
            final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
            final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppDecorations.subtleShadow,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventDetailsScreen(exam: exam)),
                ).then((_) => _refreshList()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: baseColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(width: 1, color: baseColor.withValues(alpha: 0.4)),
                            ),
                            child: Icon(_getIconData(exam.icon), size: 30, color: baseColor),
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
                                        exam.title,
                                        style: fix18(context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.more_horiz_outlined, color: AppColor().gray),
                                      onPressed: () => _showActionBottomSheet(context, exam),
                                    ),
                                  ],
                                ),
                                Text("${exam.date} | ${exam.time}", style: text14(context).copyWith(color: AppColor().gray)),
                                const SizedBox(height: 10)
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _countdownCard(days, "Days")),
                          const SizedBox(width: 20),
                          Expanded(child: _countdownCard(hours, "Hours")),
                          const SizedBox(width: 20),
                          Expanded(child: _countdownCard(minutes, "Mins")),
                          const SizedBox(width: 20),
                          Expanded(child: _countdownCard(seconds, "Secs")),
                        ],
                      ),
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
          Text(value, style: text22(context).copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: text12.copyWith(color: AppColor().gray)),
        ],
      ),
    );
  }
}