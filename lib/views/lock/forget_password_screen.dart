import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  // Use this logic to ensure the controller is always available
  final LockController _controller = Get.isRegistered<LockController>() ? Get.find<LockController>() : Get.put(LockController());
  final TextEditingController _answerController = TextEditingController();

  String? storedQuestion;
  String? storedAnswer;
  bool hasSecuritySetup = false;

  @override
  void initState() {
    super.initState();
    storedAnswer = _controller.settingsBox.get('security_answer');
    storedQuestion = _controller.settingsBox.get('security_question');
    if (storedAnswer != null && storedAnswer!.isNotEmpty) {
      hasSecuritySetup = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Back",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          if (hasSecuritySetup)
            TextButton(
              onPressed: () => _controller.handleForgetPasswordVerify(
                userAnswer: _answerController.text,
                storedAnswer: storedAnswer,
              ),
              child: Text("Submit", style: TextStyle(color: AppColor().primaryColor, fontSize: 18)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: hasSecuritySetup ? _buildQuestionUI() : _buildNoDataUI(),
      ),
    );
  }

  Widget _buildQuestionUI() {
    return Column(
      children: [
        Text("Forget Password", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(
          "Please answer your security question to verify your identity.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'EN-REGULAR', height: 1.4),
        ),
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(storedQuestion ?? "", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 15),
        buildStandardField("Enter your answer", controller: _answerController),
      ],
    );
  }

  Widget _buildNoDataUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_reset, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text("No Security Question Found", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }
}
