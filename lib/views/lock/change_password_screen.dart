import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_header.dart';
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

  // Optional: Prefill existing hint and question
  void _loadExistingData() async {
    final settings = await _lockController.getSecuritySettings();
    if (settings != null) {
      setState(() {
        _hintController.text = settings['password_hint'] ?? "";
        // Only set question if it matches one in the controller's list
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
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              // Removed 'context: context' as per updated LockController logic
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
              "Save",
              style: text18(context).copyWith(color: AppColor().primaryColor),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                Center(child: customHeader("Change Password", context)),
                const SizedBox(height: 8),
                Text(
                  "Update the password to protect your notes.",
                  textAlign: TextAlign.center,
                  style: text14(context).copyWith(
                    color: AppColor().gray,
                  ),
                ),
                const SizedBox(height: 30),
                customTextField("Current Password", _obscureCurrent, () {
                  setState(() => _obscureCurrent = !_obscureCurrent);
                }, controller: _currentPassController),
                const SizedBox(height: 15),
                customTextField("New Password", _obscureNew, () {
                  setState(() => _obscureNew = !_obscureNew);
                }, controller: _newPassController),
                const SizedBox(height: 15),
                customTextField("Confirm New Password", _obscureConfirm, () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                }, controller: _confirmPassController),
                const SizedBox(height: 15),
                customTextField(
                  "New Hint",
                  false,
                  null,
                  controller: _hintController,
                  trailing: Text(
                    "Optional",
                    style: TextStyle(
                      color: AppColor().gray,
                      fontSize: context.isPhone ? 14 : 16,
                      fontFamily: 'EN-REGULAR',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildSecurityHeader(),
                const SizedBox(height: 12),
                _buildDropdown(),
                const SizedBox(height: 15),
                customTextField(
                  "Enter your answer",
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
        Text("Security Question Verification", style: text16(context)),
        Text(
          "Optional",
          style: TextStyle(
            color: AppColor().gray,
            fontSize: context.isPhone ? 14 : 16,
            fontFamily: 'EN-REGULAR',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedQuestion,
          dropdownColor: Theme.of(context).cardColor,
          hint: Text(
            "Select question",
            style: TextStyle(
              color: AppColor().gray,
              fontSize: context.isPhone ? 14 : 18,
              fontFamily: 'EN-REGULAR',
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColor().gray),
          items: _lockController.questions.map((String q) {
            return DropdownMenuItem(
              value: q,
              child: Text(
                q,
                style: TextStyle(
                  fontSize: context.isPhone ? 16 : 18,
                  fontFamily: 'EN-REGULAR',
                ),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedQuestion = val),
        ),
      ),
    );
  }
}
