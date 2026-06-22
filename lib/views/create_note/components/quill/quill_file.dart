// CUSTOM FILE EMBED BUILDER WITH VIEW ACTION
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/widgets/custom_snack_bar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/multi_style.dart';
import 'package:share_plus/share_plus.dart';

class CustomFileEmbedBuilder implements EmbedBuilder {
  CustomFileEmbedBuilder();

  @override
  String get key => 'file';

  @override
  bool get expanded => false;

  Future<void> _viewFile(String filePath) async {
    if (filePath.isEmpty) {
      Get.snackbar("error".tr, "error_file_empty".tr);
      return;
    }

    final File file = File(filePath);
    if (await file.exists()) {
      try {
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          AppSnackbar.showError(
            title: "error_cannot_open".tr,
            message: "No compatible application found on your device to open this file.",
          );
        }
      } catch (e) {
        Get.snackbar("Error", "An error occurred while trying to open the file: $e");
      }
    } else {
      AppSnackbar.showError(
        title: "file_not_found".tr,
        message: "The file no longer exists at its recorded path storage directory.",
      );
    }
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final String rawData = embedContext.node.value.data.toString();
    Map<String, dynamic> fileData = {};

    try {
      fileData = jsonDecode(rawData);
    } catch (e) {
      debugPrint("Error parsing custom file block metadata payload string: $e");
    }

    final String fileName = fileData['name'] ?? 'Unknown File';
    final String fileSize = fileData['size'] ?? '0 B';
    final String filePath = fileData['path'] ?? '';

    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: context.isPhone ? 0.85 : 0.65,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: GestureDetector(
            onTap: () => _viewFile(filePath),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: Layout.cardDecoration(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColor().primaryColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.insert_drive_file_outlined,
                      color: AppColor().primaryColor,
                      size: context.isPhone ? 24 : 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text14(context),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fileSize,
                          style: text12,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, size: context.isPhone ? 24 : 26, color: AppColor().gray),
                    onPressed: () => _showFileActionSheet(context, embedContext, filePath, fileName),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFileActionSheet(BuildContext context, EmbedContext embedContext, String filePath, String fileName) {
    FocusManager.instance.primaryFocus?.unfocus();

    ConfirmBottomSheet.show(
      context: context,
      title: "file_options".tr,
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          decoration: Layout.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildActionItem(
                context,
                icon: Icons.share_outlined,
                color: AppColor().primaryColor,
                title: "share".tr,
                onTap: () async {
                  Get.back();
                  if (filePath.isNotEmpty && await File(filePath).exists()) {
                    // await Share.shareXFiles(
                    //   [XFile(filePath)],
                    // );
                    await SharePlus.instance.share(
                      ShareParams(
                        files: [XFile(filePath)],
                      ),
                    );
                  } else {
                    Get.snackbar("eror".tr, "File path doesn't exist anymore.");
                  }
                },
              ),
              divider(context),
              buildActionItem(
                context,
                icon: Icons.delete_outline,
                color: AppColor().red,
                title: "remove".tr,
                isDestructive: true,
                onTap: () {
                  Get.back();
                  final offset = embedContext.node.documentOffset;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    embedContext.controller.replaceText(
                      offset,
                      1,
                      '',
                      TextSelection.collapsed(offset: offset),
                    );

                    embedContext.controller.updateSelection(
                      const TextSelection.collapsed(offset: -1),
                      ChangeSource.local,
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  String toPlainText(Embed node) {
    try {
      final data = jsonDecode(node.value.data.toString());
      return "[File: ${data['name'] ?? ''}]\n";
    } catch (_) {
      return "[File]\n";
    }
  }

  @override
  WidgetSpan buildWidgetSpan(Widget child) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: child,
    );
  }
}
