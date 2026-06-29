import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/event_planner/exam_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/event_planner/event_model.dart';

import 'package:project_structure/widgets/card_and_button/custom_button.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? exam;
  const AddEventScreen({super.key, this.exam});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  // Use GetX dependency injection instead of creating a loose instance
  final ExamPlannerController _controller = Get.put(ExamPlannerController());

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _iconController = TextEditingController(); // Added controller for icon representation if needed

  // Event Date & Time States
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Distinct Reminder Date & Time States (Fixed duplicate overwrite issue)
  DateTime _reminderDate = DateTime.now();
  TimeOfDay _reminderTime = TimeOfDay.now();
  String _reminderStr = '1 day before at 9:00 AM';

  int selectedColorIndex = 0;
  bool get _isEditing => widget.exam != null;

  final List<Color> eventColors = [
    const Color(0xFF4CAF50),
    const Color(0xFF3B82F6),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    const Color(0xFFF97316),
    const Color(0xFFEF4444),
    const Color(0xFF374151),
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (_isEditing) {
      final exam = widget.exam!;
      _titleController.text = exam.title;
      _locationController.text = exam.location == "Not Specified".tr ? "" : exam.location;
      _reminderStr = exam.reminderTime ?? '1 day before at 9:00 AM';

      // Match color from historical integer if exists
      if (exam.color != null) {
        final index = eventColors.indexWhere((c) => c.value == exam.color);
        if (index != -1) selectedColorIndex = index;
      }

      // Safe date parsing for event
      try {
        _selectedDate = DateTime.parse(exam.date);
      } catch (e) {
        _selectedDate = DateTime.now();
      }

      // Safe time parsing for event
      try {
        _selectedTime = _parseTimeOfDay(exam.time);
      } catch (e) {
        _selectedTime = TimeOfDay.now();
      }

      // Safe date parsing for reminder
      try {
        _reminderDate = exam.reminderDate != null ? DateTime.parse(exam.reminderDate!) : DateTime.now();
      } catch (e) {
        _reminderDate = DateTime.now();
      }

      // Safe time parsing for reminder
      try {
        _reminderTime = exam.reminderTimer != null ? _parseTimeOfDay(exam.reminderTimer!) : TimeOfDay.now();
      } catch (e) {
        _reminderTime = TimeOfDay.now();
      }
    }
  }

  void _pickCustomColor() {
    // Use the currently selected event color as the starting point inside the picker
    Color tempColor = eventColors[selectedColorIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'pick_a_color'.tr,
            style: text18(context),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text('cancel'.tr, style: text16(context)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('apply'.tr, style: text16(context)),
                  onPressed: () {
                    setState(() {
                      // Check if the picked color already exists in your current options list
                      int existingIndex = eventColors.indexWhere((c) => c.value == tempColor.value);

                      if (existingIndex != -1) {
                        // If it matches an existing color dot, simply switch selection focus to it
                        selectedColorIndex = existingIndex;
                      } else {
                        // Otherwise, append the brand new color onto the palette selection row
                        eventColors.add(tempColor);
                        selectedColorIndex = eventColors.length - 1;
                      }
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    final periods = timeStr.split(" ");
    final parts = periods[0].split(":");
    int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    if (periods.length > 1) {
      final marker = periods[1].toLowerCase();
      if (marker == "pm" && hour < 12) hour += 12;
      if (marker == "am" && hour == 12) hour = 0;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _showIconBottomSheet(BuildContext context) {
    final List<Map<String, dynamic>> availableIcons = [
      {'name': 'school', 'icon': Icons.school},
      {'name': 'book', 'icon': Icons.book},
      {'name': 'assignment', 'icon': Icons.assignment},
      {'name': 'category', 'icon': Icons.category},
      {'name': 'star', 'icon': Icons.star},
      {'name': 'alarm', 'icon': Icons.alarm},
    ];
    ConfirmBottomSheet.show(
      context: context,
      title: "select_icon".tr,
      showTopCancel: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final item = availableIcons[index];
              final isSelected = _iconController.text == item['name'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _iconController.text = item['name'];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? eventColors[selectedColorIndex].withOpacity(0.2) : AppColor().white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? eventColors[selectedColorIndex] : const Color(0xffE8E8EE),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    item['icon'],
                    size: 28,
                    color: isSelected ? eventColors[selectedColorIndex] : AppColor().gray,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: _isEditing ? "edit_event".tr : "add_event".tr,
        context: context,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customTextField(
              "event_title".tr,
              false,
              null,
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            customTextField(
              "short_description".tr,
              false,
              null,
              maxLines: 3,
              type: TextInputType.multiline,
              controller: _locationController,
            ),
            const SizedBox(height: 16),
            Text(
              "event_date_time".tr,
              style: text16(context).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColor().white,
                        border: Border.all(color: const Color(0xffE8E8EE), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(_selectedDate), style: text16(context).copyWith(color: AppColor().gray)),
                          Icon(Icons.date_range, color: AppColor().gray, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColor().white,
                        border: Border.all(color: const Color(0xffE8E8EE), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedTime.format(context), style: text16(context).copyWith(color: AppColor().gray)),
                          Icon(Icons.access_time, color: AppColor().gray, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _showIconBottomSheet(context),
              borderRadius: BorderRadius.circular(12),
              child: IgnorePointer(
                child: customTextField(
                  "icon".tr,
                  false,
                  null,
                  controller: _iconController,
                  suffixIcon: Icon(Icons.category, color: AppColor().gray),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "color_tag".tr,
                  style: text16(context).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffE8E8EE)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Generated default dots
                        ...List.generate(
                          eventColors.length,
                          (index) {
                            final selected = selectedColorIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColorIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 18),
                                width: selected ? 32 : 30,
                                height: selected ? 32 : 30,
                                decoration: BoxDecoration(
                                  color: eventColors[index],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected ? AppColor().gray : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: selected ? [BoxShadow(color: eventColors[index].withOpacity(0.4), blurRadius: 8)] : [],
                                ),
                                child: selected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                              ),
                            );
                          },
                        ),

                        // Interactive Custom Picker Button Dot
                        GestureDetector(
                          onTap: _pickCustomColor,
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xffE8E8EE), width: 1),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: AppColor().gray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "reminder_alert".tr,
              style: text16(context).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _reminderDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _reminderDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColor().white,
                        border: Border.all(color: const Color(0xffE8E8EE), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(_reminderDate), style: text16(context).copyWith(color: AppColor().gray)),
                          Icon(Icons.date_range, color: AppColor().gray, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime,
                      );
                      if (picked != null) {
                        setState(() => _reminderTime = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColor().white,
                        border: Border.all(color: const Color(0xffE8E8EE), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_reminderTime.format(context), style: text16(context).copyWith(color: AppColor().gray)),
                          Icon(Icons.access_time, color: AppColor().gray, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: "save".tr,
              onPressed: () async {
                if (_titleController.text.trim().isNotEmpty) {
                  final dateString = _formatDate(_selectedDate);
                  final timeString = _selectedTime.format(context);
                  final reminderDateString = _formatDate(_reminderDate);
                  final reminderTimeString = _reminderTime.format(context);

                  final examData = EventModel(
                    id: widget.exam?.id,
                    title: _titleController.text.trim(),
                    date: dateString,
                    time: timeString,
                    location: _locationController.text.trim().isEmpty ? "not_specified".tr : _locationController.text.trim(),
                    reminderTime: _reminderStr,
                    isCompleted: widget.exam?.isCompleted ?? false,
                    color: eventColors[selectedColorIndex].value, // Storing as int
                    icon: _iconController.text.trim(),
                    reminderDate: reminderDateString,
                    reminderTimer: reminderTimeString,
                  );

                  if (_isEditing) {
                    await _controller.updateExam(examData);
                  } else {
                    await _controller.createExam(examData);
                  }

                  Get.back(result: true);
                } else {
                  AppSnackbar.showError(
                    title: "error".tr,
                    message: "please_provide_exam_title".tr,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
