import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class LockVerificationScreen extends StatefulWidget {
  const LockVerificationScreen({super.key});

  @override
  State<LockVerificationScreen> createState() => _LockVerificationScreenState();
}

class _LockVerificationScreenState extends State<LockVerificationScreen> {
  final TextEditingController _passController = TextEditingController();

  bool _obscureNew = true;

  // 2. Dispose them to free up memory
  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: "Folder",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().black,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: context.isPhone ? 10 : 20),
            child: Row(
              children: [
                Text(
                  "My Note",
                  style: TextStyle(
                    color: AppColor().primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: context.isPhone ? 20 : 22,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.lock_outline,
                  color: AppColor().primaryColor,
                  size: context.isPhone ? 20 : 30,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Icon(
                Icons.lock_outline,
                size: 80,
                color: AppColor().primaryColor,
              ),
            ),
            Text(
              "View Note",
              style: TextStyle(fontSize: context.isPhone ? 18 : 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Enter the password you created for notes ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 60),

            // Security Question Section
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customTextField(
                    "Password",
                    _obscureNew,
                    () => setState(() => _obscureNew = !_obscureNew),
                    controller: _passController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
