import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_header.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Welcome to Student Note!",
              style: TextStyle(fontSize: 28, fontFamily: 'EN-BOLD'),
            ),
            const SizedBox(height: 6),
            const Text(
              "Follow these simple steps to master your notes.",
              style: TextStyle(fontSize: 16, fontFamily: 'EN-REGULAR', color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildStepCard(
              context,
              stepNumber: "1",
              title: "Create Your First Note",
              description: "Tap the '+' button on the home screen to start writing. Add titles and body text easily.",
              icon: Icons.edit_note_rounded,
              iconColor: Colors.blue,
            ),
            _buildStepCard(
              context,
              stepNumber: "2",
              title: "Organize with Folders",
              description: "Swipe left on any note to move it to a specific folder like 'Homework' or 'Exams'.",
              icon: Icons.folder_copy_rounded,
              iconColor: Colors.orange,
            ),
            _buildStepCard(
              context,
              stepNumber: "3",
              title: "Secure Your Content",
              description: "Use the 'Lock' feature in the note menu to protect sensitive information with a password.",
              icon: Icons.lock_person_rounded,
              iconColor: Colors.redAccent,
            ),
            _buildStepCard(
              context,
              stepNumber: "4",
              title: "Focus with Stopwatch",
              description: "Use the built-in stopwatch to track your study sessions and stay productive.",
              icon: Icons.timer_outlined,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Circle Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [iconColor.withOpacity(0.3), iconColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "STEP $stepNumber",
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontFamily: 'EN-MEDIUM',
                  ),
                ),
                const SizedBox(height: 4),
                customHeader(title),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'EN-REGULAR',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}