import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/views/focus_track/components/timer_component.dart';
import 'package:project_structure/views/focus_track/components/stopwatch_component.dart';

class FocusTrackScreen extends StatefulWidget {
  const FocusTrackScreen({super.key});

  @override
  State<FocusTrackScreen> createState() => _FocusTrackScreenState();
}

class _FocusTrackScreenState extends State<FocusTrackScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    StopwatchScreen(),
    TimerComponent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildToggleSwitch(context),
            ),

            /// Screen content
            Expanded(child: screens[selectedIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(BuildContext context) {
  double switchWidth = MediaQuery.of(context).size.width - 40; // total width minus padding

  return Container(
    height: context.isPhone ? 45 : 60,
    decoration: BoxDecoration(
      color: const Color(0xFFE8EBF6),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Stack(
      children: [
        // Sliding background
        AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            width: switchWidth / 2,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        // Two tappable halves
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = 0);
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent, 
                  child: Text(
                    "Stopwatch",
                    style: TextStyle(
                      fontFamily: 'EN-BOLD',
                      color: selectedIndex == 0 ? Colors.black : Colors.grey,
                      fontSize: context.isPhone ? 16 : 18,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = 1);
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent, // make full container tappable
                  child: Text(
                    "Timer",
                    style: TextStyle(
                      fontFamily: 'EN-BOLD',
                      fontSize: context.isPhone ? 16 : 18,
                      color: selectedIndex == 1 ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}
