import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final LockController _lockController = Get.put(LockController());

  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for locked notes to display the warning
    final bool hasLockedNotes = Hive.box('student_notes').values.any((n) => n['isLocked'] == true);

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
              _lockController.handleRemoveAllLock(
                currentInput: _currentPassController.text.trim(),
                confirmPass: _confirmPassController.text.trim(),
                userAnswer: "", // Not used in this version
              );
            },
            child: Text("Save", style: TextStyle(color: AppColor().primaryColor, fontSize: 18, fontFamily: 'EN-REGULAR')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // const Text("Security Verification", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Reset Password", style: TextStyle(fontSize: 22, fontFamily: 'EN-BOLD')), //the mean Security Verification
            const Text("Please enter your current password to remove all protection.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'EN-REGULAR')),

            const SizedBox(height: 30),

            if (hasLockedNotes)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open_rounded, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "All currently locked notes will be unlocked and no longer require a password.",
                        style: TextStyle(fontSize: 12, color: Colors.orange, fontFamily: 'EN-REGULAR'),
                      ),
                    ),
                  ],
                ),
              ),

            // The Two Required Password Fields
            customTextField("Current Password", _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent), controller: _currentPassController),
            const SizedBox(height: 15),
            customTextField("Confirm Password", _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), controller: _confirmPassController),
          ],
        ),
      ),
    );
  }
}
