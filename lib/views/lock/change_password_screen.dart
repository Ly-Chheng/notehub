import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dropdown.dart';

import 'package:project_structure/widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final LockController _lockController = Get.put(LockController());

  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _selectedQuestion;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    final settings = await _lockController.getSecuritySettings();
    if (settings != null) {
      setState(() {
        _hintController.text = settings['password_hint'] ?? "";
        if (_lockController.questions.contains(settings['security_question'])) {
          _selectedQuestion = settings['security_question'];
        }
      });
    }
  }

  @override
  void dispose() {
    _currentPassController.dispose();
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
        title: "",
        context: context,
        actions: [
          TextButton(
            onPressed: () {
              _lockController.handleChangePassword(
                currentInput: _currentPassController.text,
                newPass: _newPassController.text,
                confirmPass: _confirmPassController.text,
                hint: _hintController.text,
                question: _selectedQuestion,
                answer: _answerController.text,
              );
            },
            child: Text(
              "save".tr,
              style: text18(context).copyWith(color: AppColor().primaryColor),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: Layout.padding(),
            child: Column(
              children: [
                Center(child: customHeader("change_password".tr, context)),
                const SizedBox(height: 8),
                Text(
                  "change_password_desc".tr,
                  textAlign: TextAlign.center,
                  style: text16(context).copyWith(
                    color: AppColor().gray,
                  ),
                ),
                const SizedBox(height: 30),
                customTextField("current_password".tr, _obscureCurrent, () {
                  setState(() => _obscureCurrent = !_obscureCurrent);
                }, controller: _currentPassController),
                const SizedBox(height: 15),
                customTextField("new_password".tr, _obscureNew, () {
                  setState(() => _obscureNew = !_obscureNew);
                }, controller: _newPassController),
                const SizedBox(height: 15),
                customTextField("confirm_new_password".tr, _obscureConfirm, () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                }, controller: _confirmPassController),
                const SizedBox(height: 15),
                customTextField(
                  "new_hint".tr,
                  false,
                  null,
                  controller: _hintController,
                  trailing: Text("optional".tr, style: text12.copyWith(color: AppColor().gray)),
                ),
                const SizedBox(height: 30),
                _buildSecurityHeader(),
                const SizedBox(height: 12),
                _buildDropdown(),
                const SizedBox(height: 15),
                customTextField(
                  "enter_your_answer".tr,
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

  Widget _buildSecurityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("security_question_verification".tr, style: text16(context)),
        Text(
          "optional".tr,
          style: TextStyle(
            color: AppColor().gray,
            fontSize: AppFontSize(context).normalTextSize,
            fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return CustomDropdown(
      selectedValue: _selectedQuestion,
      hint: "select_question".tr,
      itemsMap: {for (var q in _lockController.questions) q: q},
      onChanged: (val) => setState(() => _selectedQuestion = val),
    );
  }
}
