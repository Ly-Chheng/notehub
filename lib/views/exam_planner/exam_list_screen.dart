import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/exam_planner/exam_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/exam_planner/exam_model.dart';
import 'package:project_structure/views/exam_planner/add_exam_screen.dart';
import 'package:project_structure/widgets/card_and_button/custom_button.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'exam_details_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({Key? key}) : super(key: key);

  @override
  _ExamListScreenState createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ExamPlannerController _controller = ExamPlannerController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "exams".tr,
        context: context,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
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
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade700,
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
                _buildExamList(false), // Upcoming
                _buildExamList(true), // Completed
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: CustomButton(
          text: "add_exam".tr,
          onPressed: () async {
            final result = await Get.to(() => const AddExamScreen());
            if (result == true) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildExamList(bool completed) {
    return FutureBuilder<List<Exam>>(
      future: _controller.fetchExams(completed: completed),
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
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppDecorations.subtleShadow,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExamDetailsScreen(exam: exam)),
                ).then((_) => setState(() {})),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              exam.title,
                              style: fix18(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${exam.date}  •  ${exam.time}",
                              style: text14(context).copyWith(color: AppColor().gray),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${exam.daysLeft}",
                            style: text22(context).copyWith(
                              color: AppColor().primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Days Left".tr,
                            style: text14(context).copyWith(color: AppColor().gray),
                          ),
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
}
