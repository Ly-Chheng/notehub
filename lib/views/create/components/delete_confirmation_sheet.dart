import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_button.dart';
import 'package:project_structure/widgets/sheet_header.dart';

void showDeleteConfirmationSheet(
  BuildContext context,
  VoidCallback onConfirm, {
  required int count,
}) {
  showModalBottomSheet(
    context: context,
    constraints: BoxConstraints(maxWidth: double.infinity),
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(
              title: "",
            ),
            const SizedBox(height: 20),
            Text(
              count == 1 ? "Are you sure you want to delete this note?" : "Are you sure you want to delete selected notes?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.isPhone ? 16 : 18,
                fontFamily: 'EN-REGULAR',
              ),
            ),
            const SizedBox(height: 25),
            CustomButton(
              text: "Delete",
              backgroundColor: AppColor().red,
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
