import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/theme_controller.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/home/components/recently_deleted_screen.dart';
import 'package:project_structure/views/lock/remove_lock_screen.dart';
import 'package:project_structure/views/lock/change_password_screen.dart';
import 'package:project_structure/views/lock/forget_password_screen.dart';
import 'package:project_structure/views/more/about_screen.dart';
import 'package:project_structure/views/more/how_to_use_screen.dart';
import 'package:project_structure/views/more/widgets/dark_mode.dart';
// import 'package:share_plus/share_plus.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({
    super.key,
  });

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final controller = Get.put(DarkModeController());

  // void _shareApp() {
  //   Share.share(
  //     "Check out Student Note App!\n\nDownload now:\nhttps://play.google.com/store/apps/details?id=com.yourapp.id",
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _buildSectionContainer([
                _buildMenuTile(Icons.info_outline, "About", onTap: () {
                  Get.to(AboutScreen());
                }),
                DarkModeView(),
                // NotificationView(),
                _buildMenuTile(Icons.help_outline, "How to use", onTap: () {
                  Get.to(HowToUseScreen());
                }),
                _buildMenuTile(
                  Icons.share_outlined,
                  "Share App",
                  onTap: () {},
                  isLast: true,
                ),
                _buildMenuTile(
                  Icons.delete_outline,
                  "Recently Deleted",
                  onTap: () => Get.to(() => const RecentlyDeletedScreen()),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 60),
                child: _buildSectionContainer([
                  _buildMenuTile(Icons.lock_outline, "Change Password", onTap: () {
                    Get.to(() => const ChangePasswordScreen());
                  }),
                  _buildMenuTile(Icons.sync_lock_outlined, "Reset Password", onTap: () {
                    Get.to(() => const RemoveLockScreen());
                  }),
                  _buildMenuTile(Icons.lock_reset, "Forget Password", onTap: () {
                    Get.to(() => const ForgetPasswordScreen());
                  }, isLast: true),
                ]),
              ),
              Text(
                "Copyright © 2026 Student Note App.\nVersion 1.0.0 (2)",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: context.isPhone ? 12 : 14, height: 1.5),
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {required VoidCallback onTap, bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Text(title, style: text18(context)),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: context.isPhone ? 14 : 16,
          ),
          onTap: onTap,
        ),
      ],
    );
  }
}
