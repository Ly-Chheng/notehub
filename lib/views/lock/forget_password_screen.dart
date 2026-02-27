import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _answerController = TextEditingController();

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
            onPressed: () {},
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
            Text(
              "Please answer your security question to verify your identity.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'EN-REGULAR', height: 1.4),
            ),
            const SizedBox(height: 60),

            // Security Question Section
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What was the name of your first school?",
                    style: TextStyle(
                      fontSize: context.isPhone ? 16 : 20,
                      fontFamily: 'EN-REGULAR',
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Styled Input Field
                  buildStandardField("Enter your answer", controller: _answerController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
