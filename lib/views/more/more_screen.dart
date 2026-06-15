import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/theme_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/views/more/components/change_language.dart';
import 'package:project_structure/views/more/components/dark_mode.dart';
import 'package:project_structure/views/more/components/notification.dart';
import 'package:project_structure/widgets/custom_card_setting.dart';

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
        padding: Layout.padding(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _buildSectionContainer([
                CustomCardSetting(
                  icon: Icons.info_outline,
                  title: "about".tr,
                  onTap: () {
                    Get.toNamed('/about');
                  },
                ),
                CustomCardSetting(
                  icon: Icons.help_outline,
                  title: "how_to_use".tr,
                  onTap: () {
                    Get.toNamed('/howToUse');
                  },
                ),
                ChangeLanguageView(),
                CustomCardSetting(
                  icon: Icons.share_outlined,
                  title: "share_app".tr,
                  onTap: () {},
                ),
                CustomCardSetting(
                  icon: Icons.delete_outline,
                  title: "recently_deleted".tr,
                  onTap: () {
                    Get.toNamed('/recentyDelete');
                  },
                ),
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: _buildSectionContainer([
                  DarkModeView(),
                  NotificationView(),
                ]),
              ),
              _buildSectionContainer([
                CustomCardSetting(
                  icon: Icons.lock_outline,
                  title: "change_password".tr,
                  onTap: () {
                    Get.toNamed('/changePassword');
                  },
                ),
                CustomCardSetting(
                  icon: Icons.sync_lock_outlined,
                  title: "reset_password".tr,
                  onTap: () {
                    Get.toNamed('/resetPassword');
                  },
                ),
                CustomCardSetting(
                  icon: Icons.lock_reset,
                  title: "forget_password".tr,
                  onTap: () {
                    Get.toNamed('/forgetPassword');
                  },
                ),
              ]),
              SizedBox(
                height: 15,
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
}
