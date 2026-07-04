import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/controllers/event_planner/event_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/models/event_planner/revision_topic_model.dart';
import 'package:project_structure/views/event_planner/components/add_topic.dart';
import 'package:project_structure/widgets/app_slidable_asction.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_button.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final EventPlannerController _controller = EventPlannerController();
  Duration _timeRemaining = const Duration();
  Timer? _timer;
  bool _hasError = false;
  late Future<List<RevisionTopic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
    if (!widget.event.isCompleted) {
      _calculateTimeRemaining();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _calculateTimeRemaining());
    }
  }

  void _refreshData() {
    setState(() {
      _topicsFuture = _controller.fetchTopicsForEvent(widget.event.id!); // Fetching topics
      if (!widget.event.isCompleted) {
        _calculateTimeRemaining();
      }
    });
  }

  void _calculateTimeRemaining() {
    if (!mounted) return;

    try {
      DateTime eventDateTime;
      String rawTime = widget.event.time.trim();
      String rawDate = widget.event.date.trim();

      String combinedString = "$rawDate $rawTime";

      if (rawTime.toUpperCase().contains('AM') || rawTime.toUpperCase().contains('PM')) {
        eventDateTime = DateFormat("yyyy-MM-dd h:mm a").parse(combinedString);
      } else {
        List<String> timeParts = rawTime.split(':');
        if (timeParts.length >= 2) {
          String hour = timeParts[0].padLeft(2, '0');
          String minute = timeParts[1].padLeft(2, '0');
          eventDateTime = DateTime.parse("$rawDate $hour:$minute:00");
        } else {
          eventDateTime = DateTime.parse(rawDate);
        }
      }

      final now = DateTime.now();
      setState(() {
        _timeRemaining = eventDateTime.difference(now);
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _timeRemaining = const Duration();
        _hasError = true;
      });
    }
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "event_details".tr,
        context: context,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeaderIcon(),
              const SizedBox(height: 12),
              Text(widget.event.title, style: fix18(context), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              if (widget.event.isCompleted) _buildCompletedBadge(),
              const SizedBox(height: 12),
              _buildCountdownSection(),
              const SizedBox(height: 20),
              _buildInfoSection(),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: Layout.cardDecoration(radius: 20.0),
                child: SlidableAutoCloseBehavior(
                  child: FutureBuilder<List<RevisionTopic>>(
                    future: _topicsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Error loading topics: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                        );
                      }

                      final topics = snapshot.data ?? [];
                      final int totalTopics = topics.length;
                      final int completedTopics = topics.where((t) => t.isCompleted).length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "revision_check_list".tr,
                                style: text16(context).copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (totalTopics > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColor().primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$completedTopics / $totalTopics",
                                    style: fix16(context).copyWith(
                                      color: AppColor().primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (topics.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(
                                child: Text("no_tracking_modules".tr, style: text14(context).copyWith(color: Colors.grey)),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: topics.length,
                              itemBuilder: (context, index) {
                                final topic = topics[index];
                                final bool isTopicCompleted = topic.isCompleted;

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 3.0),
                                  child: ClipRRect(
                                    child: Slidable(
                                      key: Key('topic_${topic.id}'),
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        extentRatio: 0.35,
                                        children: [
                                          AppSlidableAction(
                                            onPressed: () {
                                              addTopic(
                                                context,
                                                widget.event.id!,
                                                () => _refreshData(),
                                                topicToEdit: topic,
                                              );
                                            },
                                            icon: Icons.edit,
                                            iconColor: AppColor().primaryColor,
                                            backgroundColor: Colors.transparent,
                                          ),
                                          AppSlidableAction(
                                            onPressed: () async {
                                              await _controller.deleteTopic(topic.id!);
                                              _refreshData();
                                            },
                                            icon: Icons.delete,
                                            iconColor: AppColor().red,
                                            backgroundColor: Colors.transparent,
                                          ),
                                        ],
                                      ),
                                      child: CheckboxListTile(
                                        controlAffinity: ListTileControlAffinity.leading,
                                        activeColor: AppColor().primaryColor,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                        title: Text(
                                          topic.name,
                                          style: fix16(context).copyWith(
                                            fontWeight: FontWeight.normal,
                                            decoration: isTopicCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                            color: isTopicCompleted ? AppColor().gray : null,
                                          ),
                                        ),
                                        secondary: topic.priority.isNotEmpty
                                            ? Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColor().primaryColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              )
                                            : null,
                                        value: isTopicCompleted,
                                        onChanged: (bool? newValue) async {
                                          if (newValue != null) {
                                            await _controller.updateTopicCompletionStatus(topic.id!, newValue);
                                            _refreshData();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          CustomButton(
                            text: "add_topic".tr,
                            onPressed: () => addTopic(
                              context,
                              widget.event.id!,
                              () => _refreshData(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // UI Component Sub-Widgets
  Widget _buildHeaderIcon() {
    final themeColor = widget.event.isCompleted ? AppColor().green : AppColor().primaryColor;
    return Container(
      decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.1), shape: BoxShape.circle),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.1), shape: BoxShape.circle),
          padding: const EdgeInsets.all(19),
          child: Image.asset(
            _getImageAsset(widget.event.icon),
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
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
    );
  }

  Widget _buildCountdownSection() {
    if (_hasError) {
      return const Text("Invalid countdown formatting structure.", style: TextStyle(color: Colors.red));
    }

    final positiveDuration = (widget.event.isCompleted || _timeRemaining.isNegative) ? const Duration() : _timeRemaining;
    final days = positiveDuration.inDays.toString().padLeft(2, '0');
    final hours = (positiveDuration.inHours % 24).toString().padLeft(2, '0');
    final minutes = (positiveDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (positiveDuration.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: Layout.cardDecoration(radius: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _countdownItem(days, "d".tr),
          _countdownItem(hours, "h".tr),
          _countdownItem(minutes, "m".tr),
          _countdownItem(seconds, "s".tr),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    // _infoRow("reminder".tr, widget.event.reminderTime.isEmpty ? "none".tr : widget.event.reminderTime, Icons.notifications_none_outlined),
    final convertedReminder = _controller.reminderConvertFromDateTime(
      eventDateStr: widget.event.date,
      reminderDateStr: widget.event.reminderDate,
      fallbackReminderTime: widget.event.reminderTime,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: Layout.cardDecoration(radius: 20.0),
      child: Column(
        children: [
          _infoRow("date".tr, widget.event.date, Icons.calendar_today_outlined),
          _divider(),
          _infoRow("timer".tr, widget.event.time, Icons.access_time_outlined),
          _divider(),
          _infoRow("reminder".tr, convertedReminder, Icons.notifications_none_outlined),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notes_rounded, size: 22, color: AppColor().gray.withValues(alpha: 0.7)),
                    const SizedBox(width: 14),
                    Text("short_description".tr, style: text16(context).copyWith(color: AppColor().gray)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.event.location.isEmpty ? "No description available." : widget.event.location,
                  style: fix16(context).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countdownItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: fix18(context).copyWith(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: text16(context).copyWith(color: AppColor().gray)),
      ],
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
            child: Text(
              val,
              style: fix16(context).copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15));
  }
}
