import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_confirm_bottomsheet.dart';

class TemplateLibrarySheet {
  static Future<void> show(BuildContext context, Function(List<dynamic>) onTemplateSelected) async {
    final String response = await rootBundle.loadString('lib/json/templates.json');
    final List<dynamic> decodedList = json.decode(response);
    final Map<String, dynamic> templates = decodedList[0]['templates'];

    if (!context.mounted) return;

    ConfirmBottomSheet.show(
      context: context,
      title: "choose_template".tr,
      content: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: templates.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final templateName = templates.keys.elementAt(index);
          final icon = _getTemplateIcon(templateName);

          return InkWell(
            onTap: () {
              Navigator.pop(context);

              List<dynamic> selectedTemplate = List<dynamic>.from(templates[templateName]);

              if (templateName == 'Journal') {
                String today = DateTime.now().toString().split(' ')[0];

                selectedTemplate[0]['insert'] = selectedTemplate[0]['insert'].replaceAll('{DATE_PLACEHOLDER}', today);
              }

              onTemplateSelected(selectedTemplate);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColor().primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColor().primaryColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: AppColor().primaryColor),
                  const SizedBox(height: 10),
                  Text(
                    _getTranslationKey(templateName).tr,
                    style: text16(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _getTranslationKey(String title) {
    switch (title) {
      case 'Exam Paper':
        return 'exam_paper';

      case 'Daily Note':
        return 'daily_note';

      case 'Exam Preparation':
        return 'exam_preparation';
      case 'Homework':
        return 'homework';

      case 'Notebook':
        return 'notebook';

      case 'To-Do List':
        return 'to_do_list';

      case 'Work':
        return 'work';

      default:
        return title;
    }
  }

  static IconData _getTemplateIcon(String title) {
    switch (title) {
      case 'Exam Paper':
        return Icons.school;

      case 'Daily Note':
        return Icons.sticky_note_2;

      case 'Exam Preparation':
        return Icons.menu_book;
      case 'Homework':
        return Icons.edit_note;

      case 'Notebook':
        return Icons.assignment;

      case 'To-Do List':
        return Icons.check_circle;

      case 'Work':
        return Icons.work;

      default:
        return Icons.description_outlined;
    }
  }
}
