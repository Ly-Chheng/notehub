// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/controllers/exam_planner/exam_controller.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/core/utils/app_fonts.dart';
// import 'package:project_structure/models/exam_planner/exam_model.dart';
// import 'package:project_structure/widgets/card_and_button/custom_button.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';
// import 'package:project_structure/widgets/custom_snack_bar.dart';
// import 'package:project_structure/widgets/custom_text_field.dart';

// class AddExamScreen extends StatefulWidget {
//   const AddExamScreen({Key? key}) : super(key: key);

//   @override
//   _AddExamScreenState createState() => _AddExamScreenState();
// }

// class _AddExamScreenState extends State<AddExamScreen> {
//   final ExamPlannerController _controller = ExamPlannerController();
//   final _titleController = TextEditingController();
//   final _locationController = TextEditingController();

//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   String _reminderStr = '1 day before at 9:00 AM';

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: customAppBar(
//         title: "add_exam".tr,
//         context: context,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             customTextField(
//               "exam_title".tr,
//               false,
//               null,
//               controller: _titleController,
//             ),
//             const SizedBox(height: 16),
//             customTextField(
//               "location".tr,
//               false,
//               null,
//               controller: _locationController,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 // Date Selector Card Box Block
//                 Expanded(
//                   child: InkWell(
//                     onTap: () async {
//                       final DateTime? picked = await showDatePicker(
//                         context: context,
//                         initialDate: _selectedDate,
//                         firstDate: DateTime.now(),
//                         lastDate: DateTime(2030),
//                       );
//                       if (picked != null) {
//                         setState(() => _selectedDate = picked);
//                       }
//                     },
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
//                             style: text16(context),
//                           ),
//                           Icon(
//                             Icons.calendar_today,
//                             color: AppColor().primaryColor,
//                             size: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // Time Selector Card Box Block
//                 Expanded(
//                   child: InkWell(
//                     onTap: () async {
//                       final TimeOfDay? picked = await showTimePicker(
//                         context: context,
//                         initialTime: _selectedTime,
//                       );
//                       if (picked != null) {
//                         setState(() => _selectedTime = picked);
//                       }
//                     },
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(_selectedTime.format(context), style: text16(context)),
//                           Icon(
//                             Icons.access_time,
//                             color: AppColor().primaryColor,
//                             size: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text("Reminder Alert", style: text16(context)),
//             // Reminder Dropdown Container Form Block
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _reminderStr,
//                   isExpanded: true,
//                   items: ['10 minutes before', '1 hour before', '1 day before at 9:00 AM', '2 days before']
//                       .map((val) => DropdownMenuItem(
//                           value: val,
//                           child: Text(
//                             val.tr,
//                             style: text16(context),
//                           )))
//                       .toList(),
//                   onChanged: (val) {
//                     if (val != null) {
//                       setState(() => _reminderStr = val);
//                     }
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40),
//             CustomButton(
//               text: "save".tr,
//               onPressed: () async {
//                 if (_titleController.text.isNotEmpty) {
//                   final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
//                   final timeString = _selectedTime.format(context);

//                   await _controller.createExam(Exam(
//                     title: _titleController.text,
//                     date: dateString,
//                     time: timeString,
//                     location: _locationController.text.isEmpty ? "Not Specified".tr : _locationController.text,
//                     reminderTime: _reminderStr,
//                     isCompleted: false,
//                   ));

//                   Get.back(result: true);
//                 } else {
//                   AppSnackbar.showError(
//                     title: "error".tr,
//                     message: "please_provide_exam_title".tr,
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/exam_planner/exam_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/exam_planner/exam_model.dart';
import 'package:project_structure/widgets/card_and_button/custom_button.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class AddExamScreen extends StatefulWidget {
  final Exam? exam; // Optional parameter: non-null means we are updating
  const AddExamScreen({super.key, this.exam});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final ExamPlannerController _controller = ExamPlannerController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _reminderStr = '1 day before at 9:00 AM';

  bool get _isEditing => widget.exam != null;

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
      _reminderStr = exam.reminderTime;

      // Safe date parsing
      try {
        _selectedDate = DateTime.parse(exam.date);
      } catch (e) {
        _selectedDate = DateTime.now();
      }

      // Safe time parsing (handles standard formatting variations safely)
      try {
        final periods = exam.time.split(" ");
        final parts = periods[0].split(":");
        int hour = int.parse(parts[0]);
        final int minute = int.parse(parts[1]);

        if (periods.length > 1) {
          final marker = periods[1].toLowerCase();
          if (marker == "pm" && hour < 12) hour += 12;
          if (marker == "am" && hour == 12) hour = 0;
        }
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        _selectedTime = TimeOfDay.now();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: _isEditing ? "edit_exam".tr : "add_exam".tr,
        context: context,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customTextField(
              "exam_title".tr,
              false,
              null,
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            customTextField(
              "location".tr,
              false,
              null,
              controller: _locationController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Date Selector
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allows editing older recent items
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
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                            style: text16(context),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: AppColor().primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Time Selector
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
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedTime.format(context), style: text16(context)),
                          Icon(
                            Icons.access_time,
                            color: AppColor().primaryColor,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text("reminder_alert".tr, style: text16(context)),
            const SizedBox(height: 8),
            // Reminder Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _reminderStr,
                  isExpanded: true,
                  items: ['10 minutes before', '1 hour before', '1 day before at 9:00 AM', '2 days before']
                      .map((val) => DropdownMenuItem(
                          value: val,
                          child: Text(
                            val.tr,
                            style: text16(context),
                          )))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _reminderStr = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: "save".tr,
              onPressed: () async {
                if (_titleController.text.trim().isNotEmpty) {
                  final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
                  final timeString = _selectedTime.format(context);

                  final examData = Exam(
                    id: widget.exam?.id, // Keeps original database key unchanged when updating
                    title: _titleController.text.trim(),
                    date: dateString,
                    time: timeString,
                    location: _locationController.text.trim().isEmpty ? "not_specified".tr : _locationController.text.trim(),
                    reminderTime: _reminderStr,
                    isCompleted: widget.exam?.isCompleted ?? false,
                  );

                  if (_isEditing) {
                    await _controller.updateExam(examData);
                  } else {
                    await _controller.createExam(examData);
                  }

                  Get.back(result: true); // Pass 'true' back to root screen so it triggers list updates
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
