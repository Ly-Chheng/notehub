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
                colors: [
                  AppColor().primaryColor,
                  AppColor().primaryColor.withOpacity(0.7),
                ],
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              Container(
                width: 2,
                height: 120,
                color: Colors.grey.shade300,
              ),
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
                    color: Colors.black.withOpacity(0.05),
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
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "STEP $step",
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
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

// import 'package:flutter/material.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';

// class HowToUseScreen extends StatelessWidget {
//   const HowToUseScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: customAppBar(
//         backgroundColor: Colors.transparent,
//         title: "How to Use",
//         titleColor: AppColor().primaryColor,
//         context: context,
//         leadingColor: AppColor().primaryColor,
//         actions: [],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           /// TOP WELCOME CARD
//           Container(
//             padding: const EdgeInsets.all(25),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(35),
//               gradient: LinearGradient(
//                 colors: [
//                   AppColor().primaryColor,
//                   AppColor().primaryColor.withOpacity(0.75),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(
//                   Icons.school_rounded,
//                   color: Colors.white,
//                   size: 55,
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   "Student Note Guide",
//                   style: TextStyle(
//                     fontSize: 28,
//                     color: Colors.white,
//                     fontFamily: 'EN-BOLD',
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "Everything you need to manage your study notes effectively.",
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.white70,
//                     fontFamily: 'EN-REGULAR',
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 28),

//           _buildModernCard(
//             title: "Create Notes",
//             subtitle: "Quickly write and save study notes.",
//             icon: Icons.edit_note_rounded,
//             bgColor: const Color(0xFFEFF4FF),
//             iconColor: const Color(0xFF5B8DEF),
//           ),

//           _buildModernCard(
//             title: "Manage Folder",
//             subtitle: "Organize subjects into folders.",
//             icon: Icons.folder_copy_rounded,
//             bgColor: const Color(0xFFFFF5E9),
//             iconColor: const Color(0xFFFFA726),
//           ),

//           _buildModernCard(
//             title: "Lock Notes",
//             subtitle: "Keep important content private.",
//             icon: Icons.lock_rounded,
//             bgColor: const Color(0xFFFFEEF1),
//             iconColor: const Color(0xFFE53935),
//           ),

//           _buildModernCard(
//             title: "Study Timer",
//             subtitle: "Stay productive with focus sessions.",
//             icon: Icons.timer_rounded,
//             bgColor: const Color(0xFFEEF9F2),
//             iconColor: const Color(0xFF43A047),
//           ),

//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernCard({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color bgColor,
//     required Color iconColor,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 18),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           /// ICON BOX
//           Container(
//             height: 75,
//             width: 75,
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Icon(
//               icon,
//               color: iconColor,
//               size: 38,
//             ),
//           ),

//           const SizedBox(width: 18),

//           /// TEXT
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontFamily: 'EN-BOLD',
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                     fontFamily: 'EN-REGULAR',
//                     height: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           /// ARROW
//           Container(
//             height: 45,
//             width: 45,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';

// class HowToUseScreen extends StatelessWidget {
//   const HowToUseScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FC),
//       appBar: customAppBar(
//         backgroundColor: Colors.transparent,
//         title: "How To Use",
//         titleColor: AppColor().primaryColor,
//         context: context,
//         leadingColor: AppColor().primaryColor,
//         actions: [],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           const SizedBox(height: 10),

//           /// HEADER
//           const Text(
//             "Learn Student Note",
//             style: TextStyle(
//               fontSize: 32,
//               fontFamily: 'EN-BOLD',
//             ),
//           ),

//           const SizedBox(height: 8),

//           Text(
//             "Simple guide to organize your notes and improve study productivity.",
//             style: TextStyle(
//               fontSize: 15,
//               color: Colors.grey.shade600,
//               fontFamily: 'EN-REGULAR',
//               height: 1.5,
//             ),
//           ),

//           const SizedBox(height: 30),

//           _buildGuideCard(
//             step: "01",
//             title: "Create Notes",
//             description:
//                 "Tap the + button and start writing your lesson notes quickly.",
//             icon: Icons.edit_note_rounded,
//             color1: const Color(0xFF5B86E5),
//             color2: const Color(0xFF36D1DC),
//           ),

//           _buildGuideCard(
//             step: "02",
//             title: "Manage Folders",
//             description:
//                 "Keep everything organized by subjects or categories.",
//             icon: Icons.folder_copy_rounded,
//             color1: const Color(0xFFFF9966),
//             color2: const Color(0xFFFF5E62),
//           ),

//           _buildGuideCard(
//             step: "03",
//             title: "Lock Notes",
//             description:
//                 "Secure your private notes using password protection.",
//             icon: Icons.lock_rounded,
//             color1: const Color(0xFF834D9B),
//             color2: const Color(0xFFD04ED6),
//           ),

//           _buildGuideCard(
//             step: "04",
//             title: "Study Timer",
//             description:
//                 "Track your study session and stay focused every day.",
//             icon: Icons.timer_rounded,
//             color1: const Color(0xFF11998E),
//             color2: const Color(0xFF38EF7D),
//           ),

//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildGuideCard({
//     required String step,
//     required String title,
//     required String description,
//     required IconData icon,
//     required Color color1,
//     required Color color2,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 22),
//       height: 180,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(35),
//         gradient: LinearGradient(
//           colors: [color1, color2],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: color1.withOpacity(0.25),
//             blurRadius: 18,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           /// BIG BACKGROUND NUMBER
//           Positioned(
//             right: -10,
//             top: -20,
//             child: Text(
//               step,
//               style: TextStyle(
//                 fontSize: 120,
//                 color: Colors.white.withOpacity(0.12),
//                 fontFamily: 'EN-BOLD',
//               ),
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// ICON
//                 Container(
//                   height: 60,
//                   width: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: Icon(
//                     icon,
//                     color: Colors.white,
//                     size: 32,
//                   ),
//                 ),

//                 const Spacer(),

//                 /// TITLE
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontFamily: 'EN-BOLD',
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 /// DESCRIPTION
//                 Text(
//                   description,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 14,
//                     height: 1.5,
//                     fontFamily: 'EN-REGULAR',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';

// class HowToUseScreen extends StatelessWidget {
//   const HowToUseScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       appBar: customAppBar(
//         backgroundColor: Colors.transparent,
//         title: "How To Use",
//         titleColor: AppColor().primaryColor,
//         context: context,
//         leadingColor: AppColor().primaryColor,
//         actions: [],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           const Text(
//             "Get Started",
//             style: TextStyle(
//               fontSize: 30,
//               fontFamily: 'EN-BOLD',
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Follow these simple steps to use Student Note",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 25),

//           _buildCheckItem(
//             icon: Icons.check_circle,
//             color: Colors.blue,
//             title: "Create your first note",
//             desc: "Tap + button and start writing your ideas or lessons.",
//           ),

//           _buildCheckItem(
//             icon: Icons.check_circle,
//             color: Colors.orange,
//             title: "Organize into folders",
//             desc: "Group notes by subject like Math, Science, or English.",
//           ),

//           _buildCheckItem(
//             icon: Icons.check_circle,
//             color: Colors.red,
//             title: "Lock private notes",
//             desc: "Protect sensitive notes with a secure password lock.",
//           ),

//           _buildCheckItem(
//             icon: Icons.check_circle,
//             color: Colors.green,
//             title: "Use study timer",
//             desc: "Track your study time and improve focus daily.",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCheckItem({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String desc,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           )
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 26),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontFamily: 'EN-BOLD',
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   desc,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';

