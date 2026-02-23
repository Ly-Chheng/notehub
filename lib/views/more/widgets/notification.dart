import 'package:flutter/material.dart';
import 'package:get/get.dart';

// You might want to create a separate controller for this later
// For now, I'll keep the structure consistent with your DarkModeView
class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a RxBool for local state demo, or replace with your actual controller
    RxBool isNotificationOn = true.obs; 

    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.black87), // Updated icon
                    const SizedBox(width: 15),
                    Text(
                      'Notification',
                      style: TextStyle(
                        // fontFamily: Get.locale == const Locale('km', 'KM') 
                        //     ? 'KH-REGULAR' 
                        //     : 'EN-REGULAR',
                        fontSize: context.isPhone ? 16 : 18, // Adjusted to match your "More" screen font size
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Obx(() => Switch.adaptive(
                  activeColor: Colors.green, // Matching your app's blue branding
                  onChanged: (value) {
                    isNotificationOn.value = value;
                    // Add your notification service logic here
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