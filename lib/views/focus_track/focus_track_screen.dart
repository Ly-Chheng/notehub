import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/focus_track/components/timer_component.dart';
import 'package:project_structure/views/focus_track/components/stopwatch_component.dart';

class FocusTrackScreen extends StatefulWidget {
  final ValueChanged<int>? onToggleChanged;
  const FocusTrackScreen({super.key, this.onToggleChanged});

  @override
  State<FocusTrackScreen> createState() => _FocusTrackScreenState();
}

class _FocusTrackScreenState extends State<FocusTrackScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    StopwatchScreen(),
    TimerComponent(),
  ];

  void _handleToggle(int index) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildToggleSwitch(context),
            ),
            Expanded(child: screens[selectedIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(BuildContext context) {
    double switchWidth = MediaQuery.of(context).size.width - 40;
    return Container(
      height: context.isPhone ? 45 : 60,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.isPhone ? 25 : 45),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: (switchWidth / 2) - 8,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(context.isPhone ? 20 : 40),
              ),
            ),
          ),
          Row(
            children: [
              _toggleItem("stopwatch".tr, 0),
              _toggleItem("timer".tr, 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, int index) {
    final Color activeColor = Theme.of(context).brightness == Brightness.dark ? AppColor().white : AppColor().black;
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleToggle(index),
        child: Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          child: Text(
            label,
            style: TextStyle(
              // fontFamily: 'EN-SEMIBOLD',
              fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
              color: selectedIndex == index ? activeColor : AppColor().gray,
              fontSize: context.isPhone ? 16 : 18,
            ),
          ),
        ),
      ),
    );
  }
}
