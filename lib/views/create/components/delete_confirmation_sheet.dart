import 'package:flutter/material.dart';
import 'package:project_structure/widgets/custom_button.dart';

void showDeleteConfirmationSheet(
  BuildContext context,
  VoidCallback onConfirm,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontFamily: 'EN-REGULAR',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Are you sure you want to delete selected note(s)?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'EN-REGULAR',
              ),
            ),
            const SizedBox(height: 25),
            CustomButton(
              text: "Delete",
              backgroundColor: Colors.red,
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
