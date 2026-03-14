import 'package:flutter/material.dart';

Widget customTextField(String hint, bool obscure, VoidCallback toggle, {TextEditingController? controller}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
          onPressed: toggle,
        ),
      ),
    ),
  );
}

// STANDARD TEXT FIELD
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontFamily: 'EN-REGULAR',
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0XFF8E8E93)) : null,
        suffixText: trailing,
        suffixStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: InputBorder.none,
      ),
    ),
  );
}
