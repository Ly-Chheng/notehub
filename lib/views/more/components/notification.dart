import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/settings_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';

class NotificationView extends StatelessWidget {
  NotificationView({super.key});

  final RxBool notificationEnabled = true.obs;
  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: context.isPhone ? 5 : 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor().primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColor().primaryColor,
                        size: context.isPhone ? 20 : 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'notification'.tr,
                      style: TextStyle(
                        fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
                        fontSize: context.isPhone ? 15 : 17,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                Obx(() => Switch.adaptive(
                      value: controller.isNotificationEnabled.value,
                      onChanged: (value) => controller.toggleNotifications(value),
                      activeTrackColor: AppColor().primaryColor,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
