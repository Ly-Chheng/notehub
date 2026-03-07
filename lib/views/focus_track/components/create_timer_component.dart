import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class CreateTimerScreen extends StatefulWidget {
  final bool isEditing;
  final dynamic timerKey;
  final Map? existingTimer;

  const CreateTimerScreen({super.key, this.isEditing = false, this.timerKey, this.existingTimer});

  @override
  State<CreateTimerScreen> createState() => _CreateTimerScreenState();
}

class _CreateTimerScreenState extends State<CreateTimerScreen> {
  late int selectedHours;
  late int selectedMinutes;
  late int selectedSeconds;
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    // Pre-fill data if editing, otherwise default to 0
    if (widget.isEditing && widget.existingTimer != null) {
      int total = widget.existingTimer!['totalSeconds'];
      selectedHours = total ~/ 3600;
      selectedMinutes = (total % 3600) ~/ 60;
      selectedSeconds = total % 60;
      _labelController = TextEditingController(text: widget.existingTimer!['title']);
    } else {
      selectedHours = 0;
      selectedMinutes = 0;
      selectedSeconds = 0;
      _labelController = TextEditingController(text: "Timer");
    }
  }

  void _saveTimer() async {
    final box = Hive.box('timer_box');
    int totalSec = (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds;

    if (totalSec <= 0) {
      Get.snackbar("Error", "Duration cannot be zero");
      return;
    }

    final timerData = {
      "type": "timer",
      "title": _labelController.text,
      "totalSeconds": totalSec,
      "remainingSeconds": totalSec, // Reset to new total on edit
      "updatedAt": DateTime.now().toIso8601String(),
      // Use existing createdAt if editing, otherwise set new one
      // "createdAt": widget.isEditing ? widget.existingTimer!['createdAt'] : DateTime.now().toIso8601String(),
    };

    if (widget.isEditing) {
      // IMPORTANT: Clear the controller's memory for this specific timer
      final TimerController controller = Get.find<TimerController>();
      controller.resetTimerMemory(widget.timerKey);

      await box.put(widget.timerKey, timerData);
    } else {
      await box.add(timerData);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: widget.isEditing ? "Edit Timer" : "New Timer",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          TextButton(
            onPressed: _saveTimer,
            child: Text("Save",
                style: TextStyle(
                  color: AppColor().primaryColor,
                  fontSize: context.isPhone ? 20 : 22,
                  fontFamily: 'EN-SEMIBOLD',
                )),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPickerSection(),
          SizedBox(height: 30),
          Row(
            children: [
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Label:",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'EN-ENGINEER',
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _labelController,
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickerSection() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          _buildPicker(24, "hours", selectedHours, (v) => setState(() => selectedHours = v)),
          _buildPicker(60, "min", selectedMinutes, (v) => setState(() => selectedMinutes = v)),
          _buildPicker(60, "sec", selectedSeconds, (v) => setState(() => selectedSeconds = v)),
        ],
      ),
    );
  }

  Widget _buildPicker(int count, String unit, int initial, ValueChanged<int> onSelect) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initial),
        itemExtent: 40,
        onSelectedItemChanged: onSelect,
        children: List.generate(count, (i) => Center(child: Text("$i $unit"))),
      ),
    );
  }
}
