import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/theme_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/more/widgets/change_language.dart';
import 'package:project_structure/views/more/widgets/dark_mode.dart';
import 'package:project_structure/views/more/widgets/notification.dart';

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
                buildMenuTile(Icons.info_outline, "about".tr, onTap: () {
                  Get.toNamed('/about');
                }),
                DarkModeView(),
                NotificationView(),
                buildMenuTile(Icons.help_outline, "how_to_use".tr, onTap: () {
                  Get.toNamed('/howToUse');
                }),
                ChangeLanguageView(),
                buildMenuTile(
                  Icons.share_outlined,
                  "share_app".tr,
                  onTap: () {},
                ),
                buildMenuTile(
                  Icons.delete_outline,
                  "recently_deleted".tr,
                  onTap: () {
                    Get.toNamed('/recentyDelete');
                  },
                  isLast: true,
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 60),
                child: _buildSectionContainer([
                  buildMenuTile(Icons.lock_outline, "change_password".tr, onTap: () {
                    Get.toNamed('/changePassword');
                  }),
                  buildMenuTile(Icons.sync_lock_outlined, "reset_password".tr, onTap: () {
                    Get.toNamed('/resetPassword');
                  }),
                  buildMenuTile(Icons.lock_reset, "forget_password".tr, onTap: () {
                    Get.toNamed('/fogetPassword');
                  }, isLast: true),
                ]),
              ),
              Text(
                "copyright".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor().gray,
                  fontSize: context.isPhone ? 12 : 14,
                  height: 1.5,
                  fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
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
        boxShadow: AppDecorations.subtleShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget buildMenuTile(IconData icon, String title, {required VoidCallback onTap, bool isLast = false}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: context.isPhone ? 12 : 16,
              horizontal: 16,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor().primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppColor().primaryColor,
                    size: context.isPhone ? 20 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: text16(context),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.arrow_forward_ios,
                  size: context.isPhone ? 14 : 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        // if (!isLast)
        //   Padding(
        //     padding: const EdgeInsets.only(left: 60),
        //     child: Divider(
        //       height: 1,
        //       color: AppColor().gray.withValues(alpha: 0.1),
        //     ),
        //   ),
      ],
    );
  }
}
