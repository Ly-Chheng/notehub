import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/widgets/custom_dialog.dart';

class LockController extends GetxController {
  final List<String> questions = [
    "What was the name of your first school?",
    "What is your mother's maiden name?",
    "In which city were you born?",
  ];

  // Fetch current security settings
  Future<Map<String, dynamic>?> getSecuritySettings() async {
    final db = await DatabaseService.db;
    final List<Map<String, dynamic>> maps = await db.query('security', where: 'id = 1');
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> handleCreatePassword({
    required String password,
    required String confirmPassword,
    required String? question,
    required String answer,
    required String hint,
  }) async {
    if (password.isEmpty || question == null || answer.isEmpty) {
      await _showDialog(
        Get.context!,
        title: "Field Required",
        message: "Please fill in the password, security question, and answer.",
      );
      return;
    }

    if (password != confirmPassword) {
      await _showDialog(
        Get.context!,
        title: "Mismatch",
        message: "Passwords do not match. Please re-type your password.",
      );
      return;
    }

    try {
      final db = await DatabaseService.db;
      await db.update(
          'security',
          {
            'master_password': password,
            'security_question': question,
            'security_answer': answer.trim().toLowerCase(),
            'password_hint': hint,
          },
          where: 'id = 1');

      Get.back(result: true);
      _showSuccess("Security settings saved successfully!");
    } catch (e) {
      await _showDialog(
        Get.context!,
        title: "Database Error",
        message: "We couldn't save your settings. Please try again.",
      );
    }
  }

  Future<void> handleChangePassword({
    required String currentInput,
    required String newPass,
    required String confirmPass,
    required String hint,
    String? question, // Optional
    String? answer, // Optional
  }) async {
    // 1. Fetch current settings from DB
    final settings = await getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (storedPass.isEmpty) {
      await _showDialog(Get.context!, title: "Not Configured", message: "No password found to change. Please create a password first.");
      return;
    }

    if (newPass.isEmpty) {
      await _showDialog(
        Get.context!,
        title: "Input Required",
        message: "New password cannot be empty. Please enter a valid password.",
      );
      return;
    }

    if (currentInput != storedPass) {
      await _showDialog(Get.context!, title: "Verification Failed", message: "The current password you entered is incorrect.");
      return;
    }

    if (newPass != confirmPass) {
      await _showDialog(Get.context!, title: "Mismatch", message: "New password and confirmation do not match.");
      return;
    }

    try {
      final db = await DatabaseService.db;

      // If user input is empty, use the data already in the database
      String finalQuestion = (question != null && question.isNotEmpty) ? question : (settings?['security_question'] ?? "");

      String finalAnswer = (answer != null && answer.isNotEmpty) ? answer.trim().toLowerCase() : (settings?['security_answer'] ?? "");

      // Update with "merged" data
      await db.update(
          'security',
          {
            'master_password': newPass,
            'password_hint': hint.isNotEmpty ? hint : (settings?['password_hint'] ?? ""),
            'security_question': finalQuestion,
            'security_answer': finalAnswer,
          },
          where: 'id = 1');

      Get.back();
      _showSuccess("Password updated successfully.");
    } catch (e) {
      _showError("Update failed. Please try again.");
    }
  }

  // FORGET PASSWORD VERIFICATION
  // Future<void> handleForgetPasswordVerify({required String userAnswer}) async {
  //   final settings = await getSecuritySettings();
  //   String storedAnswer = (settings?['security_answer'] ?? "").toString().trim().toLowerCase();

  //   if (storedAnswer.isEmpty) {
  //     await _showDialog(
  //       Get.context!,
  //       title: "",
  //       message: "Recovery not set up.",
  //     );
  //     return;
  //   }

  //   if (userAnswer.trim().toLowerCase() == storedAnswer) {
  //     _showSuccess("Identity Verified");
  //     Get.off(() => const CreatePasswordScreen());
  //   } else {
  //     await _showDialog(
  //       Get.context!,
  //       title: "",
  //       message: "Incorrect answer.",
  //     );
  //   }
  // }

  Future<void> handleForgetPasswordVerify({required String userAnswer}) async {
    if (userAnswer.trim().isEmpty) {
      await _showDialog(
        Get.context!,
        title: "Field Required",
        message: "Please enter your security answer.",
      );
      return;
    }

    try {
      final settings = await getSecuritySettings();
      String storedAnswer = (settings?['security_answer'] ?? "").toString().trim().toLowerCase();

      // Handle "Not Set Up" case
      if (storedAnswer.isEmpty) {
        await _showDialog(
          Get.context!,
          title: "Setup Required",
          message: "Security recovery has not been configured for this account.",
        );
        return;
      }

      if (userAnswer.trim().toLowerCase() == storedAnswer) {
        _showSuccess("Identity verified successfully!");

        Get.off(() => const CreatePasswordScreen());
      } else {
        await _showDialog(
          Get.context!,
          title: "Verification Failed",
          message: "The answer you entered is incorrect. Please try again.",
        );
      }
    } catch (e) {
      _showError("An error occurred while verifying. Please try again later.");
    }
  }

  Future<void> handleRemoveAllLock({
    required String currentInput,
    required String confirmPass,
  }) async {
    final settings = await getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (storedPass.isEmpty) {
      await _showDialog(
        Get.context!,
        title: "Field Required",
        message: "No password is currently set.",
      );
      return;
    }

    if (currentInput != storedPass) {
      await _showDialog(Get.context!, title: "Verification Failed", message: "Current password is incorrect.");
      return;
    }

    if (currentInput != confirmPass) {
      await _showDialog(Get.context!, title: "Verification Failed", message: "Passwords do not match.");
      return;
    }

    try {
      final db = await DatabaseService.db;

      // Bulk Unlock all notes in SQLite
      await db.update('notes', {'is_locked': 0});

      // Clear security table
      await db.update(
          'security',
          {
            'master_password': '',
            'security_question': '',
            'security_answer': '',
            'password_hint': '',
          },
          where: 'id = 1');

      // Refresh UI
      final NoteController noteController = Get.find<NoteController>();
      await noteController.fetchAllNotes();

      Get.back();
      _showSuccess("Security removed and all notes unlocked.");
    } catch (e) {
      _showError("Failed to remove security. Please try again.");
    }
  }

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

  void _showError(String message) {
    Get.snackbar("Error", message, backgroundColor: AppColor().red, colorText: Colors.white);
  }

  void _showSuccess(String message) {
    Get.snackbar("Success", message, backgroundColor: AppColor().green, colorText: Colors.white);
  }
}
