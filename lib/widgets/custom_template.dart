import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class CustomTemplate extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomTemplate({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = AppColor().primaryColor;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: isDark ? 0.15 : 0.05) : (isDark ? Colors.grey[900] : AppColor().white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColor().primaryColor : AppColor().gray.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.isPhone ? 30 : 40,
              color: isSelected ? AppColor().primaryColor : AppColor().gray,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: text16(context).copyWith(
                color: isSelected ? AppColor().primaryColor : AppColor().gray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