// class HowToUseScreen extends StatelessWidget {
//   const HowToUseScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F8FC),
//       appBar: customAppBar(
//         backgroundColor: Colors.transparent,
//         title: "How it works",
//         titleColor: AppColor().primaryColor,
//         context: context,
//         leadingColor: AppColor().primaryColor,
//         actions: [],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         children: [

//           /// HEADER SECTION (PRO STYLE)
//           Container(
//             padding: const EdgeInsets.all(22),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(28),
//               gradient: LinearGradient(
//                 colors: [
//                   AppColor().primaryColor,
//                   AppColor().primaryColor.withOpacity(0.75),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.auto_awesome_rounded,
//                     color: Colors.white, size: 40),
//                 SizedBox(height: 12),
//                 Text(
//                   "Start using Student Note",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontFamily: 'EN-BOLD',
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   "A simple guide to help you organize, secure, and track your study notes.",
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 25),

//           /// SECTION TITLE
//           Text(
//             "Quick Guide",
//             style: TextStyle(
//               fontSize: 18,
//               fontFamily: 'EN-BOLD',
//               color: Colors.grey.shade800,
//             ),
//           ),

//           const SizedBox(height: 15),

//           _buildProStep(
//             number: "01",
//             title: "Create Notes Instantly",
//             description:
//                 "Tap the create button to start writing your notes in seconds.",
//             icon: Icons.edit_note_rounded,
//             color: const Color(0xFF4F7CFE),
//           ),

//           _buildProStep(
//             number: "02",
//             title: "Organize Everything",
//             description:
//                 "Use folders to separate subjects and keep your workspace clean.",
//             icon: Icons.folder_rounded,
//             color: const Color(0xFFFFA726),
//           ),

//           _buildProStep(
//             number: "03",
//             title: "Protect Your Data",
//             description:
//                 "Lock important notes using built-in security protection.",
//             icon: Icons.lock_rounded,
//             color: const Color(0xFFEF5350),
//           ),

//           _buildProStep(
//             number: "04",
//             title: "Track Study Time",
//             description:
//                 "Use the timer to improve focus and build better habits.",
//             icon: Icons.timer_rounded,
//             color: const Color(0xFF26A69A),
//           ),

//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildProStep({
//     required String number,
//     required String title,
//     required String description,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           /// NUMBER BADGE
//           Container(
//             height: 46,
//             width: 46,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               number,
//               style: TextStyle(
//                 color: color,
//                 fontFamily: 'EN-BOLD',
//               ),
//             ),
//           ),

//           const SizedBox(width: 14),

//           /// CONTENT
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(icon, size: 18, color: color),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontFamily: 'EN-BOLD',
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   description,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const Icon(
//             Icons.arrow_forward_ios_rounded,
//             size: 14,
//             color: Colors.grey,
//           ),
//         ],
//       ),
//     );
//   }
// }
