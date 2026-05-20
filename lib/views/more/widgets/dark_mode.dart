import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/services/themes_services.dart';
import 'package:project_structure/controllers/more/theme_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';

class DarkModeView extends GetView<DarkModeController> {
  @override
  final controller = Get.put(DarkModeController());

  DarkModeView({super.key});

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
                        Icons.light_mode_outlined,
                        color: AppColor().primaryColor,
                        size: context.isPhone ? 20 : 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        // fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-MEDIUM',
                        fontFamily: 'EN-REGULAR',
                        fontWeight: FontWeight.w500,
                        fontSize: context.isPhone ? 15 : 17,
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
          ),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Divider(
              height: 1,
              color: AppColor().gray.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
