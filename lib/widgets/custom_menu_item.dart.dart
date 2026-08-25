import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import '../core/utils/app_color.dart';

Widget buildActionItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  required Color color,
  bool isDestructive = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
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
                child: Icon(icon, size: context.isPhone ? 24 : 30, color: color),
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: text16(context).copyWith(
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
