import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';

class LockController extends GetxController {
  final List<String> questions = [
    "What was the name of your first school?",
    "What is your mother's maiden name?",
    "In which city were you born?",
  ];

  // Helper: Fetch current security settings
  Future<Map<String, dynamic>?> getSecuritySettings() async {
    final db = await DatabaseService.db;
    final List<Map<String, dynamic>> maps = await db.query('security', where: 'id = 1');
    return maps.isNotEmpty ? maps.first : null;
  }

  // CREATE OR RESET PASSWORD
  Future<void> handleCreatePassword({
    required String password,
    required String confirmPassword,
    required String? question,
    required String answer,
    required String hint,
  }) async {
    if (password.isEmpty || question == null || answer.isEmpty) {
      _showError("All fields are required.");
      return;
    }
    if (password != confirmPassword) {
      _showError("Passwords do not match.");
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
      _showSuccess("Security Settings Saved");
    } catch (e) {
      _showError("Failed to save settings.");
    }
  }

  // CHANGE EXISTING PASSWORD
  Future<void> handleChangePassword({
    required String currentInput,
    required String newPass,
    required String confirmPass,
    required String hint,
    required String? question,
    required String answer,
  }) async {
    final settings = await getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (currentInput != storedPass) {
      _showError("Current password incorrect.");
      return;
    }
    if (newPass != confirmPass) {
      _showError("New passwords do not match.");
      return;
    }

    try {
      final db = await DatabaseService.db;
      await db.update(
          'security',
          {
            'master_password': newPass,
            'password_hint': hint,
            'security_question': question,
            'security_answer': answer.trim().toLowerCase(),
          },
          where: 'id = 1');

      Get.back();
      _showSuccess("Password Updated");
    } catch (e) {
      _showError("Update failed.");
    }
  }

  // FORGET PASSWORD VERIFICATION
  Future<void> handleForgetPasswordVerify({
    required String userAnswer,
  }) async {
    final settings = await getSecuritySettings();
    String storedAnswer = settings?['security_answer'] ?? "";

    if (storedAnswer.isEmpty) {
      _showError("Recovery not set up.");
      return;
    }

    if (userAnswer.trim().toLowerCase() == storedAnswer) {
      _showSuccess("Identity Verified");
      Get.off(() => const CreatePasswordScreen()); // Redirect to reset
    } else {
      _showError("Incorrect answer.");
    }
  }

  // REMOVE ALL SECURITY & UNLOCK NOTES
  Future<void> handleRemoveAllLock({
    required String currentInput,
    required String confirmPass,
  }) async {
    final settings = await getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (currentInput != storedPass || currentInput != confirmPass) {
      _showError("Verification failed.");
      return;
    }

    try {
      final db = await DatabaseService.db;

      // 1. Bulk Unlock all notes in SQLite
      await db.update('notes', {'is_locked': 0});

      // 2. Clear security table
      await db.update(
          'security',
          {
            'master_password': '',
            'security_question': '',
            'security_answer': '',
            'password_hint': '',
          },
          where: 'id = 1');

      // 3. Refresh UI
      final NoteController noteController = Get.find<NoteController>();
      await noteController.fetchAllNotes();

      Get.back();
      _showSuccess("Security removed and notes unlocked.");
    } catch (e) {
      _showError("Removal failed.");
    }
  }

  void _showError(String message) {
    Get.snackbar("Error", message, backgroundColor: AppColor().red, colorText: Colors.white);
  }

  void _showSuccess(String message) {
    Get.snackbar("Success", message, backgroundColor: AppColor().green, colorText: Colors.white);
  }
}
