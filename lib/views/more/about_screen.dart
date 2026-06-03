// import 'package:flutter/material.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';
// import 'package:project_structure/widgets/custome_no_data.dart';

// class AboutScreen extends StatelessWidget {
//   const AboutScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: customAppBar(
//         title: "About",
//         titleColor: AppColor().primaryColor,
//         context: context,
//         leadingColor: AppColor().primaryColor,
//         actions: [],
//       ),
//       body: Center(
//         child: CustomNoData(
//           message: "No Data",
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColor().primaryColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "about".tr,
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.75),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 95,
                    width: 95,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor().white.withValues(alpha: 0.18),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 50,
                      color: AppColor().white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Student Note App",
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColor().white,
                      fontFamily: 'EN-BOLD',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Study smarter, stay organized",
                    style: TextStyle(
                      color: AppColor().white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontFamily: 'EN-BOLD',
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColor().white.withValues(alpha: 0.16),
                    ),
                    child: Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        color: AppColor().white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'EN-BOLD',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            /// About App Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColor().primaryColor,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "About Application",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'EN-BOLD',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Student Note App helps students organize notes, "
                    "manage study materials, and improve productivity "
                    "through a clean, simple, and modern experience. "
                    "You can create, edit, and manage notes anytime "
                    "to support better learning and organization.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      fontFamily: 'EN-REGULAR',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Features Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_outline_rounded,
                        color: AppColor().primaryColor,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Features",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    icon: Icons.note_alt_outlined,
                    title: "Create Notes",
                    subtitle: "Write and save study notes easily",
                  ),
                  _buildFeatureItem(
                    icon: Icons.edit_note_rounded,
                    title: "Edit Anytime",
                    subtitle: "Update notes whenever needed",
                  ),
                  _buildFeatureItem(
                    icon: Icons.school_outlined,
                    title: "Study Smarter",
                    subtitle: "Organize subjects and materials",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Contact Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColor().primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.email_outlined,
                        color: AppColor().primaryColor,
                      ),
                    ),
                    title: const Text("Email"),
                    subtitle: const Text("support@studentnoteapp.com"),
                  ),
                  Divider(
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColor().primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.language_rounded,
                        color: AppColor().primaryColor,
                      ),
                    ),
                    title: const Text("Website"),
                    subtitle: const Text("www.studentnoteapp.com"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Footer
            Text(
              "© 2026 Student Note App",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor().primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColor().primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'EN-BOLD'),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontFamily: 'EN-REGULAR'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
