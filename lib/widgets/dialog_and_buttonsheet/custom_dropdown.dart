import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class CustomDropdown extends StatelessWidget {
  final String? selectedValue;
  final Map<String, String> itemsMap;
  final Function(String) onChanged;
  final String hint;

  const CustomDropdown({
    super.key,
    required this.selectedValue,
    required this.itemsMap,
    required this.onChanged,
    this.hint = "Select option",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(hint, style: text16(context).copyWith(color: AppColor().gray)),
              dropdownColor: Theme.of(context).cardColor,
              isExpanded: true,
              items: itemsMap.keys.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name, style: text16(context)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

PopupMenuItem<String> buildPopupItem(BuildContext context, String title, IconData icon, {Color? color}) {
  return PopupMenuItem<String>(
    value: title,
    child: Row(
      children: [
        Icon(
          icon,
          size: context.isPhone ? 20 : 25,
          color: color ?? Theme.of(context).iconTheme.color,
        ),
        SizedBox(width: context.isPhone ? 20 : 25),
        Text(
          title.tr,
          style: text14(context).copyWith(
            color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    ),
  );
}