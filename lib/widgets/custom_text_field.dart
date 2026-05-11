import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

Widget customTextField(
  String hint,
  bool obscure,
  VoidCallback? toggle, {
  TextEditingController? controller,
  String? Function(String?)? validator,
  Widget? prefixIcon,
  Widget? suffixIcon,
  Function(String)? onChanged,
  bool showBorder = false,
  Color? fillColor,
  double? hintFontSize,
  double? fontSize,
  Widget? trailing,
  TextInputType? type,
}) {
  return Container(
    decoration: BoxDecoration(
      color: fillColor ?? Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      onChanged: onChanged,
      keyboardType: type,
      cursorColor: AppColor().primaryColor,
      style: TextStyle(
        color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
        fontSize: AppFontSize(Get.context!).subTitleSize,
        fontFamily: 'EN-REGULAR',
        fontFamilyFallback: const ['KH-REGULAR'],
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColor().gray,
          fontSize: fontSize ?? 16,
          fontFamily: 'EN-REGULAR',
          fontFamilyFallback: const ['KH-REGULAR'],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor().gray),
              )
            : InputBorder.none,
        prefixIcon: prefixIcon,
        prefixIconColor: AppColor().gray,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        suffixStyle: TextStyle(
          color: AppColor().gray,
          fontSize: hintFontSize ?? 14,
          fontFamily: 'EN-REGULAR',
          fontFamilyFallback: const ['KH-REGULAR'],
        ),
        suffixIcon: suffixIcon ??
            (trailing != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      widthFactor: 1,
                      child: trailing,
                    ),
                  )
                : toggle != null
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
