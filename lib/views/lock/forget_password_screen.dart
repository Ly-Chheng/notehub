import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_header.dart';
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
              if (storedAnswer == null || storedAnswer!.isEmpty) {
                Get.snackbar(
                  "Error",
                  "No password found. Please set a password first.",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }

              //Proceed to verification logic in controller
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Center(child: customHeader("Forget Password")),
            const Text(
              "Verify your identity using your security question to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5, fontFamily: 'EN-REGULAR'),
            ),
            const SizedBox(height: 30),
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
            buildStandardField("Enter your answer", controller: _answerController),
          ],
        ),
      ),
    );
  }
}
