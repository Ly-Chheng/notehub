import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class NoteSearch extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const NoteSearch({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
        bottom: 5,
      ),
      child: customTextField(
        "search".tr,
        false,
        null,
        controller: controller,
        onChanged: onChanged,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}