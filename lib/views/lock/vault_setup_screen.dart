import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class VaultSetupScreen extends StatefulWidget {
  const VaultSetupScreen({super.key});

  @override
  State<VaultSetupScreen> createState() => _VaultSetupScreenState();
}

class _VaultSetupScreenState extends State<VaultSetupScreen> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _hintController = TextEditingController();
  final _answerController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _selectedQuestion;

  final List<String> _questions = [
    "What was the name of your first school?",
    "What is your mother's maiden name?",
    "In which city were you born?",
  ];

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    _hintController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateVaultLock() async {
    // Basic Validation
    if (_newPassController.text.isEmpty || _selectedQuestion == null || _answerController.text.isEmpty) {
      Get.snackbar("Required", "Please complete all security fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_newPassController.text != _confirmPassController.text) {
      Get.snackbar("Mismatch", "Passwords do not match", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Save to Hive settings_box
    final settingsBox = Hive.box('settings_box');
    await settingsBox.put('master_password', _newPassController.text);
    await settingsBox.put('security_question', _selectedQuestion);
    await settingsBox.put('security_answer', _answerController.text);
    await settingsBox.put('hint', _hintController.text);

    // Enable the global lock flag
    await settingsBox.put('is_vault_locked', true);

    Get.back(result: true);
    Get.snackbar("Vault Active", "All notes are now protected", backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Security",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          TextButton(
            onPressed: _handleCreateVaultLock,
            child: Text("Enable", style: TextStyle(fontSize: 18, color: AppColor().primaryColor, fontFamily: 'EN-BOLD')),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.local_activity, size: 60, color: AppColor().primaryColor),
                  const SizedBox(height: 10),
                  Text("Notes Vault",
                      style: TextStyle(
                        fontSize: context.isPhone ? 22 : 26,
                        fontFamily: 'EN-BOLD',
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Set a master password. This will be required to view or edit any of your saved notes.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'EN-REGULAR'),
            ),
            const SizedBox(height: 30),
            customTextField("Master Password", _obscureNew, () => setState(() => _obscureNew = !_obscureNew), controller: _newPassController),
            const SizedBox(height: 15),
            customTextField("Confirm Master Password", _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), controller: _confirmPassController),
            const SizedBox(height: 15),
            buildStandardField("Hint (Optional)", controller: _hintController),
            const SizedBox(height: 35),
            const Text("Recovery Question", style: TextStyle(fontSize: 16, fontFamily: 'EN-BOLD')),
            const SizedBox(height: 10),
            _buildDropdown(),
            const SizedBox(height: 15),
            buildStandardField("Security Answer", controller: _answerController),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedQuestion,
          hint: const Text("Select Recovery Question"),
          isExpanded: true,
          items: _questions.map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
          onChanged: (val) => setState(() => _selectedQuestion = val),
        ),
      ),
    );
  }
}
