import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_button.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

enum DialogType { normal, success, error, warning }

Future<void> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String subTitle,
  String? confirmText,
  required VoidCallback onConfirm,
  bool showCancel = true,
  DialogType type = DialogType.normal,
  TextEditingController? controller,
  bool obscureText = false,
  String? hintText,
}) {
  Color confirmColor;
  IconData? icon;

  switch (type) {
    case DialogType.success:
      confirmColor = AppColor().green;
      icon = Icons.check_circle;
      break;
    case DialogType.error:
      confirmColor = AppColor().red;
      icon = Icons.error;
      break;
    case DialogType.warning:
      confirmColor = AppColor().orange;
      icon = Icons.warning;
      break;
    default:
      confirmColor = AppColor().red;
      icon = null;
  }

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, __) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: Theme.of(context).cardColor,
            title: (title.isNotEmpty || icon != null)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Icon(
                          icon,
                          size: 50,
                          color: confirmColor,
                        ),
                      if (icon != null && title.isNotEmpty) const SizedBox(height: 8),
                      if (title.isNotEmpty)
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSize(context).mediumLargeSize,
                            fontFamily: 'EN-BOLD',
                          ),
                        ),
                    ],
                  )
                : null,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFontSize(Get.context!).subTitleSize,
                      fontFamily: 'EN-REGULAR',
                    ),
                  ),
                  if (controller != null) ...[
                    const SizedBox(height: 16),
                    customTextField(
                      "Password",
                      false,
                      null,
                      controller: controller,
                    ),
                  ],
                ],
              ),
            ),
            actionsPadding: EdgeInsets.only(
              bottom: 16,
              left: kIsWeb ? 30 : 16,
              right: kIsWeb ? 30 : 16,
            ),
            actions: [
              Row(
                children: [
                  if (showCancel)
                    Expanded(
                      child: CustomButton(
                        text: "Cancel",
                        onPressed: () => Navigator.pop(context),
                        // backgroundColor: Colors.grey.shade50,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                        // textColor: AppColor().black,
                        textColor: Theme.of(context).textTheme.bodyLarge?.color ?? AppColor().black,
                        borderRadius: 14,
                      ),
                    ),
                  if (showCancel) const SizedBox(width: 15),
                  Expanded(
                    child: CustomButton(
                      text: confirmText ?? 'OK',
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      backgroundColor: confirmColor,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
