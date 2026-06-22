import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/services/themes_services.dart';
import 'package:project_structure/controllers/mores/theme_controller.dart';
import 'package:project_structure/widgets/card_and_button/custom_card_setting.dart';

class DarkModeView extends GetView<DarkModeController> {
  @override
  final controller = Get.put(DarkModeController());

  DarkModeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardSetting(
      icon: Icons.light_mode_outlined,
      title: "dark_mode".tr,
      onTap: () {},
      trailing: Switch.adaptive(
        value: controller.darkStatus,
        onChanged: (value) {
          controller.darkToggle(value);
          ThemeService().changeTheme();
        },
      ),
    );
  }
}
