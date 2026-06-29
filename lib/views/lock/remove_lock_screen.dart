import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "reset_password".tr,
        context: context,
        actions: [
          TextButton(
            onPressed: () {
              _lockController.handleRemoveAllLock(
                currentInput: _currentPassController.text.trim(),
                confirmPass: _confirmPassController.text.trim(),
              );
            },
            child: Text(
              "save".tr,
              style: text18(context).copyWith(color: AppColor().white),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: Layout.padding(),
          child: Column(
            children: [
              // Center(child: customHeader("reset_password".tr, context)),
              const SizedBox(height: 8),
              Text(
                "remove_lock_desc".tr,
                textAlign: TextAlign.center,
                style: text16(context).copyWith(
                  color: AppColor().gray,
                ),
              ),
              const SizedBox(height: 30),
              customTextField("current_password".tr, _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent), controller: _currentPassController),
              const SizedBox(height: 15),
              customTextField("confirm_password".tr, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), controller: _confirmPassController),
            ],
          ),
        ),
      ),
    );
  }
}
