// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/views/lock/create_password_screen.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';
// import 'package:project_structure/widgets/custom_text_field.dart';

// class ForgetPasswordScreen extends StatefulWidget {
//   const ForgetPasswordScreen({super.key});

//   @override
//   State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
// }

// class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
//   final TextEditingController _answerController = TextEditingController();
//   final Box settingsBox = Hive.box('settings_box');

//   String? storedQuestion;
//   String? storedAnswer;

//   @override
//   void initState() {
//     super.initState();
//     // Load the question and answer set during setup
//     storedQuestion = settingsBox.get('security_question') ?? "What was the name of your first school?";
//     storedAnswer = settingsBox.get('security_answer');
//   }

//   // --- FORGET PASSWORD LOGIC ---
//   void _handleSubmit() {
//     String userAnswer = _answerController.text.trim().toLowerCase();

//     if (userAnswer.isEmpty) {
//       Get.snackbar("Error", "Please enter an answer", backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }

//     if (storedAnswer == null) {
//       Get.snackbar("Error", "No security answer found in settings.", backgroundColor: Colors.orange, colorText: Colors.white);
//       return;
//     }

//     // Check if the answer matches the one in Hive
//     if (userAnswer == storedAnswer!.toLowerCase()) {
//       Get.snackbar("Verified", "Identity confirmed. Please reset your password.", backgroundColor: Colors.green, colorText: Colors.white);

//       // Navigate to CreatePasswordScreen to set a new password
//       // result: true ensures the parent screens know a change happened
//       Get.off(() => const CreatePasswordScreen());
//     } else {
//       Get.snackbar("Error", "Incorrect answer. Please try again.", backgroundColor: Colors.red, colorText: Colors.white);
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
//             onPressed: _handleSubmit, // Call the logic
//             child: Text("Submit",
//                 style: TextStyle(
//                   color: AppColor().primaryColor,
//                   fontSize: context.isPhone ? 20 : 22,
//                   fontFamily: 'EN-REGULAR',
//                 )),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: SingleChildScrollView(
//           // Added scroll for small screens
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               Text(
//                 "Forget Password",
//                 style: TextStyle(
//                   fontSize: context.isPhone ? 18 : 24,
//                   fontFamily: 'EN-BOLD',
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Text(
//                 "Please answer your security question to verify your identity.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'EN-REGULAR', height: 1.4),
//               ),
//               const SizedBox(height: 60),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       storedQuestion!, // Display the actual question
//                       style: TextStyle(
//                         fontSize: context.isPhone ? 16 : 20,
//                         fontFamily: 'EN-REGULAR',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     buildStandardField("Enter your answer", controller: _answerController),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _answerController = TextEditingController();
  final Box settingsBox = Hive.box('settings_box');

  String? storedQuestion;
  String? storedAnswer;
  bool hasSecuritySetup = false; // Flag for privacy protection

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  void _loadSecurityData() {
    // Check if an answer exists first to verify identity recovery is possible
    storedAnswer = settingsBox.get('security_answer');
    storedQuestion = settingsBox.get('security_question');

    if (storedAnswer != null && storedAnswer!.trim().isNotEmpty) {
      setState(() {
        hasSecuritySetup = true;
      });
    }
  }

  void _handleSubmit() {
    if (!hasSecuritySetup) return;

    String userAnswer = _answerController.text.trim().toLowerCase();

    if (userAnswer.isEmpty) {
      Get.snackbar("Error", "Please enter an answer", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (userAnswer == storedAnswer!.toLowerCase()) {
      Get.snackbar("Verified", "Identity confirmed.", backgroundColor: Colors.green, colorText: Colors.white);
      Get.off(() => const CreatePasswordScreen());
    } else {
      Get.snackbar("Error", "Incorrect answer. Please try again.", backgroundColor: Colors.red, colorText: Colors.white);
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
          if (hasSecuritySetup) // Hide submit button if no setup exists
            TextButton(
              onPressed: _handleSubmit,
              child: Text("Submit",
                  style: TextStyle(
                    color: AppColor().primaryColor,
                    fontSize: context.isPhone ? 20 : 22,
                    fontFamily: 'EN-REGULAR',
                  )),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Forget Password",
                style: TextStyle(
                  fontSize: context.isPhone ? 18 : 24,
                  fontFamily: 'EN-BOLD',
                ),
              ),
              const SizedBox(height: 15),

              // Conditional UI rendering
              if (!hasSecuritySetup) _buildNoSetupView() else _buildSecurityQuestionView(),
            ],
          ),
        ),
      ),
    );
  }

  // Shown when no security question/answer is found in Hive
  Widget _buildNoSetupView() {
    return Column(
      children: [
        const SizedBox(height: 50),
        Icon(Icons.lock_reset, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 20),
        const Text(
          "Recovery Not Available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "No security question was found for this account. Recovery is not possible via this method.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }

  // Shown when security setup is verified
  Widget _buildSecurityQuestionView() {
    return Column(
      children: [
        Text(
          "Please answer your security question to verify your identity.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'EN-REGULAR', height: 1.4),
        ),
        const SizedBox(height: 60),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                storedQuestion ?? "Security Question",
                style: TextStyle(
                  fontSize: context.isPhone ? 16 : 20,
                  fontFamily: 'EN-MEDIUM',
                ),
              ),
              const SizedBox(height: 12),
              buildStandardField("Enter your answer", controller: _answerController),
            ],
          ),
        ),
      ],
    );
  }
}
