import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dropdown.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final LockController _controller = Get.put(LockController());

  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _hintController = TextEditingController();
  final _answerController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _selectedQuestion;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    _hintController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "create_new_password".tr,
        context: context,
        actions: [
          TextButton(
            onPressed: () {
              _controller.handleCreatePassword(
                password: _newPassController.text,
                confirmPassword: _confirmPassController.text,
                question: _selectedQuestion,
                answer: _answerController.text,
                hint: _hintController.text,
              );
            },
            child: Text(
              "create".tr,
              style: text18(context).copyWith(color: AppColor().white),
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: Layout.padding(),
            child: Column(
              children: [
                // Center(child: customHeader("create_new_password".tr, context)),
                const SizedBox(height: 8),
                Text(
                  "create_password_desc".tr,
                  textAlign: TextAlign.center,
                  style: text16(context).copyWith(
                    color: AppColor().gray,
                  ),
                ),
                const SizedBox(height: 30),
                customTextField(
                  "new_password".tr,
                  _obscureNew,
                  () => setState(() => _obscureNew = !_obscureNew),
                  controller: _newPassController,
                ),
                const SizedBox(height: 15),
                customTextField(
                  "confirm_password".tr,
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                  controller: _confirmPassController,
                ),
                const SizedBox(height: 15),
                customTextField(
                  "hint".tr,
                  false,
                  null,
                  controller: _hintController,
                  trailing: Text("optional".tr, style: text12.copyWith(color: AppColor().gray)),
                ),
                const SizedBox(height: 30),
                _buildDropdown(),
                const SizedBox(height: 15),
                customTextField(
                  "security_answer".tr,
                  false,
                  null,
                  controller: _answerController,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("security_question_verification".tr, style: text16(context)),
        const SizedBox(height: 10),
        CustomDropdown(
          hint: "select_security_question".tr,
          selectedValue: _selectedQuestion,
          itemsMap: {for (var q in _controller.questions) q: q},
          onChanged: (val) => setState(() => _selectedQuestion = val),
        )
      ],
    );
  }
}
