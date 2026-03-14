import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class RemoveLockScreen extends StatefulWidget {
  const RemoveLockScreen({super.key});

  @override
  State<RemoveLockScreen> createState() => _RemoveLockScreenState();
}

class _RemoveLockScreenState extends State<RemoveLockScreen> {
  // Find or Put controller
  final LockController _lockController = Get.isRegistered<LockController>() ? Get.find<LockController>() : Get.put(LockController());

  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureConfirm = true;
  String? storedQuestion;

  @override
  void initState() {
    super.initState();
    // Load question for the UI
    storedQuestion = _lockController.settingsBox.get('security_question');
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _confirmPassController.dispose();
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
              // Final check: if user clicks "Confirm" but password doesn't exist
              String? storedPass = _lockController.settingsBox.get('master_password');
              if (storedPass == null) {
                Get.snackbar("Notice", "No password exists to remove.", backgroundColor: Colors.blue, colorText: Colors.white);
                return;
              }

              _lockController.handleRemoveAllLock(
                currentInput: _currentPassController.text.trim(),
                confirmPass: _confirmPassController.text.trim(),
                userAnswer: _answerController.text.trim(),
              );
            },
            child: Text("Confirm", style: TextStyle(color: AppColor().primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_reset_rounded, size: 70, color: Colors.red),
            const SizedBox(height: 10),
            const Text("Security Verification", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Enter credentials to permanently disable the vault.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            customTextField("Current Password", _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent), controller: _currentPassController),
            const SizedBox(height: 15),
            customTextField("Confirm Password", _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), controller: _confirmPassController),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Recovery Question:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(storedQuestion ?? "No question set", style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
            ),
            const SizedBox(height: 15),
            buildStandardField("Answer", controller: _answerController),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
