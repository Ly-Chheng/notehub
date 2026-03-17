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
  final LockController _controller = Get.put(LockController());

  final TextEditingController _answerController = TextEditingController();

  String? storedQuestion;
  String? storedAnswer;

  @override
  void initState() {
    super.initState();
    // Retrieve values from Hive via the controller
    storedAnswer = _controller.settingsBox.get('security_answer');
    storedQuestion = _controller.settingsBox.get('security_question');
  }

  @override
  void dispose() {
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
              // 1. Guard Check: If no security setup exists
              if (storedAnswer == null || storedAnswer!.isEmpty) {
                Get.snackbar(
                  "Notice",
                  "No password found. Please set a password first.",
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return; // Stop execution
              }

              // 2. Proceed to verification logic in controller
              _controller.handleForgetPasswordVerify(
                userAnswer: _answerController.text.trim(),
                storedAnswer: storedAnswer,
              );
            },
            child: Text("Submit",
                style: TextStyle(
                  color: AppColor().primaryColor,
                  fontSize: 18,
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Text("Forget Password", style: TextStyle(fontSize: 24, fontFamily: 'EN-BOLD')),
            ),

            const Text(
              "Verify your identity using your security question to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5, fontFamily: 'EN-REGULAR'),
            ),
            const SizedBox(height: 30),

            // Question Display
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(storedQuestion ?? "Security setup not found.", style: const TextStyle(fontSize: 16, fontFamily: 'EN-REGULAR')),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Answer Input Field
            buildStandardField("Enter your answer", controller: _answerController),
          ],
        ),
      ),
    );
  }
}
