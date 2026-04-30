import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_header.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class RemoveLockScreen extends StatefulWidget {
  const RemoveLockScreen({super.key});

  @override
  State<RemoveLockScreen> createState() => _RemoveLockScreenState();
}

class _RemoveLockScreenState extends State<RemoveLockScreen> {
  final LockController _lockController = Get.put(LockController());

  final NoteController _noteController = Get.find<NoteController>();

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
    final bool hasLockedNotes = _noteController.notes.any((n) => n.isLocked == true);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              _lockController.handleRemoveAllLock(
                currentInput: _currentPassController.text.trim(),
                confirmPass: _confirmPassController.text.trim(),
              );
            },
            child: Text(
              "Save",
              style: text18(context).copyWith(color: AppColor().primaryColor),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Center(child: customHeader("Remove Protection", context)),
              const SizedBox(height: 8),
              Text(
                "Please enter your current password to remove all protection.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColor().gray, fontFamily: 'EN-REGULAR'),
              ),
              const SizedBox(height: 30),

              // Warning box if there are locked notes
              if (hasLockedNotes)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    color: AppColor().orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor().orange.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_open_rounded, color: AppColor().orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "All currently locked notes will be unlocked and no longer require a password.",
                          style: TextStyle(fontSize: 12, color: AppColor().orange, fontFamily: 'EN-REGULAR'),
                        ),
                      ),
                    ],
                  ),
                ),

              customTextField("Current Password", _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent), controller: _currentPassController),
              const SizedBox(height: 15),
              customTextField("Confirm Password", _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), controller: _confirmPassController),
            ],
          ),
        ),
      ),
    );
  }
}
