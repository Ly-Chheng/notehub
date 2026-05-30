import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
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
        title: "",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
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
              "Create",
              style: text18(context).copyWith(color: AppColor().primaryColor),
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                Center(child: customHeader("Create New Password", context)),
                const SizedBox(height: 8),
                Text(
                  "Create a secure password to protect your personal notes.",
                  textAlign: TextAlign.center,
                  style: text16(context).copyWith(
                    color: AppColor().gray,
                  ),
                ),
                const SizedBox(height: 30),
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
                customTextField(
                  "Hint",
                  false,
                  null,
                  controller: _hintController,
                  trailing: Text(
                    "Optional",
                    style: TextStyle(
                      color: AppColor().gray,
                      fontSize: AppFontSize(context).normalTextSize,
                      fontFamily: 'EN-REGULAR',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildDropdown(),
                const SizedBox(height: 15),
                customTextField(
                  "Security Answer",
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
        Text("Security Question Verification", style: text16(context)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedQuestion,
              dropdownColor: Theme.of(context).cardColor,
              hint: Text(
                "Select Security Question",
                style: TextStyle(
                  color: AppColor().gray,
                  fontSize: AppFontSize(context).subTitleSize,
                  fontFamily: 'EN-REGULAR',
                ),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColor().gray),
              items: _controller.questions
                  .map((q) => DropdownMenuItem(
                        value: q,
                        child: Text(
                          q,
                          style: TextStyle(
                            fontSize: AppFontSize(context).normalTextSize,
                            fontFamily: 'EN-REGULAR',
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedQuestion = val),
            ),
          ),
        ),
      ],
    );
  }
}
