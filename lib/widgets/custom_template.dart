import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class ModeOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeOptionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        // decoration: BoxDecoration(
        //   color: isSelected ? AppColor().primaryColor.withOpacity(0.1) : Colors.white,
        //   borderRadius: BorderRadius.circular(18),
        //   boxShadow: AppDecorations.subtleShadow,
        //   border: Border.all(
        //     color: isSelected
        //         ? AppColor().primaryColor
        //         : AppColor().gray.withOpacity(0.1),
        //     width: 1,
        //   ),
        // ),
        decoration: BoxDecoration(
          color: AppColor().primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor().primaryColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              // color: isSelected ? AppColor().primaryColor : AppColor().gray,
              color: AppColor().primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: text16(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
