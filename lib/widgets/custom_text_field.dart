import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

Widget customTextField(
  String hint,
  bool obscure,
  VoidCallback? toggle, {
  TextEditingController? controller,
  String? Function(String?)? validator,
  Widget? prefixIcon,
  Widget? suffixIcon,
  Function(String)? onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(
        color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
        fontSize: 16,
        fontFamily: 'EN-REGULAR',
        fontFamilyFallback: const ['KH-REGULAR'],
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColor().gray,
          fontSize: 16,
          fontFamily: 'EN-REGULAR',
          fontFamilyFallback: const ['KH-REGULAR'],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: InputBorder.none,
        prefixIcon: prefixIcon,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        suffixStyle: TextStyle(
          color: AppColor().gray,
          fontSize: 14,
          fontFamily: 'EN-REGULAR',
          fontFamilyFallback: const ['KH-REGULAR'],
        ),
        suffixIcon: suffixIcon ??
            (toggle != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColor().gray,
                    ),
                    onPressed: toggle,
                  )
                : null),
      ),
    ),
  );
}

Widget buildStandardField(
  String hint, {
  String? trailing,
  TextEditingController? controller,
  IconData? prefixIcon,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: controller,
      style: TextStyle(
        color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
        fontSize: 16,
        fontFamily: 'EN-REGULAR',
        fontFamilyFallback: const ['KH-REGULAR'],
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColor().gray,
          fontSize: 16,
          fontFamily: 'EN-REGULAR',
          fontFamilyFallback: const ['KH-REGULAR'],
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0XFF8E8E93)) : null,
        suffixText: trailing,
        suffixStyle: TextStyle(
          color: AppColor().gray,
          fontSize: 14,
          fontFamily: 'EN-REGULAR',
          fontFamilyFallback: const ['KH-REGULAR'],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}
