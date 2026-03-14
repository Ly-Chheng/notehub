import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';

class LockController extends GetxController {
  final Box settingsBox = Hive.box('settings_box');

  Future<void> handleChangePassword({
    required String currentInput,
    required String newPass,
    required String confirmPass,
    required String hint,
    required String? question,
    required String answer,
  }) async {
    String? storedPass = settingsBox.get('master_password');

    // If user never created a password
    if (storedPass == null || storedPass.isEmpty) {
      _showError("No password found. Please create a password first.");
      return;
    }

    if (currentInput.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showError("Please fill in all password fields");
      return;
    }

    if (currentInput != storedPass) {
      _showError("Current password is incorrect");
      return;
    }

    if (newPass != confirmPass) {
      _showError("New passwords do not match");
      return;
    }

    try {
      await settingsBox.put('master_password', newPass);
      await settingsBox.put('password_hint', hint);
      if (question != null && answer.isNotEmpty) {
        await settingsBox.put('security_question', question);
        await settingsBox.put('security_answer', answer.trim().toLowerCase());
      }
      Get.back();
      _showSuccess("Password changed successfully");
    } catch (e) {
      _showError("Update failed");
    }
  }

  /// HANDLE CREATE / UPDATE SECURITY SETUP
  Future<void> handleCreatePassword({
    required String password,
    required String confirmPassword,
    required String? question,
    required String answer,
    required String hint,
  }) async {
    if (password.isEmpty || question == null || answer.isEmpty) {
      _showError("Please fill all required fields");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match");
      return;
    }

    try {
      await settingsBox.put('master_password', password);
      await settingsBox.put('security_question', question);
      await settingsBox.put('security_answer', answer.trim().toLowerCase());
      await settingsBox.put('hint', hint);

      Get.back(result: true);
      _showSuccess("Security Settings Saved");
    } catch (e) {
      _showError("Failed to save settings");
    }
  }

  void handleForgetPasswordVerify({
    required String userAnswer,
    required String? storedAnswer,
  }) {
    if (userAnswer.isEmpty) {
      _showError("Please enter your answer");
      return;
    }

    if (storedAnswer == null) {
      _showError("Recovery data missing on this device");
      return;
    }

    if (userAnswer.trim().toLowerCase() == storedAnswer.toLowerCase()) {
      _showSuccess("Identity Verified");
      // Use off to prevent going back to the answer screen
      Get.off(() => const CreatePasswordScreen());
    } else {
      _showError("Incorrect answer. Try again.");
    }
  }

  Future<void> handleRemoveAllLock({
    required String currentInput,
    required String confirmPass,
    required String userAnswer,
  }) async {
    String? storedPass = settingsBox.get('master_password');
    String? storedAnswer = settingsBox.get('security_answer');

    // Check if password exists in database at all
    if (storedPass == null || storedPass.isEmpty) {
      _showError("No password exists to remove.");
      return;
    }

    if (currentInput.isEmpty || confirmPass.isEmpty || userAnswer.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    //Confirm Input Match (Typo protection)
    if (currentInput != confirmPass) {
      _showError("Confirm password does not match");
      return;
    }

    // Verify against stored Password
    if (currentInput != storedPass) {
      _showError("Current password is wrong");
      return; // STOPS HERE (Prevents 'Success' message)
    }

    // Verify against stored Security Answer
    if (storedAnswer != null && userAnswer.toLowerCase() != storedAnswer.toLowerCase()) {
      _showError("Security answer is incorrect");
      return;
    }

    // SUCCESS: If code reaches here, all data is correct
    try {
      await settingsBox.delete('master_password');
      await settingsBox.delete('security_question');
      await settingsBox.delete('security_answer');
      await settingsBox.delete('password_hint');

      Get.back();
      _showSuccess("All locks removed successfully");
      update();
    } catch (e) {
      _showError("Failed to delete security data");
    }
  }

  ///   UTILS
  void _showError(String message) {
    Get.snackbar("Error", message, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  void _showSuccess(String message) {
    Get.snackbar("Success", message, backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }
}
