import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _selectedQuestion;

  final List<String> _questions = [
    "What was the name of your first school?",
    "What is your mother's maiden name?",
    "In which city were you born?",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: customAppBar(
        title: "Folder",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Create", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

            // Password Inputs
            _buildCustomTextField("New Password", isPassword: true, obscure: _obscureNew, onToggle: () => setState(() => _obscureNew = !_obscureNew)),
            const SizedBox(height: 15),
            _buildCustomTextField("Confirm Password", isPassword: true, obscure: _obscureConfirm, onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm)),
            const SizedBox(height: 15),
            _buildCustomTextField("Hint", trailingText: "Optional"),

            const SizedBox(height: 30),
            const Text("Security Question Verification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Security Question Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E9EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedQuestion,
                  hint: const Text("Select question"),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _questions.map((String q) {
                    return DropdownMenuItem(value: q, child: Text(q));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedQuestion = val),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildCustomTextField("Enter your answer"),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField(String hint, {bool isPassword = false, bool? obscure, VoidCallback? onToggle, String? trailingText}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: obscure ?? false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscure! ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                  onPressed: onToggle,
                )
              : (trailingText != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(trailingText, style: const TextStyle(color: Colors.grey)),
                    )
                  : null),
        ),
      ),
    );
  }
}
