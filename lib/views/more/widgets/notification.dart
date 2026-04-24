import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isNotificationOn = true.obs;

    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: Theme.of(context).iconTheme.color,
                    ), // Updated icon
                    const SizedBox(width: 15),
                    Text(
                      'Notification',
                      style: TextStyle(
                        fontFamily: 'EN-REGULAR',
                        fontSize: context.isPhone ? 16 : 18,
                      ),
                    ),
                  ],
                ),
                Obx(() => Switch.adaptive(
                      activeThumbColor: AppColor().green,
                      onChanged: (value) {
                        isNotificationOn.value = value;
                      },
                      value: isNotificationOn.value,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
