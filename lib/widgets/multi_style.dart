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
                  "Cancel",
                  style: TextStyle(
                    color: AppColor().red,
                    fontFamily: 'EN-ENGINEER',
                    fontSize: context.isPhone ? 16 : 18,
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: context.isPhone ? 18 : 20,
                  fontFamily: 'EN-BOLD',
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextButton(
                onPressed: onSave,
                child: Text(
                  saveText,
                  style: TextStyle(
                    color: AppColor().primaryColor,
                    fontFamily: 'EN-ENGINEER',
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
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
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
