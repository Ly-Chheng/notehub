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
    return Container(
      height: context.isPhone ? 45 : 60,
      padding: EdgeInsets.all(context.isPhone ? 4 : 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EBF6),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            alignment: selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          Row(
            children: [
              /// Stopwatch
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = 0);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.bottomCenter,
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
              ),

              /// Timer
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.bottomCenter,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
