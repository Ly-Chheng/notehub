import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/theme_controller.dart';
import 'package:project_structure/views/more/widgets/change_language.dart';
import 'package:project_structure/views/more/widgets/dark_mode.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({
    super.key,
  });

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final controller = Get.put(DarkModeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const ChangeLanguageView(),
              DarkModeView(),
            ],
          ),
        ),
      ),
    );
  }
}
