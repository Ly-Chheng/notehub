import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/note_book.png',
              fit: BoxFit.cover,
              height: context.isPhone ? 100 : 130,
              width: context.isPhone ? 100 : 130,
            ),
          ],
        ),
      ),
    );
  }
}
