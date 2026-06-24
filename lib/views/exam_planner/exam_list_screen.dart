// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/controllers/exam_planner/exam_controller.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/core/utils/app_fonts.dart';
// import 'package:project_structure/models/exam_planner/exam_model.dart';
// import 'package:project_structure/views/exam_planner/add_exam_screen.dart';
// import 'package:project_structure/widgets/card_and_button/custom_button.dart';
// import 'package:project_structure/widgets/custom_slidableasction.dart';
// import 'package:project_structure/widgets/custom_snack_bar.dart';
// import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
// import 'exam_details_screen.dart';

// class ExamListScreen extends StatefulWidget {
//   const ExamListScreen({super.key});

//   @override
//   State<ExamListScreen> createState() => _ExamListScreenState();
// }

// class _ExamListScreenState extends State<ExamListScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final ExamPlannerController _controller = ExamPlannerController();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       // appBar: customAppBar(
//       //   title: "exams".tr,
//       //   context: context,
//       // ),
//       body: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: Colors.grey.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: TabBar(
//               controller: _tabController,
//               dividerColor: Colors.transparent,
//               indicatorSize: TabBarIndicatorSize.tab,
//               indicator: BoxDecoration(
//                 color: AppColor().primaryColor,
//                 borderRadius: BorderRadius.circular(25),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColor().primaryColor.withValues(alpha: 0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               labelColor: AppColor().white,
//               unselectedLabelColor: AppColor().gray,
//               labelStyle: text16(context),
//               unselectedLabelStyle: text16(context),
//               tabs: [
//                 Tab(text: "upcoming".tr),
//                 Tab(text: "completed".tr),
//               ],
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildExamList(false), // Upcoming
//                 _buildExamList(true), // Completed
//               ],
//             ),
//           ),
//         ],
//       ),
//       // bottomNavigationBar: Padding(
//       //   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//       //   child: CustomButton(
//       //     text: "add_exam".tr,
//       //     onPressed: () async {
//       //       final result = await Get.to(() => const AddExamScreen());
//       //       if (result == true) {
//       //         setState(() {});
//       //       }
//       //     },
//       //   ),
//       // ),
//     );
//   }

//   Widget _buildExamList(bool completed) {
//     return FutureBuilder<List<Exam>>(
//       future: _controller.fetchExams(completed: completed),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text("Error: ${snapshot.error}"));
//         }

//         final exams = snapshot.data ?? [];
//         if (exams.isEmpty) {
//           return Center(
//             child: Text(
//               completed ? "No completed exams." : "No upcoming exams scheduled.",
//               style: const TextStyle(color: Colors.grey),
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: exams.length,
//           itemBuilder: (context, index) {
//             final exam = exams[index];
//             return Container(
//               margin: const EdgeInsets.only(bottom: 15),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(18),
//                 child: Slidable(
//                   key: ValueKey(exam.id),
//                   endActionPane: ActionPane(
//                     motion: const ScrollMotion(),
//                     // extentRatio: 0.7,
//                     extentRatio: completed ? 0.5 : 0.75,
//                     children: [
//                       if (!completed)
//                         AppSlidableAction(
//                           onPressed: () async {
//                             if (exam.id != null) {
//                               showConfirmDialog(
//                                 context: context,
//                                 title: "make_completed".tr,
//                                 subTitle: "are_you_sure_make_completed".tr,
//                                 confirmText: "completed".tr,
//                                 onConfirm: () async {
//                                   // Update database status
//                                   await _controller.updateExamCompletionStatus(exam.id!, true);

//                                   // Rebuild UI state array arrays
//                                   setState(() {});
//                                 },
//                               );
//                             } else {
//                               AppSnackbar.showError(
//                                 title: "error".tr,
//                                 message: "cannot_make_completed".tr,
//                               );
//                             }
//                           },
//                           icon: Icons.check,
//                           label: 'completed'.tr,
//                           backgroundColor: AppColor().green,
//                           borderRadius: BorderRadius.zero,
//                         ),
//                       AppSlidableAction(
//                         onPressed: () async {
//                           // Navigate to AddExamScreen, passing the current exam model object
//                           final result = await Get.to(() => AddExamScreen(exam: exam));

