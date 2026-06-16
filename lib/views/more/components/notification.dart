import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/settings_controller.dart';
import 'package:project_structure/widgets/card_and_button/custom_card_setting.dart';

class NotificationView extends StatelessWidget {
  NotificationView({super.key});

  final RxBool notificationEnabled = true.obs;
  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return CustomCardSetting(
      icon: Icons.notifications_outlined,
      title: "notification".tr,
      onTap: () {},
      trailing: Obx(() => Switch.adaptive(
            value: controller.isNotificationEnabled.value,
            onChanged: (value) => controller.toggleNotifications(value),
            // activeTrackColor: AppColor().primaryColor,
          )),
    );
  }
}
