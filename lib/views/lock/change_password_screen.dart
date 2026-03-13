import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  final Box settingsBox = Hive.box('settings_box');

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

  // --- CHANGE PASSWORD LOGIC ---
  void _saveNewPassword() async {
    String currentInput = _currentPassController.text.trim();
    String newPass = _newPassController.text.trim();
    String confirmPass = _confirmPassController.text.trim();
    String? storedPass = settingsBox.get('master_password');

    // 1. Basic Validation
    if (currentInput.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar("Error", "Please fill in all password fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 2. Verify Current Password
    if (storedPass != null && currentInput != storedPass) {
      Get.snackbar("Error", "Current password is incorrect", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 3. Match New Passwords
    if (newPass != confirmPass) {
      Get.snackbar("Error", "New passwords do not match", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // // 4. Password Length Check
    // if (newPass.length < 4) {
    //   Get.snackbar("Error", "Password must be at least 4 characters", backgroundColor: Colors.red, colorText: Colors.white);
    //   return;
    // }

    // 5. Save Password & Hint
    await settingsBox.put('master_password', newPass);
    if (_hintController.text.isNotEmpty) {
      await settingsBox.put('password_hint', _hintController.text.trim());
    }

    // 6. Optional: Update Security Question
    if (_selectedQuestion != null && _answerController.text.isNotEmpty) {
      await settingsBox.put('security_question', _selectedQuestion);
      await settingsBox.put('security_answer', _answerController.text.trim().toLowerCase());
    }

    Get.back();
    Get.snackbar("Success", "Password updated successfully", backgroundColor: Colors.green, colorText: Colors.white);
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
            onPressed: _saveNewPassword, // Trigger logic
            child: Text("Save",
                style: TextStyle(
                  color: AppColor().primaryColor,
                  fontSize: context.isPhone ? 20 : 22,
                  fontFamily: 'EN-SEMIBOLD',
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text("Change Password", style: TextStyle(fontSize: context.isPhone ? 18 : 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Update the password to protect your notes.", textAlign: TextAlign.center, style: TextStyle(fontSize: context.isPhone ? 15 : 17)),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Security Question Verification", style: TextStyle(fontSize: context.isPhone ? 16 : 18, fontFamily: 'EN-REGULAR')),
        Text("Optional", style: TextStyle(color: Colors.grey, fontSize: context.isPhone ? 14 : 16, fontFamily: 'EN-REGULAR')),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedQuestion,
          dropdownColor: Colors.white,
          hint: Text("Select question", style: TextStyle(color: Colors.grey, fontSize: context.isPhone ? 14 : 18, fontFamily: 'EN-REGULAR')),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _questions.map((String q) {
            return DropdownMenuItem(
                value: q,
                child: Text(q,
                    style: TextStyle(
                      fontSize: context.isPhone ? 16 : 18,
                      fontFamily: 'EN-REGULAR',
                      color: Colors.black,
                    )));
          }).toList(),
          onChanged: (val) => setState(() => _selectedQuestion = val),
        ),
      ),
    );
  }
}
