import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

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
            width: 40,
            height: 4,
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
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
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
                    fontSize: 16,
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
