import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel exam;

  const EventDetailsScreen({super.key, required this.exam});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Duration _timeRemaining = const Duration();
  Timer? _timer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (!widget.exam.isCompleted) {
      _calculateTimeRemaining();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _calculateTimeRemaining());
    }
  }

  void _calculateTimeRemaining() {
    // FIX: Guard clause to stop execution if the widget was unmounted mid-timer execution loop
    if (!mounted) return;

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
    final positiveDuration = (widget.exam.isCompleted || _timeRemaining.isNegative) ? const Duration() : _timeRemaining;

    final days = positiveDuration.inDays.toString().padLeft(2, '0');
    final hours = (positiveDuration.inHours % 24).toString().padLeft(2, '0');
    final minutes = (positiveDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (positiveDuration.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "event_details".tr,
        context: context,
      ),
      body: SingleChildScrollView(
        // Added scroll safety for smaller devices
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
            Text(widget.exam.title, style: text22(context), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            if (widget.exam.isCompleted) ...[
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
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            _hasError
                ? const Text("Invalid countdown formatting structure.", style: TextStyle(color: Colors.red))
                : Row(
                    children: [
                      Expanded(child: _countdownCard(days, "Days")),
                      const SizedBox(width: 8),
                      Expanded(child: _countdownCard(hours, "Hours")),
                      const SizedBox(width: 8),
                      Expanded(child: _countdownCard(minutes, "Mins")),
                      const SizedBox(width: 8),
                      Expanded(child: _countdownCard(seconds, "Secs")),
                    ],
                  ),
            const SizedBox(height: 30),
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
                    widget.exam.location.isEmpty ? "n_a".tr : widget.exam.location,
                    Icons.location_on_outlined,
                  ),
                  _divider(),
                  _infoRow(
                    "reminder".tr,
                    widget.exam.reminderTime.isEmpty ? "none".tr : widget.exam.reminderTime,
                    Icons.notifications_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countdownCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: widget.exam.isCompleted ? Colors.grey.withValues(alpha: 0.08) : AppColor().primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.exam.isCompleted ? Colors.grey : AppColor().primaryColor,
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

  Widget _infoRow(String label, String val, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColor().gray),
              const SizedBox(width: 14),
              Text(label, style: text16(context).copyWith(color: AppColor().gray)),
            ],
          ),
          Flexible(
            // Prevents long location/info text from causing layout overflows
            child: Text(
              val,
              style: text16(context).copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }
}
