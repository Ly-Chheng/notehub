import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class CustomActionSheet {
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isSwitch;
  final RxBool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  CustomActionSheet({
    required this.label,
    this.icon,
    this.color,
    this.onTap,
    this.isSwitch = false,
    this.switchValue,
    this.onSwitchChanged,
  });
}

class ActionSheet {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<CustomActionSheet> actions,
    VoidCallback? onCancel,
  }) {
    return showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          title,
          style: TextStyle(
            color: AppColor().gray,
            fontSize: AppFontSize(context).normalTextSize,
            fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
          ),
        ),
        actions: actions.map((item) {
          if (item.isSwitch && item.switchValue != null) {
            return Obx(() => CupertinoActionSheetAction(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (item.icon != null) ...[
                              Icon(
                                item.icon,
                                color: item.color ?? Theme.of(context).hoverColor,
                                size: context.isPhone ? 20 : 22,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                item.label,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: item.color ?? Theme.of(context).hoverColor,
                                  fontSize: AppFontSize(context).descriptionLargeSize,
                                  fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-BOLD' : 'EN-BOLD',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoSwitch(
                        value: item.switchValue!.value,
                        onChanged: (val) {
                          item.switchValue!.value = val;
                          item.onSwitchChanged?.call(val);
                        },
                        activeTrackColor: AppColor().green,
                      ),
                    ],
                  ),
                ));
          }

          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              item.onTap?.call();
            },
            isDestructiveAction: item.color == AppColor().primaryColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    color: item.color ?? Theme.of(context).hoverColor,
                    size: context.isPhone ? 20 : 22,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    color: item.color ?? Theme.of(context).hoverColor,
                    fontSize: AppFontSize(context).descriptionLargeSize,
                    fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-BOLD' : 'EN-BOLD',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          isDefaultAction: true,
          child: Text(
            'cancel'.tr,
            style: TextStyle(
              color: AppColor().red,
              fontSize: AppFontSize(context).subTitleSize,
              fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-BOLD' : 'EN-BOLD',
            ),
          ),
        ),
      ),
    );
  }
}
