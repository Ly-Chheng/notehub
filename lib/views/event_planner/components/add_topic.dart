import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/event_planner/event_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/widgets/app_snack_bar.dart';
import 'package:project_structure/widgets/custom_button.dart';
import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/confirm_bottomsheet.dart';

void addTopic(
  BuildContext context,
  int eventId,
  VoidCallback onTopicSaved, {
  RevisionTopic? topicToEdit,
}) {
  final EventPlannerController controller = EventPlannerController();
  final nameController = TextEditingController();
  final bool isEditing = topicToEdit != null;

  if (isEditing) {
    nameController.text = topicToEdit.name;
  }

  ConfirmBottomSheet.show(
    context: context,
    title: isEditing ? "edit".tr : "add_topic".tr,
    confirmText: isEditing ? "save".tr : "add_topic".tr,
    showTopCancel: true,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        customTextField(
          "topic_name".tr,
          false,
          null,
          controller: nameController,
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: isEditing ? "save".tr : "add_topic".tr,
          backgroundColor: AppColor().primaryColor,
          onPressed: () async {
            final textVal = nameController.text.trim();

            if (textVal.isNotEmpty) {
              Navigator.pop(context);

              if (isEditing) {
                await controller.updateTopicName(topicToEdit.id!, textVal);
              } else {
                await controller.createTopic(RevisionTopic(
                  examId: eventId,
                  name: textVal,
                  notes: '',
                  priority: '',
                  dueDate: '',
                ));
              }

              onTopicSaved();
              nameController.dispose();
            } else {
              AppSnackbar.showError(
                title: "Error",
                message: "Please fill out the Topic Name",
              );
            }
          },
        ),
      ],
    ),
  );
}
