import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // 1. Define the controllers
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // 2. Cleanup controllers when screen is closed
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // appBar: AppBar(
      //  backgroundColor: const Color(0xFFF8F9FB),
      //   elevation: 0,
      //   leadingWidth: 100,
      //   leading: TextButton.icon(
      //     onPressed: () => Get.back(),
      //     icon: Icon(Icons.arrow_back_ios, size: 18, color: AppColor().primaryColor),
      //     label: Text("Back", style: TextStyle(color: AppColor().primaryColor, fontSize: 16)),
      //   ),
      //   actions: [
      //     TextButton(
      //       onPressed: () {
      //         // 3. Simple validation logic
      //         String pass = _newPasswordController.text;
      //         String confirm = _confirmPasswordController.text;

      //         if (pass.isEmpty || confirm.isEmpty) {
      //           Get.snackbar("Error", "Please fill in all fields", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
      //         } else if (pass != confirm) {
      //           Get.snackbar("Error", "Passwords do not match", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
      //         } else {
      //           // Success - Call your API or Update logic here
      //           Get.snackbar("Success", "Password reset successfully", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
      //           Get.back(); // Go back to More screen
      //         }
      //       },
      //       child: Text("Save", style: TextStyle(color: AppColor().primaryColor, fontSize: 16, fontWeight: FontWeight.w500)),
      //     ),
      //   ],
      // ),
      appBar: customAppBar(
        title: "Back",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().black,
        actions: [
          TextButton(
            onPressed: () {
              // 3. Simple validation logic
              String pass = _newPasswordController.text;
              String confirm = _confirmPasswordController.text;

              if (pass.isEmpty || confirm.isEmpty) {
                Get.snackbar("Error", "Please fill in all fields", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
              } else if (pass != confirm) {
                Get.snackbar("Error", "Passwords do not match", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
              } else {
                // Success - Call your API or Update logic here
                Get.snackbar("Success", "Password reset successfully", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
                Get.back(); // Go back to More screen
              }
            },
            child: Text("Save", style: TextStyle(color: AppColor().primaryColor, fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Reset Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text(
              "For your security, please reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 40),

            // 4. Using controllers in your buildPasswordField
            customTextField(
              "Current Password",
              _obscureNew,
              () => setState(() => _obscureNew = !_obscureNew),
              controller: _newPasswordController,
            ),

            const SizedBox(height: 15),

            customTextField(
              "Confirm Password",
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
              controller: _confirmPasswordController,
            ),
          ],
        ),
      ),
    );
  }
}
