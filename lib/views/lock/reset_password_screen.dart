// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart'; // Import Hive
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';
// import 'package:project_structure/widgets/custom_text_field.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   // Access the settings box
//   final Box settingsBox = Hive.box('settings_box');

//   bool _obscureNew = true;
//   bool _obscureConfirm = true;

//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   // --- RESET LOGIC ---
//   void _handleResetPassword() async {
//     String newPass = _newPasswordController.text.trim();
//     String confirmPass = _confirmPasswordController.text.trim();

//     // 1. Validation: Empty fields
//     if (newPass.isEmpty || confirmPass.isEmpty) {
//       Get.snackbar("Error", "Please fill in all fields",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }

//     // 2. Validation: Match
//     if (newPass != confirmPass) {
//       Get.snackbar("Error", "Passwords do not match",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }

//     // 3. Validation: Length (Security best practice)
//     if (newPass.length < 4) {
//       Get.snackbar("Error", "Password must be at least 4 characters",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }

//     // 4. Update Hive
//     try {
//       await settingsBox.put('master_password', newPass);

//       Get.snackbar("Success", "Password updated successfully",
//           backgroundColor: Colors.green, colorText: Colors.white);

//       // Navigate back to the lock screen or home
//       Get.back();
//     } catch (e) {
//       Get.snackbar("Error", "Failed to update password. Please try again.",
//           backgroundColor: Colors.red, colorText: Colors.white);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: customAppBar(
//         title: "Back",
//         titleColor: AppColor().primaryColor,
//         context: context,
//         leadingColor: AppColor().primaryColor,
//         actions: [
//           TextButton(
//             onPressed: _handleResetPassword, // Call reset logic
//             child: Text("Save",
//                 style: TextStyle(
//                   color: AppColor().primaryColor,
//                   fontSize: context.isPhone ? 20 : 22,
//                   fontFamily: 'EN-SEMIBOLD',
//                 )),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             Text("Reset Password",
//                 style: TextStyle(
//                   fontSize: context.isPhone ? 18 : 24,
//                   fontFamily: 'EN-BOLD',
//                 )),
//             const SizedBox(height: 15),
//             Text(
//               "Enter a new password to secure your account.",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: context.isPhone ? 16 : 20,
//                 fontFamily: 'EN-REGULAR',
//               ),
//             ),
//             const SizedBox(height: 40),

//             // Corrected labels for Reset context
//             customTextField(
//               "New Password",
//               _obscureNew,
//               () => setState(() => _obscureNew = !_obscureNew),
//               controller: _newPasswordController,
//             ),

//             const SizedBox(height: 15),

//             customTextField(
//               "Confirm New Password",
//               _obscureConfirm,
//               () => setState(() => _obscureConfirm = !_obscureConfirm),
//               controller: _confirmPasswordController,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Access the settings box
  final Box settingsBox = Hive.box('settings_box');

  // Visibility states
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- RESET LOGIC ---
  void _handleResetPassword() async {
    String currentPass = _currentPasswordController.text.trim();
    String newPass = _newPasswordController.text.trim();
    String confirmPass = _confirmPasswordController.text.trim();

    // 1. Fetch existing password from Hive
    String? storedPassword = settingsBox.get('master_password');

    // 2. Validation: Empty fields
    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 3. Validation: Verify Current Password
    // If no password exists yet (first time setup), you might skip this or handle accordingly
    if (storedPassword != null && currentPass != storedPassword) {
      Get.snackbar("Error", "Current password is incorrect", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 4. Validation: Match New Passwords
    if (newPass != confirmPass) {
      Get.snackbar("Error", "New passwords do not match", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 5. Update Hive
    try {
      await settingsBox.put('master_password', newPass);
      Get.snackbar("Success", "Password updated successfully", backgroundColor: Colors.green, colorText: Colors.white);

      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to update password.", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "Back",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          TextButton(
            onPressed: _handleResetPassword,
            child: Text("Save",
                style: TextStyle(
                  color: AppColor().primaryColor,
                  fontSize: context.isPhone ? 20 : 22,
                  fontFamily: 'EN-SEMIBOLD',
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Added scroll view to prevent overflow on keyboard popup
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text("Reset Password",
                  style: TextStyle(
                    fontSize: context.isPhone ? 18 : 24,
                    fontFamily: 'EN-BOLD',
                  )),
              const SizedBox(height: 15),
              Text(
                "Verify your current identity and set a new password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.isPhone ? 16 : 20,
                  fontFamily: 'EN-REGULAR',
                ),
              ),
              const SizedBox(height: 40),

              // 1. Current Password Field
              customTextField(
                "Current Password",
                _obscureCurrent,
                () => setState(() => _obscureCurrent = !_obscureCurrent),
                controller: _currentPasswordController,
              ),

              const SizedBox(height: 15),

              // 2. New Password Field
              customTextField(
                "New Password",
                _obscureNew,
                () => setState(() => _obscureNew = !_obscureNew),
                controller: _newPasswordController,
              ),

              const SizedBox(height: 15),

              // 3. Confirm Password Field
              customTextField(
                "Confirm New Password",
                _obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm),
                controller: _confirmPasswordController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
