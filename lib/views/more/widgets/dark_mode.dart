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
      // color: Theme.of(context).cardColor,
      // clipBehavior: Clip.antiAlias,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(8),
      // ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.light_mode_outlined, color: Colors.black87), // Updated icon
                    const SizedBox(width: 15),
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        // fontFamily: Get.locale == const Locale('km', 'KM')
                        //     ? 'KH-REGULAR'
                        //     : 'EN-REGULAR',
                        fontWeight: FontWeight.w500,
                        fontSize: context.isPhone ? 16 : 18,
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
            // const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFEEEEEE)),
          ],
        ),
      ),
    );
  }
}