//                           // If updating returned true, refresh the local view list state
//                           if (result == true) {
//                             setState(() {});
//                           }
//                         },
//                         icon: Icons.edit,
//                         label: 'edit'.tr,
//                         backgroundColor: AppColor().primaryColor,
//                       ),
//                       AppSlidableAction(
//                         onPressed: () async {
//                           if (exam.id != null) {
//                             showConfirmDialog(
//                               context: context,
//                               title: "delete".tr,
//                               subTitle: "delete_confirm".tr,
//                               confirmText: "delete".tr,
//                               onConfirm: () async {
//                                 // 2. Perform the deletion
//                                 await _controller.deleteExam(exam.id!);

//                                 // 3. Trigger a rebuild to pull the updated data array from the local DB
//                                 setState(() {});
//                               },
//                             );
//                           } else {
//                             AppSnackbar.showError(
//                               title: "error".tr,
//                               message: "cannot_delete_exam".tr,
//                             );
//                           }
//                         },
//                         icon: Icons.delete,
//                         label: 'delete'.tr,
//                         backgroundColor: AppColor().red,
//                         borderRadius: const BorderRadius.horizontal(
//                           right: Radius.circular(18),
//                         ),
//                       ),
//                     ],
//                   ),
//                   child: Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardColor,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: AppDecorations.subtleShadow,
//                     ),
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(18),
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => ExamDetailsScreen(exam: exam)),
//                       ).then((_) => setState(() {})),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     exam.title,
//                                     style: fix18(context),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     "${exam.date}  •  ${exam.time}",
//                                     style: text14(context).copyWith(color: AppColor().gray),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   "${exam.daysLeft}",
//                                   style: text22(context).copyWith(
//                                     color: AppColor().primaryColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   "days_left".tr,
//                                   style: text14(context).copyWith(color: AppColor().gray),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/controllers/exam_planner/exam_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/exam_planner/exam_model.dart';
import 'package:project_structure/views/exam_planner/add_exam_screen.dart';
import 'package:project_structure/widgets/custom_slidableasction.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
import 'exam_details_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ExamPlannerController _controller = ExamPlannerController();

  // Cache the futures so they don't trigger database calls on every UI rebuild
  late Future<List<Exam>> _upcomingExamsFuture;
  late Future<List<Exam>> _completedExamsFuture;

  // Global heartbeat timer to update list countdowns simultaneously every second
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

  // Helper calculation to parse date strings and extract exact time components
  Duration _calculateTimeRemaining(Exam exam) {
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
              color: Colors.grey.withValues(alpha: 0.1),
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
    return FutureBuilder<List<Exam>>(
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

            // Generate active dynamic durations per card item row element
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
                    extentRatio: completed ? 0.5 : 0.75,
                    children: [
                      if (!completed)
                        AppSlidableAction(
                          onPressed: () async {
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
                          icon: Icons.check,
                          label: 'completed'.tr,
                          backgroundColor: AppColor().green,
                          borderRadius: BorderRadius.zero,
                        ),
                      AppSlidableAction(
                        onPressed: () async {
                          final result = await Get.to(() => AddExamScreen(exam: exam));
                          if (result == true) {
                            _refreshLists();
                          }
                        },
                        icon: Icons.edit,
                        label: 'edit'.tr,
                        backgroundColor: AppColor().primaryColor,
                      ),
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
                        ),
                      ),
                    ],
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExamDetailsScreen(exam: exam)),
                      ).then((_) => _refreshLists()),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exam.title,
                                        style: fix18(context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${exam.date}  •  ${exam.time}",
                                        style: text14(context).copyWith(color: AppColor().gray),
                                      ),
                                    ],
                                  ),
                                ),
                                if (completed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColor().green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "done".tr,
                                      style: text12.copyWith(color: AppColor().green, fontWeight: FontWeight.bold),
                                    ),
                                  )
                              ],
                            ),

                            // Only display countdown array grids if the exam is active/upcoming
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
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColor().primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: text16(context).copyWith(fontWeight: FontWeight.bold, color: AppColor().primaryColor),
          ),
          Text(label, style: text12.copyWith(color: AppColor().gray)),
        ],
      ),
    );
  }
}
