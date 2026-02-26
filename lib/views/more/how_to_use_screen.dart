import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: customAppBar(
        title: "How to Use",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().black,
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text(
            "Welcome to Student Note!",
            style: TextStyle(fontSize: 24, fontFamily: 'EN-BOLD'),
          ),
          const SizedBox(height: 8),
          const Text(
            "Follow these simple steps to master your notes.",
            style: TextStyle(color: Colors.grey, fontSize: 16,fontFamily: 'EN-REGULAR'),
          ),
          const SizedBox(height: 30),

          _buildStepCard(
            stepNumber: "1",
            title: "Create Your First Note",
            description: "Tap the '+' button on the home screen to start writing. You can add titles and body text easily.",
            icon: Icons.edit_note_rounded,
            iconColor: Colors.blue,
          ),
          _buildStepCard(
            stepNumber: "2",
            title: "Organize with Folders",
            description: "Swipe left on any note to move it to a specific folder like 'Homework' or 'Exams'.",
            icon: Icons.folder_copy_rounded,
            iconColor: Colors.orange,
          ),
          _buildStepCard(
            stepNumber: "3",
            title: "Secure Your Content",
            description: "Use the 'Lock' feature in the note menu to protect sensitive information with a password.",
            icon: Icons.lock_person_rounded,
            iconColor: Colors.redAccent,
          ),
          _buildStepCard(
            stepNumber: "4",
            title: "Focus with Stopwatch",
            description: "Use the built-in stopwatch to track your study sessions and stay productive.",
            icon: Icons.timer_outlined,
            iconColor: Colors.green,
          ),

          const SizedBox(height: 20),
          // Footer Contact Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor().primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help_center_outlined,
                  color: AppColor().primaryColor,
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    "Still need help? Contact our student support team.",
                    style: TextStyle(fontSize: 14,fontFamily: 'EN-REGULAR'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- STEP CARD BUILDER ---
  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 20),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "STEP $stepNumber",
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontFamily: 'EN-MEDIUM',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontFamily: 'EN-BOLD'),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54, height: 1.4, fontFamily: 'EN-REGULAR'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
