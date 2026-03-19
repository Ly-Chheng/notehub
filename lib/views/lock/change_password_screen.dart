import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
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

  final List<String> _questions = [
    "What was the name of your first school?",
    "What is your mother's maiden name?",
    "In which city were you born?",
  ];

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
        title: "Back",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
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
            child: Text("Save",
                style: TextStyle(
                  color: AppColor().primaryColor,
                  fontSize: context.isPhone ? 18 : 20,
                  fontFamily: 'EN-SEMIBOLD',
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          children: [
            Center(child: customHeader("Change Password")),
            Text("Update the password to protect your notes.", textAlign: TextAlign.center, style: TextStyle(fontSize: context.isPhone ? 15 : 17, color: Colors.grey)),
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
            buildStandardField("New Hint", trailing: "Optional", controller: _hintController),
            const SizedBox(height: 30),
            _buildSecurityHeader(),
            const SizedBox(height: 12),
            _buildDropdown(),
            const SizedBox(height: 15),
            buildStandardField("Enter your answer", controller: _answerController),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Security Question Verification",
            style: TextStyle(
              fontSize: context.isPhone ? 16 : 18,
              fontFamily: 'EN-MEDIUM',
            )),
        Text("Optional",
            style: TextStyle(
              color: Colors.grey,
              fontSize: context.isPhone ? 12 : 14,
              fontFamily: 'EN-REGULAR',
            )),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedQuestion,
          dropdownColor: Theme.of(context).cardColor,
          hint: Text("Select question",
              style: TextStyle(
                color: Colors.grey,
                fontSize: context.isPhone ? 14 : 18,
                fontFamily: 'EN-REGULAR',
              )),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _questions.map((String q) {
            return DropdownMenuItem(
                value: q,
                child: Text(q,
                    style: TextStyle(
                      fontSize: context.isPhone ? 16 : 18,
                      fontFamily: 'EN-REGULAR',
                    )));
          }).toList(),
          onChanged: (val) => setState(() => _selectedQuestion = val),
        ),
      ),
    );
  }
}
