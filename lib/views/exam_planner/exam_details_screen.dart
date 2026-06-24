import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/exam_planner/exam_model.dart';
import 'package:project_structure/widgets/card_and_button/custom_button.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'revision_checklist_screen.dart';

class ExamDetailsScreen extends StatefulWidget {
  final Exam exam;

  const ExamDetailsScreen({super.key, required this.exam});

  @override
  State<ExamDetailsScreen> createState() => _ExamDetailsScreenState();
}

class _ExamDetailsScreenState extends State<ExamDetailsScreen> {
  Duration _timeRemaining = const Duration();
  Timer? _timer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // _calculateTimeRemaining();
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _calculateTimeRemaining());
    // Only fire live countdown processing if the exam isn't completed already
    if (!widget.exam.isCompleted) {
      _calculateTimeRemaining();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _calculateTimeRemaining());
    }
  }

  void _calculateTimeRemaining() {
    try {
      DateTime examDateTime;
      String rawTime = widget.exam.time.trim();
      String rawDate = widget.exam.date.trim();

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

      final now = DateTime.now();
      setState(() {
        _timeRemaining = examDateTime.difference(now);
        _hasError = false;
      });
    } catch (e) {
      // Graceful fallback to avoid app crashing if bad data string is found in DB
      setState(() {
        _timeRemaining = const Duration();
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // // Clamp to 0 if the exam date has already passed
    // final positiveDuration = _timeRemaining.isNegative ? const Duration() : _timeRemaining;

    // final days = positiveDuration.inDays.toString().padLeft(2, '0');
    // final hours = (positiveDuration.inHours % 24).toString().padLeft(2, '0');
    // final minutes = (positiveDuration.inMinutes % 60).toString().padLeft(2, '0');
    // final seconds = (positiveDuration.inSeconds % 60).toString().padLeft(2, '0');
    // Clamp to 0 if the exam date has passed or if the exam is already marked completed
    final positiveDuration = (widget.exam.isCompleted || _timeRemaining.isNegative) ? const Duration() : _timeRemaining;

    final days = positiveDuration.inDays.toString().padLeft(2, '0');
    final hours = (positiveDuration.inHours % 24).toString().padLeft(2, '0');
    final minutes = (positiveDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (positiveDuration.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "exam_details".tr,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Container(
            //   decoration: BoxDecoration(
            //     color: AppColor().primaryColor.withValues(alpha: 0.1),
            //     shape: BoxShape.circle,
            //   ),
            //   padding: const EdgeInsets.all(25),
            //   child: Icon(
            //     Icons.school,
            //     color: AppColor().primaryColor,
            //     size: 70,
            //   ),
            // ),
            // const SizedBox(height: 12),
            // Text(widget.exam.title, style: text22(context)),
            // const SizedBox(height: 24),

            // Dynamic Status Icon Header Block
            Container(
              decoration: BoxDecoration(
                color: widget.exam.isCompleted ? AppColor().green.withValues(alpha: 0.1) : AppColor().primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(25),
              child: Icon(
                widget.exam.isCompleted ? Icons.check_circle_outline : Icons.school,
                color: widget.exam.isCompleted ? AppColor().green : AppColor().primaryColor,
                size: 70,
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.exam.title, style: text22(context)),
            const SizedBox(height: 6),

            // Completed Badge chip indicator
            if (widget.exam.isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor().green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "completed".tr,
                  style: text14(context).copyWith(color: AppColor().green, fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 24),
            _hasError
                ? const Text("Invalid countdown formatting structure.", style: TextStyle(color: Colors.red))
                : Row(
                    children: [
                      Expanded(
                        child: _countdownCard(days, "Days"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _countdownCard(hours, "Hours"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _countdownCard(minutes, "Mins"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _countdownCard(seconds, "Secs"),
                      ),
                    ],
                  ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow(
                    "date".tr,
                    widget.exam.date,
                    Icons.calendar_today_outlined,
                  ),
                  _divider(),
                  _infoRow(
                    "time".tr,
                    widget.exam.time,
                    Icons.access_time_outlined,
                  ),
                  _divider(),
                  _infoRow(
                    "location".tr,
                    widget.exam.location,
                    Icons.location_on_outlined,
                  ),
                  _divider(),
                  _infoRow(
                    "reminder".tr,
                    widget.exam.reminderTime,
                    Icons.notifications_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: CustomButton(
          text: "view_revision_checklist".tr,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RevisionChecklistScreen(exam: widget.exam))),
        ),
      ),
    );
  }

  Widget _countdownCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppColor().primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor().primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String val,
    IconData icon,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: AppColor().gray,
                  ),
                  const SizedBox(width: 14),
                  Text(label, style: text16(context).copyWith(color: AppColor().gray)),
                ],
              ),
              Text(val, style: text16(context).copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }
}
