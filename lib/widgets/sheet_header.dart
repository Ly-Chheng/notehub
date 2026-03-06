import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onCancel;

  const SheetHeader({
    super.key,
    required this.title,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: onCancel ?? () => Get.back(),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'EN-ENGINEER',
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'EN-ENGINEER',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
