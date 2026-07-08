import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/event_planner/event_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/event_planner/components/completed_event_list.dart';
import 'package:project_structure/views/event_planner/components/upcoming_event_list.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 2, vsync: this);

  //   Get.put(EventPlannerController());
  // }
  @override
  void initState() {
    super.initState();

    // 1. Safely extract argument settings passed via Get.toNamed() Routing
    int initialTab = 0;
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['tab'] != null) {
      initialTab = Get.arguments['tab'];
    }

    // 2. Initialize the tab controller utilizing the dynamically passed initialIndex profile
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialTab,
    );

    Get.put(EventPlannerController());
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
      body: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
              children: const [
                UpcomingEventList(),
                CompletedEventList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
