import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/controllers/event_planner/exam_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/views/event_planner/add_event_screen.dart';
import 'package:project_structure/widgets/custom_slidableasction.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
import 'package:project_structure/widgets/multi_style.dart';
import 'event_details_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ExamPlannerController _controller = Get.put(ExamPlannerController());

  late Future<List<EventModel>> _upcomingExamsFuture;
  late Future<List<EventModel>> _completedExamsFuture;

  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshLists();

    // Fire a global timer ticker to ensure the countdown grid cards count down live in the list
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _refreshLists() {
    setState(() {
      _upcomingExamsFuture = _controller.fetchExams(completed: false);
      _completedExamsFuture = _controller.fetchExams(completed: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tickerTimer?.cancel();
    super.dispose();
  }

  Duration _calculateTimeRemaining(EventModel exam) {
    if (exam.isCompleted) return const Duration();
    try {
      DateTime examDateTime;
      String rawTime = exam.time.trim();
      String rawDate = exam.date.trim();
      String combinedString = "$rawDate $rawTime";

      if (rawTime.toUpperCase().contains('AM') || rawTime.toUpperCase().contains('PM')) {
        examDateTime = DateFormat("yyyy-MM-dd h:mm a").parse(combinedString);
      } else {
        List<String> timeParts = rawTime.split(':');
        if (timeParts.length >= 2) {
          String hour = timeParts[0].padLeft(2, '0');
          String minute = timeParts[1].padLeft(2, '0');
          examDateTime = DateTime.parse("$rawDate $hour:$minute:00");
        } else {
          examDateTime = DateTime.parse(rawDate);
        }
      }

      final difference = examDateTime.difference(DateTime.now());
      return difference.isNegative ? const Duration() : difference;
    } catch (_) {
      return const Duration();
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName?.toLowerCase().trim()) {
      case 'school':
      case 'education':
        return Icons.school;
      case 'category':
        return Icons.category;
      case 'assignment':
        return Icons.assignment;
      case 'book':
        return Icons.book;
      default:
        return Icons.school;
    }
  }

  void _showActionBottomSheet(BuildContext context, EventModel exam, bool completed) {
    ConfirmBottomSheet.show(
        context: context,
        title: "event".tr,
        content: SafeArea(
          child: Wrap(
            children: <Widget>[
              if (!completed)
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
                          _refreshLists();
                        },
                      );
                    } else {
                      AppSnackbar.showError(
                        title: "error".tr,
                        message: "cannot_make_completed".tr,
                      );
                    }
                  },
                ),
              if (!completed)
                buildActionItem(
                  context,
                  icon: Icons.edit_outlined,
                  color: AppColor().primaryColor,
                  title: "edit".tr,
                  onTap: () async {
                    Navigator.pop(context);

                    final result = await Get.to(() => AddEventScreen(exam: exam));

                    if (result == true) {
                      _refreshLists();
                    }
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
                        _refreshLists();
                      },
                    );
                  } else {
                    AppSnackbar.showError(
                      title: "error".tr,
                      message: "cannot_delete_exam".tr,
                    );
                  }
                },
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColor().white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColor().primaryColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColor().primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              labelColor: AppColor().white,
              unselectedLabelColor: AppColor().gray,
              labelStyle: text16(context),
              unselectedLabelStyle: text16(context),
              tabs: [
                Tab(text: "upcoming".tr),
                Tab(text: "completed".tr),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExamList(completed: false),
                _buildExamList(completed: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamList({required bool completed}) {
    return FutureBuilder<List<EventModel>>(
      future: completed ? _completedExamsFuture : _upcomingExamsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final exams = snapshot.data ?? [];
        if (exams.isEmpty) {
          return Center(
            child: Text(
              completed ? "No completed exams." : "No upcoming exams scheduled.",
              style: const TextStyle(color: Colors.grey),
            ),
          );
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
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Slidable(
                  key: ValueKey(exam.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.3,
                    children: [
                      if (completed)
                        AppSlidableAction(
                          onPressed: () async {
                            if (exam.id != null) {
                              showConfirmDialog(
                                context: context,
                                title: "delete".tr,
                                subTitle: "delete_confirm".tr,
                                confirmText: "delete".tr,
                                onConfirm: () async {
                                  await _controller.deleteExam(exam.id!);
                                  _refreshLists();
                                },
                              );
                            } else {
                              AppSnackbar.showError(
                                title: "error".tr,
                                message: "cannot_delete_exam".tr,
                              );
                            }
                          },
                          icon: Icons.delete,
                          label: 'delete'.tr,
                          backgroundColor: AppColor().red,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(18),
                            left: Radius.circular(18),
                          ),
                        ),
                    ],
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppDecorations.subtleShadow,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventDetailsScreen(exam: exam)),
                      ).then((_) => _refreshLists()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (completed) ...[
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: baseColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 40,
                                      color: baseColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                if (!completed)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: baseColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        width: 1,
                                        color: baseColor.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Icon(
                                      _getIconData(exam.icon),
                                      size: 30,
                                      color: baseColor,
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
                                              exam.title,
                                              style: fix18(context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!completed)
                                            IconButton(
                                              icon: Icon(
                                                Icons.more_horiz_outlined,
                                                color: AppColor().gray,
                                              ),
                                              onPressed: () => _showActionBottomSheet(context, exam, completed),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        "${exam.date}  •  ${exam.time}",
                                        style: text14(context).copyWith(color: AppColor().gray),
                                      ),
                                      const SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (!completed) ...[
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
                          ],
                        ),
                      ),
                    ),
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
            style: text22(context).copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: text12.copyWith(color: AppColor().gray)),
        ],
      ),
    );
  }
}
