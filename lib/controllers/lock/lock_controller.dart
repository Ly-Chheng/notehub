import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/home/folder_controller.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/controllers/note/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';

class LockController extends GetxController {
  List<String> get questions => [
        // "first_school_question".tr,
        "mother_maiden_name_question".tr,
        "birth_city_question".tr,
        "dream_job_child_question".tr,
        "favorite_teacher_question".tr,
      ];
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
        title: "field_required".tr,
        message: "field_required_msg".tr,
      );
      return;
    }

    if (password != confirmPassword) {
      await _showDialog(
        Get.context!,
        title: "mismatch".tr,
        message: "mismatch_msg".tr,
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
      _showSuccess("security_saved".tr);
    } catch (e) {
      await _showDialog(
        Get.context!,
        title: "db_error_title".tr,
        message: "db_error_msg",
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
    final settings = await getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (storedPass.isEmpty) {
      await _showDialog(Get.context!, title: "not_configured".tr, message: "not_configured_msg".tr);
      return;
    }

    if (newPass.isEmpty) {
      await _showDialog(
        Get.context!,
        title: "input_required".tr,
        message: "input_required_msg".tr,
      );
      return;
    }

    if (currentInput != storedPass) {
      await _showDialog(Get.context!, title: "verification_failed".tr, message: "verification_failed_msg".tr);
      return;
    }

    if (newPass != confirmPass) {
      await _showDialog(Get.context!, title: "mismatch".tr, message: "password_confirm_mismatch".tr);
      return;
    }

    try {
      final db = await DatabaseService.db;

      String finalQuestion = (question != null && question.isNotEmpty) ? question : (settings?['security_question'] ?? "");

      String finalAnswer = (answer != null && answer.isNotEmpty) ? answer.trim().toLowerCase() : (settings?['security_answer'] ?? "");

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
      _showSuccess("password_updated".tr);
    } catch (e) {
      _showError("update_failed".tr);
    }
  }

  Future<void> handleForgetPasswordVerify({required String userAnswer}) async {
    if (userAnswer.trim().isEmpty) {
      await _showDialog(
        Get.context!,
        title: "field_required".tr,
        message: "answer_required_msg".tr,
      );
      return;
    }

    try {
      final settings = await getSecuritySettings();
      String storedAnswer = (settings?['security_answer'] ?? "").toString().trim().toLowerCase();

      if (storedAnswer.isEmpty) {
        await _showDialog(
          Get.context!,
          title: "setup_required".tr,
          message: "setup_required_msg".tr,
        );
        return;
      }

      if (userAnswer.trim().toLowerCase() == storedAnswer) {
        _showSuccess("verified_success".tr);

        Get.off(() => const CreatePasswordScreen());
      } else {
        await _showDialog(
          Get.context!,
          title: "verification_failed".tr,
          message: "verification_failed_answer_msg".tr,
        );
      }
    } catch (e) {
      _showError("verify_error".tr);
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
        title: "field_required",
        message: "no_password_set_msg".tr,
      );
      return;
    }

    if (currentInput != storedPass) {
      await _showDialog(Get.context!, title: "verification_failed".tr, message: "current_password_wrong_msg".tr);
      return;
    }

    if (currentInput != confirmPass) {
      await _showDialog(Get.context!, title: "verification_failed".tr, message: "password_mismatch_msg".tr);
      return;
    }

    try {
      final db = await DatabaseService.db;

      await db.update('notes', {'is_locked': 0});

      await db.update('folders', {'isLocked': 0});

      await db.update(
          'security',
          {
            'master_password': '',
            'security_question': '',
            'security_answer': '',
            'password_hint': '',
          },
          where: 'id = 1');

      final NoteController noteController = Get.find<NoteController>();
      final FolderController folderController = Get.find<FolderController>();

      await noteController.fetchAllNotes();
      await folderController.loadFolders();

      Get.back();
      Get.offAllNamed('mainHome');

      _showSuccess("security_removed_success".tr);
    } catch (e) {
      _showError("security_remove_failed".tr);
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
      confirmText: "ok".tr,
      onConfirm: () {},
    );
  }

  void _showError(String message) {
    Get.snackbar("error".tr, message, backgroundColor: AppColor().red, colorText: Colors.white);
  }

  void _showSuccess(String message) {
    Get.snackbar("success".tr, message, backgroundColor: AppColor().green, colorText: Colors.white);
  }
}
