// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/core/utils/app_color.dart';

// Future<void> showConfirmDeleteDialog({
//   required BuildContext context,
//   required String title,
//   String? confirmText,
//   required String subTitle,
//   required VoidCallback onConfirm,
// }) {
//   return showGeneralDialog(
//     context: context,
//     barrierDismissible: true,
//     barrierLabel: '',
//     transitionDuration: const Duration(milliseconds: 200),
//     pageBuilder: (_, __, ___) => const SizedBox.shrink(),
//     transitionBuilder: (context, animation, _, __) {
//       return ScaleTransition(
//         scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
//         child: FadeTransition(
//           opacity: animation,
//           child: AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             // backgroundColor: AppColor().backgroundColor,
//             backgroundColor: Colors.white,
//             title: Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: context.isPhone ? 18 : 20,
//                 color: AppColor().black,
//                 fontFamily: 'EN-BOLD',
//                 fontWeight: FontWeight.bold,

//               ),
//             ),
//             content: Text(
//               subTitle,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: context.isPhone ? 16 : 18,
//                 color: AppColor().black,
//                 fontFamily: 'EN-REGULAR',
//               ),
//             ),
//             actionsPadding: const EdgeInsets.only(bottom: 16, left: kIsWeb ? 30 : 16, right: kIsWeb ? 30 : 16),
//             actions: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey.shade50,
//                         padding: const EdgeInsets.symmetric(
//                           vertical: kIsWeb ? 16 : 10,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         shadowColor: Colors.transparent,
//                       ),
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(
//                           fontSize: context.isPhone ? 16 : 18,
//                           color: AppColor().black,
//                           fontFamily: 'EN-REGULAR',
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         onConfirm();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         padding: const EdgeInsets.symmetric(
//                           vertical: kIsWeb ? 16 : 10,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         shadowColor: Colors.transparent,
//                       ),
//                       child: Text(
//                         confirmText ?? 'Delete',
//                         style: TextStyle(
//                           fontSize: context.isPhone ? 16 : 18,
//                           color: Colors.white,
//                           fontFamily: 'EN-REGULAR',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

Future<void> showConfirmDeleteDialog({
  required BuildContext context,
  required String title,
  required String subTitle,
  String? confirmText,
  required VoidCallback onConfirm,

  /// Optional TextField
  TextEditingController? controller,
  bool obscureText = false,
  String? hintText,
}) {
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
            backgroundColor: Colors.white,

            /// TITLE
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.isPhone ? 18 : 20,
                color: AppColor().black,
                fontFamily: 'EN-BOLD',
                fontWeight: FontWeight.bold,
              ),
            ),

            /// CONTENT
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.isPhone ? 16 : 18,
                    color: AppColor().black,
                    fontFamily: 'EN-REGULAR',
                  ),
                ),

                /// TEXT FIELD (Optional)
                if (controller != null) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      hintText: hintText ?? "Enter text",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            /// BUTTONS
            actionsPadding: EdgeInsets.only(
              bottom: 16,
              left: kIsWeb ? 30 : 16,
              right: kIsWeb ? 30 : 16,
            ),
            actions: [
              Row(
                children: [
                  /// CANCEL
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

                  const SizedBox(width: 10),

                  /// CONFIRM
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(
                          vertical: kIsWeb ? 16 : 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        confirmText ?? 'Delete',
                        style: TextStyle(
                          fontSize: context.isPhone ? 16 : 18,
                          color: Colors.white,
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
