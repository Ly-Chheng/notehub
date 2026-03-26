import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/views/focus_track/components/timer_component.dart';
import 'package:project_structure/views/focus_track/components/stopwatch_component.dart';

class FocusTrackScreen extends StatefulWidget {
  // 1. Add this callback to communicate with the parent AppBar
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

  // 2. Helper to update local UI and notify the parent screen
  void _handleToggle(int index) {
    setState(() {
      selectedIndex = index;
    });
    // Send the index (0 or 1) back to the BottomNavigationBarScreen
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        color: Colors.grey.withOpacity(0.1),
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
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            children: [
              _toggleItem("Stopwatch", 0),
              _toggleItem("Timer", 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleToggle(index), // Trigger the update
        child: Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'EN-SEMIBOLD',
              color: selectedIndex == index ? Colors.black : Colors.grey,
              fontSize: context.isPhone ? 16 : 18,
            ),
          ),
        ),
      ),
    );
  }
}
