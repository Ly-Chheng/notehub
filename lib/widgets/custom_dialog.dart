import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

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
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Theme.of(context).cardColor,
            title: Column(
              children: [
                if (icon != null) Icon(icon, size: 50, color: confirmColor),
                if (icon != null) const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.isPhone ? 18 : 20,
                    fontFamily: 'EN-BOLD',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.isPhone ? 16 : 18,
                      fontFamily: 'EN-REGULAR',
                    ),
                  ),
                  if (controller != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: controller,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: hintText ?? "Enter text",
                          hintStyle: TextStyle(
                            color: AppColor().gray,
                            fontFamily: 'EN-REGULAR',
                            fontFamilyFallback: const ['KH-REGULAR'],
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
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
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade50,
                          padding: EdgeInsets.symmetric(
                            vertical: kIsWeb ? 16 : 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: context.isPhone ? 16 : 18,
                            color: AppColor().black,
                            fontFamily: 'EN-REGULAR',
                          ),
                        ),
                      ),
                    ),
                  if (showCancel) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        padding: EdgeInsets.symmetric(
                          vertical: kIsWeb ? 16 : 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        confirmText ?? 'OK',
                        style: TextStyle(
                          fontSize: context.isPhone ? 16 : 18,
                          color: AppColor().white,
                          fontFamily: 'EN-REGULAR',
                        ),
                      ),
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
