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

    int initialTab = 0;
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['tab'] != null) {
      initialTab = Get.arguments['tab'];
    }

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
          EventToggleSwitch(tabController: _tabController),
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

// separate StatelessWidget to reduce rebuilds and improve performance.
class EventToggleSwitch extends StatelessWidget {
  final TabController tabController;

  const EventToggleSwitch({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicator: BoxDecoration(
          color: AppColor().primaryColor,
          borderRadius: BorderRadius.circular(context.isPhone ? 25 : 45),
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
    );
  }
}
