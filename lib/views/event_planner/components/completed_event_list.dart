import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/event_planner/event_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/views/event_planner/event_details_screen.dart';
import 'package:project_structure/widgets/custom_slidableasction.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';

class CompletedEventList extends StatefulWidget {
  const CompletedEventList({super.key});

  @override
  State<CompletedEventList> createState() => _CompletedEventListState();
}

class _CompletedEventListState extends State<CompletedEventList> {
  final EventPlannerController _controller = Get.find<EventPlannerController>();
  late Future<List<EventModel>> _completedExamsFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _completedExamsFuture = _controller.fetchExams(completed: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventModel>>(
      future: _completedExamsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

        final exams = snapshot.data ?? [];
        if (exams.isEmpty) {
          return Center(child: Text("No completed exams.", style: const TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final event = exams[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Slidable(
                  key: ValueKey(event.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.3,
                    children: [
                      AppSlidableAction(
                        onPressed: () async {
                          if (event.id != null) {
                            showConfirmDialog(
                              context: context,
                              title: "delete".tr,
                              subTitle: "delete_confirm".tr,
                              confirmText: "delete".tr,
                              onConfirm: () async {
                                await _controller.deleteExam(event.id!);
                                _refreshList();
                              },
                            );
                          } else {
                            AppSnackbar.showError(title: "error".tr, message: "cannot_delete_exam".tr);
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
                      color: AppColor().green.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(18),
                      ),
                      boxShadow: AppDecorations.subtleShadow,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventDetailsScreen(exam: event)),
                      ).then((_) => _refreshList()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColor().green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 40,
                                color: AppColor().green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: fix18(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text("${event.date} | ${event.time}", style: text14(context).copyWith(color: AppColor().gray)),
                                ],
                              ),
                            ),
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
}
