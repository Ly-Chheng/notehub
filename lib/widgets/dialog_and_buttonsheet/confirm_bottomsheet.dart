import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_button.dart';

class ConfirmBottomSheet {
  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? content,
    String? confirmText,
    Color? confirmColor,
    int itemCount = 1,
    bool showTopCancel = false,
    VoidCallback? onCancel,
    String? saveText,
    VoidCallback? onSave,
    Future<void> Function()? onConfirm,
    bool isFloating = false,
  }) {
    final bool hasSaveButton = saveText != null && onSave != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: isFloating ? Colors.transparent : Theme.of(context).cardColor,
      elevation: isFloating ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: isFloating ? BorderRadius.circular(20) : const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: isFloating ? 13 : 0,
              right: isFloating ? 13 : 0,
              bottom: isFloating ? 13 : 0,
            ),
            child: Container(
              decoration: isFloating
                  ? BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    )
                  : const BoxDecoration(),
              padding: EdgeInsets.all(isFloating ? 15 : 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: context.isPhone ? 70 : 90,
                      height: context.isPhone ? 6 : 10,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: showTopCancel
                              ? TextButton(
                                  onPressed: onCancel ?? () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "cancel".tr,
                                    style: text14(context).copyWith(
                                      color: AppColor().red,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        itemCount > 1 ? "$title ($itemCount)" : title,
                        style: text18(context),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: hasSaveButton
                              ? TextButton(
                                  onPressed: onSave,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    saveText,
                                    style: text14(context).copyWith(
                                      color: AppColor().primaryColor,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Content Switcher
                  if (content != null) ...[
                    content,
                  ] else if (subtitle != null) ...[
                    Text(
                      subtitle,
                      style: text16(context).copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Bottom Confirmation Actions Block
                  if (confirmText != null && onConfirm != null) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "cancel".tr,
                            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
                            textColor: Theme.of(context).textTheme.bodyLarge?.color ?? AppColor().black,
                            onPressed: onCancel ?? () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: confirmText,
                            backgroundColor: confirmColor ?? AppColor().primaryColor,
                            onPressed: () async {
                              Navigator.pop(context);
                              await onConfirm();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
