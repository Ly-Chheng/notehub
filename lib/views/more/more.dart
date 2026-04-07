import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/theme_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
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
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
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
                  isLast: true,
                ),
                _buildMenuTile(
                  Icons.delete_outline,
                  "Recently Deleted",
                  onTap: () {
                    Get.toNamed('/recentyDelete');
                  },
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
                "Copyright © 2026 Student Note App.\nVersion 1.0.0 (3)",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColor().gray, fontSize: context.isPhone ? 12 : 14, height: 1.5),
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
          title: Text(title, style: text16(context)),
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
