import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // 1. Initialize Controllers
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  // Visibility states
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _selectedQuestion;

  final List<String> _questions = [
    "What was the name of your first school?",
    "What is your mother's maiden name?",
    "In which city were you born?",
  ];

  // 2. Cleanup
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
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, size: 18, color: AppColor().primaryColor),
          label: Text("Back", style: TextStyle(color: AppColor().primaryColor, fontSize: 16)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 3. Simple Validation Example
              if (_newPassController.text != _confirmPassController.text) {
                Get.snackbar("Error", "New passwords do not match", snackPosition: SnackPosition.BOTTOM);
              } else {
                // Success logic
                Get.back();
              }
            },
            child: Text("Save", style: TextStyle(color: AppColor().primaryColor, fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      // appBar: customAppBar(
      //   title: "Back",
      //   titleColor: AppColor().primaryColor,
      //   context: context,
      //   leadingColor: AppColor().primaryColor,
      //   actions: [
      //     TextButton(
      //       onPressed: () {
      //         // 3. Simple Validation Example
      //         if (_newPassController.text != _confirmPassController.text) {
      //           Get.snackbar("Error", "New passwords do not match", snackPosition: SnackPosition.BOTTOM);
      //         } else {
      //           // Success logic
      //           Get.back();
      //         }
      //       },
      //       child:  Text("Save", style: TextStyle(color: AppColor().primaryColor, fontSize: 16, fontWeight: FontWeight.w500)),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text("Change Password", style: TextStyle(fontSize: context.isPhone ? 18 : 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Update the password to protect your notes.",
                style: TextStyle(
                  fontSize: context.isPhone ? 15 : 17,
                )),
            const SizedBox(height: 30),

            // Password Fields with Controllers passed to your reusable widget
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

            // Standard Fields with Controllers
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

  // Header and Dropdown UI helpers
  Widget _buildSecurityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Security Question Verification", style: TextStyle(fontSize: context.isPhone ? 15 : 17, fontWeight: FontWeight.bold)),
        const Text("Optional", style: TextStyle(color: Colors.grey, fontSize: 14)),
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
          hint: const Text("Select question", style: TextStyle(color: Colors.grey, fontSize: 15)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _questions.map((String q) {
            return DropdownMenuItem(value: q, child: Text(q, style: const TextStyle(fontSize: 15)));
          }).toList(),
          onChanged: (val) => setState(() => _selectedQuestion = val),
        ),
      ),
    );
  }
}
