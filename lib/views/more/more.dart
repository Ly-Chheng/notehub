import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/theme_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/more/widgets/dark_mode.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({
    super.key,
  });

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final controller = Get.put(DarkModeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _buildSectionContainer([
                _buildMenuTile(Icons.info_outline, "About", onTap: () {
                  Get.toNamed('/about');
                }),
                DarkModeView(),
                _buildMenuTile(Icons.help_outline, "How to use", onTap: () {
                  Get.toNamed('/howToUse');
                }),
                _buildMenuTile(
                  Icons.share_outlined,
                  "Share App",
                  onTap: () {},
                ),
                _buildMenuTile(
                  Icons.delete_outline,
                  "Recently Deleted",
                  onTap: () {
                    Get.toNamed('/recentyDelete');
                  },
                  isLast: true,
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 60),
                child: _buildSectionContainer([
                  _buildMenuTile(Icons.lock_outline, "Change Password", onTap: () {
                    Get.toNamed('/changePassword');
                  }),
                  _buildMenuTile(Icons.sync_lock_outlined, "Reset Password", onTap: () {
                    Get.toNamed('/resetPassword');
                  }),
                  _buildMenuTile(Icons.lock_reset, "Forget Password", onTap: () {
                    Get.toNamed('/fogetPassword');
                  }, isLast: true),
                ]),
              ),
              Text(
                "Copyright © 2026 Student Note App.\nVersion 1.0.0 (5)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor().gray,
                  fontSize: context.isPhone ? 12 : 14,
                  height: 1.5,
                  fontFamily: 'EN-REGULAR',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {required VoidCallback onTap, bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor().primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColor().primaryColor,
              size: context.isPhone ? 20 : 24,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: context.isPhone ? 15 : 17,
              fontFamily: 'EN-REGULAR',
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: context.isPhone ? 14 : 18,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),

        /// DIVIDER
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/views/more/widgets/dark_mode.dart';

// class MoreScreen extends StatelessWidget {
//   const MoreScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),

//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [

//           /// HEADER DASHBOARD
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(22),
//               gradient: LinearGradient(
//                 colors: [
//                   AppColor().primaryColor,
//                   AppColor().primaryColor.withOpacity(0.75),
//                 ],
//               ),
//             ),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.dashboard_customize,
//                     color: Colors.white, size: 40),
//                 SizedBox(height: 12),
//                 Text(
//                   "Settings Dashboard",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   "Manage your app preferences and account",
//                   style: TextStyle(color: Colors.white70),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           /// GRID MENU
//           GridView(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               mainAxisSpacing: 12,
//               crossAxisSpacing: 12,
//               childAspectRatio: 1.2,
//             ),
//             children: [

//               _buildCard(
//                 icon: Icons.info_outline,
//                 title: "About",
//                 color: Colors.blue,
//                 onTap: () => Get.toNamed('/about'),
//               ),

//               _buildCard(
//                 icon: Icons.help_outline,
//                 title: "How to Use",
//                 color: Colors.orange,
//                 onTap: () => Get.toNamed('/howToUse'),
//               ),

//               _buildCard(
//                 icon: Icons.delete_outline,
//                 title: "Trash",
//                 color: Colors.red,
//                 onTap: () => Get.toNamed('/recentyDelete'),
//               ),

//               _buildCard(
//                 icon: Icons.lock_outline,
//                 title: "Security",
//                 color: Colors.purple,
//                 onTap: () => Get.toNamed('/changePassword'),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           /// DARK MODE CARD
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 )
//               ],
//             ),
//             child: DarkModeView(),
//           ),

//           const SizedBox(height: 20),

//           /// FOOTER
//           Center(
//             child: Text(
//               "Version 1.0.0 • Student Note App",
//               style: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCard({
//     required IconData icon,
//     required String title,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             )
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: color, size: 26),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
