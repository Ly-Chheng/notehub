import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/mores/font_size_controller.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class FontSizeBottomSheet extends StatelessWidget {
  const FontSizeBottomSheet({super.key});

  double _snapValue(double value) {
    if (value < 0.95) return 0.8;
    if (value < 1.15) return 1.0;
    return 1.2;
  }

  String _getScaleLabel(double value) {
    if (value < 0.95) return "small".tr;
    if (value <= 1.15) return "normal".tr;
    return "large".tr;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FontSizeController>();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.isPhone ? 40 : 50,
              height: context.isPhone ? 4 : 8,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => Text(
                  _getScaleLabel(controller.fontScale.value),
                  style: text18(context),
                )),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "a".tr,
                    style: text14(context),
                  ),
                  Text(
                    "a".tr,
                    style: text16(context),
                  ),
                ],
              ),
            ),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Get.theme.primaryColor,
                          inactiveTrackColor: Get.theme.primaryColor.withValues(alpha: 0.2),
                          thumbColor: Get.theme.primaryColor,
                          trackHeight: 8.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                        ),
                        child: Slider(
                          value: controller.fontScale.value,
                          min: 0.8,
                          max: 1.2,
                          divisions: 2,
                          onChanged: (value) {
                            double snapped = _snapValue(value);
                            if (controller.fontScale.value != snapped) {
                              HapticFeedback.lightImpact();
                            }
                            controller.setFontScale(snapped);
                          },
                        ),
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
