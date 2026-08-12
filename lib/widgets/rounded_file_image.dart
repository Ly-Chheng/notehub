import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class RoundedFileImage extends StatelessWidget {
  final String path;
  final double phoneSize;
  final double desktopSize;

  const RoundedFileImage({
    super.key,
    required this.path,
    this.phoneSize = 60,
    this.desktopSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    final size = context.isPhone ? phoneSize : desktopSize;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, size: size * 0.4),
        ),
      ),
    );
  }
}
