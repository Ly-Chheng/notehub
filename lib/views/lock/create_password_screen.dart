import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
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

  final List<String> _questions = [
    "What was the name of your first school?",
    "What is your mother's maiden name?",
    "In which city were you born?",
  ];

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
            onPressed: () => _controller.handleCreatePassword(
              password: _newPassController.text,
              confirmPassword: _confirmPassController.text,
              question: _selectedQuestion,
              answer: _answerController.text,
              hint: _hintController.text,
            ),
            child: Text("Create", style: TextStyle(fontSize: 18, color: AppColor().primaryColor, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Setup Lock", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(
              "Create a secure password to protect your personal notes.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontFamily: 'EN-REGULAR',
              ),
            ),
            const SizedBox(height: 30),
            customTextField("New Password", _obscureNew, () => setState(() => _obscureNew = !_obscureNew), controller: _newPassController),
            const SizedBox(height: 15),
            customTextField("Confirm Password", _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), controller: _confirmPassController),
            const SizedBox(height: 15),
            buildStandardField("Hint (Optional)", controller: _hintController),
            const SizedBox(height: 30),
            _buildDropdown(),
            const SizedBox(height: 15),
            buildStandardField("Security Answer", controller: _answerController),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Security Question Verification", style: TextStyle(fontSize: context.isPhone ? 16 : 18, fontFamily: 'EN-REGULAR')),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedQuestion,
              dropdownColor: Colors.white,
              hint: Text("Select Security Question", style: TextStyle(color: Colors.grey, fontSize: context.isPhone ? 14 : 18, fontFamily: 'EN-REGULAR')),
              isExpanded: true,
              items: _questions
                  .map((q) => DropdownMenuItem(
                      value: q,
                      child: Text(q,
                          style: TextStyle(
                            fontSize: context.isPhone ? 16 : 18,
                            fontFamily: 'EN-REGULAR',
                            color: Colors.black,
                          ))))
                  .toList(),
              onChanged: (val) => setState(() => _selectedQuestion = val),
            ),
          ),
        ),
      ],
    );
  }
}
