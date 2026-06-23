import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/mores/notification_controller.dart';
import 'package:project_structure/controllers/mores/theme_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/views/more/components/font_size.dart';
import 'package:project_structure/views/more/components/change_language.dart';
import 'package:project_structure/views/more/components/dark_mode.dart';
import 'package:project_structure/widgets/card_and_button/custom_card_setting.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({
    super.key,
  });

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final controller = Get.put(DarkModeController());
  final RxBool notificationEnabled = true.obs;
  final NotificationController notificontroller = Get.put(NotificationController());

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
                  icon: Icons.text_fields,
                  title: "font_size".tr,
                  onTap: () {
                    Get.bottomSheet(const FontSizeBottomSheet());
                  },
                ),
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
                CustomCardSetting(
                  icon: Icons.school_outlined,
                  title: "exams".tr,
                  onTap: () {
                    Get.toNamed('/examList');
                  },
                ),
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: _buildSectionContainer([
                  DarkModeView(),
                  CustomCardSetting(
                    icon: Icons.notifications_outlined,
                    title: "notification".tr,
                    onTap: () {},
                    trailing: Obx(() => Switch.adaptive(
                          value: notificontroller.isNotificationEnabled.value,
                          onChanged: (value) => notificontroller.toggleNotifications(value),
                        )),
                  ),
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
                    Get.toNamed('/fogetPassword');
                  },
                ),
              ]),
              SizedBox(
                height: 15,
              ),
              Text("copyright".tr,
                  textAlign: TextAlign.center,
                  style: text12.copyWith(
                    height: 1.5,
                  )),
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
