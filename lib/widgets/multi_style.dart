import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class SheetHeader extends StatelessWidget {
  final String title;
  final String saveText;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  const SheetHeader({
    super.key,
    required this.title,
    this.saveText = "",
    this.onCancel,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          Container(
            width: context.isPhone ? 40 : 50,
            height: context.isPhone ? 4 : 8,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onCancel ?? () => Get.back(),
                child: Text(
                  "cancel".tr,
                  style: TextStyle(
                    color: AppColor().red,
                    // fontFamily: 'EN-ENGINEER',
                    fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
                    fontSize: context.isPhone ? 16 : 18,
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: context.isPhone ? 18 : 20,
                  // fontFamily: 'EN-BOLD',
                  fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-BOLD' : 'EN-BOLD',
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextButton(
                onPressed: onSave,
                child: Text(
                  saveText,
                  style: TextStyle(
                    color: AppColor().primaryColor,
                    // fontFamily: 'EN-ENGINEER',
                    fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
                    fontSize: context.isPhone ? 16 : 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget divider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(
      height: 1,
      color: Colors.grey.withValues(alpha: 0.08),
    ),
  );
}

Widget buildActionItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  required Color color,
  bool isDestructive = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppFontSize(context).descriptionLargeSize,
                  fontFamily: rengular,
                  color: isDestructive ? AppColor().red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

PopupMenuItem<String> buildPopupItem(BuildContext context, String title, IconData icon, {Color? color}) {
  return PopupMenuItem<String>(
    value: title,
    child: Row(
      children: [
        Icon(icon, size: context.isPhone ? 20 : 25),
        SizedBox(width: context.isPhone ? 20 : 25),
        Text(
          title,
          style: text14(context),
        ),
      ],
    ),
  );
}
