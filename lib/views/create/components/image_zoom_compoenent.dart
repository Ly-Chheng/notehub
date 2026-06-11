import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class ImageZoomPage extends StatelessWidget {
  final String imagePath;
  const ImageZoomPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "",
        context: context,
        leadingColor: AppColor().primaryColor,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 5,
          child: imagePath.startsWith('http') ? Image.network(imagePath) : Image.file(File(imagePath)),
        ),
      ),
    );
  }
}
