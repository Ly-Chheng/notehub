import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/event_planner/event_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/widgets/custom_button.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_date_picker.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/custom_time_picker.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/confirm_bottomsheet.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? event;
  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final EventPlannerController _controller = Get.put(EventPlannerController());

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _iconController = TextEditingController();

  // Event Date & Time States
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Distinct Reminder Date & Time States
  DateTime _reminderDate = DateTime.now();
  TimeOfDay _reminderTime = TimeOfDay.now();

  int selectedColorIndex = 0;
  bool get _isEditing => widget.event != null;

  final List<Color> eventColors = [
    const Color(0xFF4CAF50),
    const Color(0xFF3B82F6),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    const Color(0xFFF97316),
    const Color(0xFFEF4444),
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (_isEditing) {
      final event = widget.event!;
      _titleController.text = event.title;
      _locationController.text = event.location == "Not Specified".tr ? "" : event.location;

      _iconController.text = event.icon ?? "";

      if (event.color != null) {
        final index = eventColors.indexWhere((c) => c.value == event.color);
        if (index != -1) selectedColorIndex = index;
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      // Safe date parsing for event
      try {
        final parsedDate = DateTime.parse(event.date);
        _selectedDate = parsedDate.isBefore(todayStart) ? todayStart : parsedDate;
      } catch (e) {
        _selectedDate = todayStart;
      }

      try {
        _selectedTime = _parseTimeOfDay(event.time);
      } catch (e) {
        _selectedTime = TimeOfDay.now();
      }

      // Safe date parsing for reminder (Clamped between today and event date)
      try {
        final parsedReminder = event.reminderDate != null ? DateTime.parse(event.reminderDate!) : todayStart;
        if (parsedReminder.isBefore(todayStart)) {
          _reminderDate = todayStart;
        } else if (parsedReminder.isAfter(_selectedDate)) {
          _reminderDate = _selectedDate;
        } else {
          _reminderDate = parsedReminder;
        }
      } catch (e) {
        _reminderDate = todayStart;
      }

      try {
        _reminderTime = event.reminderTimer != null ? _parseTimeOfDay(event.reminderTimer!) : TimeOfDay.now();
      } catch (e) {
        _reminderTime = TimeOfDay.now();
      }
    }
  }

  void _pickCustomColor() {
    Color tempColor = eventColors[selectedColorIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('pick_a_color'.tr, style: text18(context)),
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('apply'.tr, style: text16(context)),
                  onPressed: () {
                    setState(() {
                      int existingIndex = eventColors.indexWhere((c) => c.value == tempColor.value);
                      if (existingIndex != -1) {
                        selectedColorIndex = existingIndex;
                      } else {
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
    ConfirmBottomSheet.show(
      context: context,
      isFloating: true,
      title: "icon".tr,
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
            itemCount: _controller.availableIcons.length,
            itemBuilder: (context, index) {
              final item = _controller.availableIcons[index];
              final isSelected = _iconController.text == item['name'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _iconController.text = item['name'];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? eventColors[selectedColorIndex].withValues(alpha: 0.15) : AppColor().white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? eventColors[selectedColorIndex] : const Color(0xffE8E8EE),
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    item['image'],
                    fit: BoxFit.contain,
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
            Container(
                decoration: Layout.themedBorderDecoration(context),
                child: customTextField(
                  "event_title".tr,
                  false,
                  null,
                  controller: _titleController,
                  fillColor: Theme.of(context).cardColor,
                )),
            const SizedBox(height: 16),
            Container(
              decoration: Layout.themedBorderDecoration(context),
              child: customTextField(
                "short_description".tr,
                false,
                null,
                maxLines: 3,
                type: TextInputType.multiline,
                controller: _locationController,
                fillColor: Theme.of(context).cardColor,
              ),
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
                      final now = DateTime.now();
                      final todayMidnight = DateTime(now.year, now.month, now.day);

                      final DateTime? picked = await customDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: todayMidnight,
                        lastDate: DateTime(2035),
                      );

                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          if (_reminderDate.isAfter(_selectedDate)) {
                            _reminderDate = _selectedDate;
                          }
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      decoration: Layout.themedBorderDecoration(context),
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
                      final TimeOfDay? picked = await customTimePicker(
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
                      decoration: Layout.themedBorderDecoration(context),
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
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(Get.context!).brightness == Brightness.dark ? const Color(0xff3A3A3C) : const Color(0xffE8E8EE),
                  ),
                ),
                child: IgnorePointer(
                  child: customTextField(
                    "icon".tr,
                    false,
                    null,
                    fillColor: Theme.of(context).cardColor,
                    // controller: _iconController,
                    controller: TextEditingController(),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _iconController.text.isNotEmpty
                          ? Image.asset(
                              'assets/images/${_iconController.text}.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            )
                          : Icon(Icons.category, color: AppColor().gray),
                    ),
                  ),
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
                  decoration: Layout.themedBorderDecoration(context),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
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
                                  boxShadow: selected ? [BoxShadow(color: eventColors[index].withValues(alpha: 0.4), blurRadius: 8)] : [],
                                ),
                                child: selected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: _pickCustomColor,
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(Get.context!).brightness == Brightness.dark ? const Color(0xff3A3A3C) : const Color(0xffE8E8EE),
                              ),
                            ),
                            child: Icon(Icons.add, size: 18, color: AppColor().gray),
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
              "reminder".tr,
              style: text16(context).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final todayStart = DateTime(now.year, now.month, now.day);

                      DateTime verifiedInitial = _reminderDate;
                      if (verifiedInitial.isBefore(todayStart)) {
                        verifiedInitial = todayStart;
                      } else if (verifiedInitial.isAfter(_selectedDate)) {
                        verifiedInitial = _selectedDate;
                      }

                      final DateTime? picked = await customDatePicker(
                        context: context,
                        initialDate: verifiedInitial,
                        firstDate: todayStart, //Cannot select before today
                        lastDate: _selectedDate, //Cannot select after event date
                      );
                      if (picked != null) {
                        setState(() => _reminderDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      decoration: Layout.themedBorderDecoration(context),
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
                      final TimeOfDay? picked = await customTimePicker(
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
                      decoration: Layout.themedBorderDecoration(context),
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
                    id: widget.event?.id,
                    title: _titleController.text.trim(),
                    date: dateString,
                    time: timeString,
                    location: _locationController.text.trim().isEmpty ? "not_specified".tr : _locationController.text.trim(),
                    reminderTime: "$reminderDateString $reminderTimeString", // safely constructed fallback string
                    isCompleted: widget.event?.isCompleted ?? false,
                    color: eventColors[selectedColorIndex].value,
                    icon: _iconController.text.trim(),
                    reminderDate: reminderDateString,
                    reminderTimer: reminderTimeString,
                  );

                  if (_isEditing) {
                    await _controller.updateEvent(examData);
                  } else {
                    await _controller.createEvent(examData);
                  }

                  Get.back(result: true);
                } else {
                  showConfirmDialog(
                    context: context,
                    title: "error".tr,
                    subTitle: "please_provide_exam_title".tr,
                    confirmText: "ok".tr,
                    onConfirm: () {},
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
