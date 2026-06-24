import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/exam_planner/exam_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/exam_planner/exam_model.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class RevisionProgressScreen extends StatelessWidget {
  final Exam exam;
  final ExamPlannerController _controller = ExamPlannerController();

  RevisionProgressScreen({super.key, required this.exam});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "revision_progress".tr,
        context: context,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _controller.calculateExamProgressMetrics(exam.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final metrics = snapshot.data ?? {'total': 0, 'completed': 0, 'pending': 0, 'percent': 0};

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular Progress Chart Arc
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: CircularProgressIndicator(
                            value: (metrics['percent'] ?? 0) / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            color: AppColor().primaryColor,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${metrics['percent']}%",
                              style: fix18(context).copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "completed".tr,
                              style: text12.copyWith(color: AppColor().gray),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Analytical Layout Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _metricStat("total_topics".tr, metrics['total'] ?? 0, context),
                      _metricStat("completed".tr, metrics['completed'] ?? 0, context),
                      _metricStat("pending".tr, metrics['pending'] ?? 0, context),
                    ],
                  ),
                  const SizedBox(height: 40),

                  Text(
                    "keep_going".tr,
                    style: text16(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _metricStat(String label, int val, BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          "$val",
          style: text22(context).copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
