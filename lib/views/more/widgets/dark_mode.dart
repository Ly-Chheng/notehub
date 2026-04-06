import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/services/themes_services.dart';
import 'package:project_structure/controllers/more/theme_controller.dart';

class DarkModeView extends GetView<DarkModeController> {
  @override
  final controller = Get.put(DarkModeController());

  DarkModeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.light_mode_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        // fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-MEDIUM',
                        fontFamily: 'EN-REGULAR',
                        fontSize: context.isPhone ? 16 : 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                GetBuilder<DarkModeController>(
                  builder: (_) {
                    return Switch.adaptive(
                      onChanged: (darkValue) {
                        controller.darkToggle(darkValue);
                        ThemeService().changeTheme();
                      },
                      value: controller.darkStatus,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
