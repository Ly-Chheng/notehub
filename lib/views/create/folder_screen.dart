import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: customAppBar(
        title: "Folder",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          Center(child: Text("My Note", style: TextStyle(color: AppColor().primaryColor, fontWeight: FontWeight.w500,fontSize: 16))),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Today", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // _buildSlidableNote(
            //   title: "Homework",
            //   subtitle: "Day to practice class...",
            //   date: "02/01/2026",
            // ),
            _buildSlidableNote(
              title: "Homework",
              subtitle: "Day to practice class...",
              date: "02/01/2026",
            ),
            const SizedBox(height: 12),
            _buildSlidableNote(
              title: "Exams & Quizzes",
              subtitle: "Test-related work including quizzes, ...",
              date: "29/01/2026",
              hasImage: true, // This activates the image container on the right
            ),
            const SizedBox(height: 12),
            _buildSlidableNote(
              title: "Projects",
              subtitle: "Large assignments that require research...",
              date: "30/01/2026",
              isLocked: true, // You can still pass parameters through
            ),
          ],
        ),
      ),

      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGET BUILDERS ---

  // Widget _buildSlidableNote({required String title, required String subtitle, required String date}) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(12),
  //     child: Slidable(
  //       endActionPane: ActionPane(
  //         motion: const ScrollMotion(),
  //         children: [
  //           SlidableAction(onPressed: (context) {}, backgroundColor: Colors.orange, icon: Icons.push_pin_outlined),
  //           SlidableAction(onPressed: (context) {}, backgroundColor: Colors.blue, icon: Icons.folder_open),
  //           SlidableAction(onPressed: (context) {}, backgroundColor: Colors.red, icon: Icons.delete_outline),
  //         ],
  //       ),
  //       child: _buildNoteCard(title: title, subtitle: subtitle, date: date),
  //     ),
  //   );
  // }
  // --- SLIDABLE NOTE BUILDER WITH IMAGE SUPPORT ---
  Widget _buildSlidableNote({
    required String title,
    required String subtitle,
    required String date,
    bool hasImage = false, // Added this
    String? imageUrl, // Optional: Pass the image source
    bool isLocked = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          key: ValueKey(title),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.6,
            children: [
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.push_pin_outlined,
              ),
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.folder_open,
              ),
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline_rounded,
              ),
            ],
          ),
          // Pass the image parameters to the card
          child: _buildNoteCard(
            title: title,
            subtitle: subtitle,
            date: date,
            hasImage: hasImage,
            isLocked: isLocked,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard({required String title, required String subtitle, required String date, bool hasImage = false, bool isLocked = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isLocked) const Icon(Icons.lock_outline, size: 18, color: Colors.red),
                    if (isLocked) const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (hasImage) Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8))),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home, color: Colors.blue),
          Icon(Icons.timer_outlined, color: Colors.grey),
          Icon(Icons.grid_view_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
