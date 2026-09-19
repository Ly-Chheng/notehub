import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/event_planner/event_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/views/event_planner/event_details_screen.dart';
import 'package:project_structure/widgets/app_slidable_asction.dart';
import 'package:project_structure/widgets/app_snack_bar.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';

class CompletedEventList extends StatefulWidget {
  const CompletedEventList({super.key});

  @override
  State<CompletedEventList> createState() => _CompletedEventListState();
}

class _CompletedEventListState extends State<CompletedEventList> {
  final EventPlannerController _controller = Get.find<EventPlannerController>();
  late Future<List<EventModel>> _completedEventsFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _completedEventsFuture = _controller.fetchEvent(completed: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventModel>>(
      future: _completedEventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: CustomNoData(
              message: "no_data".tr,
            ),
          );
        }

        return SlidableAutoCloseBehavior(
          closeWhenOpened: true,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: Slidable(
                  key: ValueKey(event.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.3,
                    children: [
                      //swipe to delete action
                      AppSlidableAction(
                        onPressed: () async {
                          if (event.id != null) {
                            showConfirmDialog(
                              context: context,
                              title: "delete".tr,
                              subTitle: "delete_confirm".tr,
                              confirmText: "delete".tr,
                              onConfirm: () async {
                                await _controller.deleteEvent(event.id!);
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
                          right: Radius.circular(20),
                          left: Radius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: Layout.cardDecoration(radius: 20.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventDetailsScreen(event: event)),
                      ).then((_) => _refreshList()),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColor().green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.check,
                                size: context.isPhone ? 40 : 45,
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
              );
            },
          ),
        );
      },
    );
  }
}
