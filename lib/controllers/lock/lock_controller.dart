import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/widgets/custom_dialog.dart';

class LockController extends GetxController {
  final Box settingsBox = Hive.box('settings_box');

  Future<void> _showDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showConfirmDialog(
      context: context,
      title: title,
      subTitle: message,
      confirmText: "OK",
      onConfirm: () {},
    );
  }

  Future<void> handleChangePassword({
    required BuildContext context,
    required String currentInput,
    required String newPass,
    required String confirmPass,
    required String hint,
    required String? question,
    required String answer,
  }) async {
    String? storedPass = settingsBox.get('master_password');

    if (storedPass == null || storedPass.isEmpty) {
      await _showDialog(
        context,
        title: "Error",
        message: "No password found. Please create one first.",
      );
      return;
    }

    if (currentInput.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      await _showDialog(
        context,
        title: "Error",
        message: "Please fill all password fields",
      );
      return;
    }

    if (currentInput != storedPass) {
      await _showDialog(
        context,
        title: "Error",
        message: "Current password is incorrect",
      );
      return;
    }

    if (newPass != confirmPass) {
      await _showDialog(
        context,
        title: "Error",
        message: "New passwords do not match",
      );
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

  Future<void> handleCreatePassword({
    required BuildContext context,
    required String password,
    required String confirmPassword,
    required String? question,
    required String answer,
    required String hint,
  }) async {
    if (password.isEmpty || question == null || answer.isEmpty) {
      await _showDialog(
        context,
        title: "Error",
        message: "Please fill all required fields",
      );
      return;
    }

    if (password != confirmPassword) {
      await _showDialog(
        context,
        title: "Error",
        message: "Passwords do not match",
      );
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
    required BuildContext context,
    required String userAnswer,
    required String? storedAnswer,
  }) async {
    if (storedAnswer == null || storedAnswer.isEmpty) {
      await _showDialog(
        context,
        title: "Error",
        message: "No password found. Please set one first.",
      );

      return;
    }

    if (userAnswer.isEmpty) {
      await _showDialog(
        context,
        title: "Error",
        message: "Please enter your recovery answer",
      );
      return;
    }

    if (userAnswer.trim().toLowerCase() == storedAnswer.toLowerCase()) {
      _showSuccess("Identity Verified");

      Get.off(() => const CreatePasswordScreen());
    } else {
      await _showDialog(
        context,
        title: "Error",
        message: "Incorrect answer. Try again.",
      );
    }
  }

  Future<void> handleRemoveAllLock({
    required BuildContext context,
    required String currentInput,
    required String confirmPass,
    required String userAnswer,
  }) async {
    String? storedPass = settingsBox.get('master_password');
    final Box noteBox = Hive.box('student_notes');

    if (storedPass == null || storedPass.isEmpty) {
      await _showDialog(
        context,
        title: "Error",
        message: "No password exists to remove.",
      );
      return;
    }

    if (currentInput.isEmpty || confirmPass.isEmpty) {
      await _showDialog(
        context,
        title: "Error",
        message: "Please enter password in both fields",
      );
      return;
    }

    if (currentInput != storedPass) {
      await _showDialog(
        context,
        title: "Error",
        message: "Current password is incorrect",
      );
      return;
    }

    if (currentInput != confirmPass) {
      await _showDialog(
        context,
        title: "Error",
        message: "Confirmation password does not match",
      );
      return;
    }

    try {
      int unlockCount = 0;
      for (var key in noteBox.keys) {
        final note = noteBox.get(key);
        if (note != null && (note['isLocked'] ?? false)) {
          final updatedNote = Map<String, dynamic>.from(note);
          updatedNote['isLocked'] = false;
          await noteBox.put(key, updatedNote);
          unlockCount++;
        }
      }

      await settingsBox.delete('master_password');
      await settingsBox.delete('security_question');
      await settingsBox.delete('security_answer');
      await settingsBox.delete('password_hint');

      Get.back();
      _showSuccess(unlockCount > 0 ? "Locks removed and $unlockCount notes unlocked." : "All security locks removed.");
      update();
    } catch (e) {
      _showError("Failed to complete removal process");
    }
  }

  void _showError(String message) {
    Get.snackbar("Error", message, backgroundColor: AppColor().red, colorText: AppColor().white, snackPosition: SnackPosition.TOP);
  }

  void _showSuccess(String message) {
    Get.snackbar("Success", message, backgroundColor: AppColor().green, colorText: AppColor().white, snackPosition: SnackPosition.TOP);
  }
}
