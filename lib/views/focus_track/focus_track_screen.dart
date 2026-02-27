import 'package:flutter/material.dart';
import 'package:project_structure/views/focus_track/components/stopwatch_component.dart';
import 'package:project_structure/views/focus_track/components/create_timer_component.dart';

class FocusTrackScreen extends StatefulWidget {
  const FocusTrackScreen({super.key});

  @override
  State<FocusTrackScreen> createState() => _FocusTrackScreenState();
}

class _FocusTrackScreenState extends State<FocusTrackScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const StopwatchScreen(),
    CreateTimerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildToggleSwitch(),
            ),

            /// Screen content
            Expanded(child: screens[selectedIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EBF6),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          /// Sliding active tab
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
