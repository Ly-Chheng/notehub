import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/focus_track/components/timer_list.dart';
import 'package:project_structure/views/focus_track/components/stopwatch.dart';

class FocusTrackScreen extends StatefulWidget {
  final ValueChanged<int>? onToggleChanged;
  const FocusTrackScreen({super.key, this.onToggleChanged});

  @override
  State<FocusTrackScreen> createState() => _FocusTrackScreenState();
}

class _FocusTrackScreenState extends State<FocusTrackScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;

  final List<Widget> screens = [
    StopwatchScreen(),
    const TimerList(),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _handleToggle(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleToggle(int index) {
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });

    if (widget.onToggleChanged != null) {
      widget.onToggleChanged!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            FocusToggleSwitch(tabController: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: screens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// separate StatelessWidget to reduce rebuilds and improve performance.
class FocusToggleSwitch extends StatelessWidget {
  final TabController tabController;

  const FocusToggleSwitch({
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
          Tab(text: "stopwatch".tr),
          Tab(text: "timer".tr),
        ],
      ),
    );
  }
}
