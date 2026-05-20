import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: "How to Use",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          /// HEADER
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [AppColor().primaryColor, AppColor().primaryColor.withValues(alpha: 0.7)],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 45,
                ),
                SizedBox(height: 14),
                Text(
                  "How To Use Student Note",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontFamily: 'EN-BOLD',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Master your notes with simple steps and boost your productivity.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontFamily: 'EN-REGULAR',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          _buildTimelineCard(
            context,
            step: "01",
            title: "Create Your First Note",
            description: "Tap the '+' button to quickly create notes and add your important study materials.",
            icon: Icons.edit_note_rounded,
            color: AppColor().primaryColor,
          ),

          _buildTimelineCard(
            context,
            step: "02",
            title: "Organize with Folders",
            description: "Group your notes into folders like Homework, Exams, or Projects.",
            icon: Icons.folder_copy_rounded,
            color: AppColor().orange,
          ),

          _buildTimelineCard(
            context,
            step: "03",
            title: "Secure Your Notes",
            description: "Lock important notes to protect private or sensitive information.",
            icon: Icons.lock_rounded,
            color: AppColor().red,
          ),

          _buildTimelineCard(
            context,
            step: "04",
            title: "Study with Stopwatch",
            description: "Track your study time and improve focus using the stopwatch feature.",
            icon: Icons.timer_rounded,
            color: AppColor().green,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context, {
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Timeline
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              // Container(
              //   width: 2,
              //   height: 120,
              //   color: AppColor().gray.withOpacity(0.2),
              // ),
            ],
          ),

          const SizedBox(width: 18),

          /// Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "STEP $step",
                      style: TextStyle(
                        color: color,
                        fontSize: AppFontSize(context).normalTextSize,
                        fontFamily: 'EN-BOLD',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(title, style: text20(context)),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade700,
                      fontFamily: 'EN-REGULAR',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
