import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/exam_planner/exam_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/exam_planner/exam_model.dart';
import 'package:project_structure/widgets/card_and_button/custom_button.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'add_topic_screen.dart';
import 'revision_progress_screen.dart';

class RevisionChecklistScreen extends StatefulWidget {
  final Exam exam;

  const RevisionChecklistScreen({super.key, required this.exam});

  @override
  State<RevisionChecklistScreen> createState() => _RevisionChecklistScreenState();
}

class _RevisionChecklistScreenState extends State<RevisionChecklistScreen> {
  final ExamPlannerController _controller = ExamPlannerController();
  int progressPercent = 0;
  late Future<List<RevisionTopic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _topicsFuture = _controller.fetchTopicsForExam(widget.exam.id!);
    });
    _loadProgress();
  }

  void _loadProgress() async {
    final metrics = await _controller.calculateExamProgressMetrics(widget.exam.id!);
    setState(() {
      progressPercent = metrics['percent'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "revision_checklist".tr,
        context: context,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics_outlined, color: AppColor().primaryColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RevisionProgressScreen(exam: widget.exam))),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Progress Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("overall_progress".tr, style: text16(context).copyWith(fontWeight: FontWeight.bold)),
                    Text("$progressPercent%", style: text16(context).copyWith(fontWeight: FontWeight.bold, color: AppColor().primaryColor)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: AppColor().primaryColor,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Topics & Subtopics Checklist
          Expanded(
            child: FutureBuilder<List<RevisionTopic>>(
              future: _topicsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final topics = snapshot.data ?? [];
                if (topics.isEmpty) {
                  return Center(child: Text("no_tracking_modules".tr));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: topics.length,
                  itemBuilder: (context, index) => _buildTopicBlock(topics[index]),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: "add_topic".tr,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTopicScreen(examId: widget.exam.id!),
                ),
              ).then((_) => _refreshData()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicBlock(RevisionTopic topic) {
    return FutureBuilder<List<RevisionSubtopic>>(
      future: _controller.fetchSubtopicsForTopic(topic.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final subtopics = snapshot.data!;
        final completedCount = subtopics.where((s) => s.isCompleted).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppDecorations.subtleShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(topic.name, style: text16(context).copyWith(fontWeight: FontWeight.bold)),
                    Text("$completedCount/${subtopics.length}", style: text16(context).copyWith(fontWeight: FontWeight.bold, color: AppColor().gray)),
                  ],
                ),
                const Divider(height: 20),
                if (subtopics.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("no_checklist_items".tr, style: text14(context).copyWith(color: AppColor().gray)),
                  ),
                ...subtopics.map((subtopic) => CheckboxListTile(
                      title: Text(subtopic.name, style: TextStyle(decoration: subtopic.isCompleted ? TextDecoration.lineThrough : null, color: subtopic.isCompleted ? AppColor().gray : Colors.black)),
                      value: subtopic.isCompleted,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColor().primaryColor,
                      onChanged: (bool? value) async {
                        await _controller.updateSubtopicCompletionStatus(subtopic.id!, value ?? false);
                        _refreshData();
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
