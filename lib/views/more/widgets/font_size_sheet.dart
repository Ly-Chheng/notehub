import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showFontSizeSheet(BuildContext context, RxDouble currentFontSize, Function(double) onSelected) {
  double tempValue = currentFontSize.value; // Local state for the slider

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.red))),
                  const Text("Font Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      onSelected(tempValue);
                      Get.back();
                    }, 
                    child: const Text("Done", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Slider
              Slider(
                value: tempValue,
                min: 12,
                max: 30,
                divisions: 4, // Snaps to 5 specific points as per your image
                onChanged: (val) => setSheetState(() => tempValue = val),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ),
  );
}