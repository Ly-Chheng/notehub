import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

class LabelSettingsWidget extends StatefulWidget {
  final String selectedValue;
  final Map<String, String> itemsMap;
  final Function(String) onChanged;

  const LabelSettingsWidget({
    super.key,
    required this.selectedValue,
    required this.itemsMap,
    required this.onChanged,
  });

  @override
  State<LabelSettingsWidget> createState() => _LabelSettingsWidgetState();
}

class _LabelSettingsWidgetState extends State<LabelSettingsWidget> {
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
              value: widget.selectedValue,
              dropdownColor: Theme.of(context).cardColor,
              isExpanded: true,
              items: widget.itemsMap.keys.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name, style: text14(context)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
