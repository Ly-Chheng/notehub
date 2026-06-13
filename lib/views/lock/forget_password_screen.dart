import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final LockController _controller = Get.put(LockController());

  final TextEditingController _answerController = TextEditingController();

  String? storedQuestion;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  Future<void> _loadSecurityData() async {
    final settings = await _controller.getSecuritySettings();
    if (mounted) {
      setState(() {
        storedQuestion = settings?['security_question'];
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "",
        context: context,
        actions: [
          TextButton(
            onPressed: () {
              _controller.handleForgetPasswordVerify(
                userAnswer: _answerController.text,
              );
            },
            child: Text(
              "submit".tr,
              style: text18(context).copyWith(color: AppColor().primaryColor),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: Layout.padding(),
                child: Column(
                  children: [
                    Center(child: customHeader("forget_password".tr, context)),
                    const SizedBox(height: 8),
                    Text(
                      "forget_password_desc".tr,
                      textAlign: TextAlign.center,
                      style: text16(context).copyWith(
                        color: AppColor().gray,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (storedQuestion == null || storedQuestion!.trim().isEmpty) ? "no_security_question".tr : storedQuestion!,
                            style: text16(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    customTextField(
                      "enter_your_answer".tr,
                      false,
                      null,
                      controller: _answerController,
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
