import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class ImageDetailScreen extends StatelessWidget {
  final File imageFile;

  const ImageDetailScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            clipBehavior: Clip.none,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
