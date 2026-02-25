import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  // 1. Initialize Controllers in State
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _hintController = TextEditingController();
  final _answerController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _selectedQuestion;

  final List<String> _questions = [
    "What was the name of your first school?",
    "What is your mother's maiden name?",
    "In which city were you born?",
  ];

  // 2. Dispose them to free up memory
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
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: customAppBar(
        title: "Folder",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().black,
        actions: [
          TextButton(
            onPressed: () {
              // Handle logic (e.g., validation) before going back
              if (_newPassController.text == _confirmPassController.text) {
                Get.back();
              } else {
                Get.snackbar("Error", "Passwords do not match");
              }
            },
            child:   Text("Create", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColor().primaryColor)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text("Create Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            const Center(
              child: Text(
                "Create a secure password to protect your personal notes.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),

            // 3. Use customTextField for Passwords
            customTextField(
              "New Password",
              _obscureNew,
              () => setState(() => _obscureNew = !_obscureNew),
              controller: _newPassController,
            ),
            const SizedBox(height: 15),
            customTextField(
              "Confirm Password",
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
              controller: _confirmPassController,
            ),
            const SizedBox(height: 15),

            // 4. Use buildStandardField for Hint
            buildStandardField(
              "Hint", 
              trailing: "Optional", 
              controller: _hintController
            ),

            const SizedBox(height: 30),
            const Text("Security Question Verification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Security Question Dropdown
            _buildDropdown(),

            const SizedBox(height: 15),

            // 5. Use buildStandardField for Answer
            buildStandardField(
              "Enter your answer", 
              controller: _answerController
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
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