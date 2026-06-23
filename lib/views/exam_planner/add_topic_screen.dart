import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/controllers/exam_planner/exam_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/exam_planner/exam_model.dart';
import 'package:project_structure/widgets/card_and_button/custom_button.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class AddTopicScreen extends StatefulWidget {
  final int examId;

  const AddTopicScreen({Key? key, required this.examId}) : super(key: key);

  @override
  _AddTopicScreenState createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final ExamPlannerController _controller = ExamPlannerController();

  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String _priority = "High";
  DateTime _selectedDate = DateTime(2025, 3, 29); // Set defaults as requested

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMM dd, yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "add_revision_topic".tr,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customTextField(
              "topic_name".tr,
              false,
              null,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            const Text("Notes", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: "Study all formulas and practice previous year questions.",
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none),
              ),
            ),
            const SizedBox(height: 16),
            Text("Priority", style: text16(context).copyWith(color: AppColor().gray)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<String>(
                value: _priority,
                isExpanded: true,
                underline: const SizedBox(),
                items: ["High", "Medium", "Low"]
                    .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          p,
                          style: text16(context),
                        )))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
            ),
            const SizedBox(height: 16),
            Text("Due Date", style: text16(context).copyWith(color: AppColor().gray)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(formattedDate, style: text16(context)),
                trailing: Icon(Icons.calendar_today, color: AppColor().primaryColor),
                onTap: () => _selectDate(context),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                text: "add_topic".tr,
                onPressed: () async {
                  if (_nameController.text.isNotEmpty) {
                    int topicId = await _controller.createTopic(RevisionTopic(
                      examId: widget.examId,
                      name: _nameController.text,
                      notes: _notesController.text,
                      priority: _priority,
                      dueDate: formattedDate,
                    ));

                    await _controller.createSubtopic(RevisionSubtopic(
                      topicId: topicId,
                      name: "Basic Properties Structure",
                    ));

                    Get.back();
                  } else {
                    AppSnackbar.showError(
                      title: "Error",
                      message: "Please fill out the Topic Name",
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
