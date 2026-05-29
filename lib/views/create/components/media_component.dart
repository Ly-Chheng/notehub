// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/core/utils/app_fonts.dart';
// import 'package:project_structure/widgets/sheet_header.dart';

// void showMediaSheet({
//   required BuildContext context,
//   required Function(File image) onImageSelected,
// }) {
//   final ImagePicker picker = ImagePicker();

//   Future<void> pick(ImageSource source) async {
//     try {
//       final XFile? file = await picker.pickImage(
//         source: source,
//         imageQuality: 70,
//       );

//       if (file != null && context.mounted) {
//         onImageSelected(File(file.path));
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       debugPrint("Error picking image: $e");
//     }
//   }

//   showModalBottomSheet(
//     context: context,
//     constraints: BoxConstraints(maxWidth: double.infinity),
//     backgroundColor: Theme.of(context).cardColor,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) => SafeArea(
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SheetHeader(
//                 title: "Add Media",
//               ),
//               const SizedBox(height: 20),
//               // ListTile(
//               //   leading: Icon(
//               //     Icons.camera_alt_outlined,
//               //     color: AppColor().primaryColor,
//               //   ),
//               //   title: Text("Take a Photo",
//               //       style: TextStyle(
//               //         fontSize: context.isPhone ? 16 : 18,
//               //         fontFamily: 'EN-REGULAR',
//               //       )),
//               //   onTap: () => pick(ImageSource.camera),
//               // ),
//               // ListTile(
//               //   leading: Icon(
//               //     Icons.camera_alt_outlined,
//               //     color: AppColor().primaryColor,
//               //   ),
//               //   title: Text("Select from Gallery",
//               //       style: TextStyle(
//               //         fontSize: context.isPhone ? 16 : 18,
//               //         fontFamily: 'EN-REGULAR',
//               //       )),
//               //   onTap: () => pick(ImageSource.gallery),
//               // ),
//               _buildActionItem(
//                 context,
//                 icon: Icons.camera_alt_outlined,
//                 color: AppColor().primaryColor,
//                 title: "Take a Photo",
//                 onTap: () => pick(ImageSource.camera),
//               ),
//               _divider(context),
//               _buildActionItem(
//                 context,
//                 icon: Icons.image_outlined,
//                 color: AppColor().primaryColor,
//                 title: "Select from Gallery",
//                 // isDestructive: true,
//                 onTap: () => pick(ImageSource.gallery),
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Widget _buildActionItem(
//   BuildContext context, {
//   required IconData icon,
//   required String title,
//   required VoidCallback onTap,
//   required Color color,
//   bool isDestructive = false,
// }) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//     child: Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(14),
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(icon, size: 24, color: color),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: AppFontSize(context).descriptionLargeSize,
//                   fontFamily: rengular,
//                   color: isDestructive ? AppColor().red : null,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Widget _divider(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16),
//     child: Divider(
//       height: 1,
//       color: Colors.grey.withValues(alpha: 0.08),
//     ),
//   );
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/multi_style.dart';

void showMediaSheet({
  required BuildContext context,
  required Function(File mediaFile, String type) onMediaSelected,
}) {
  final ImagePicker picker = ImagePicker();

  // Handles image picking (Camera or Gallery)
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (file != null && context.mounted) {
        onMediaSelected(File(file.path), 'image');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // Handles video picking (Camera or Gallery)
  Future<void> pickVideo(ImageSource source) async {
    try {
      final XFile? file = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (file != null && context.mounted) {
        onMediaSelected(File(file.path), 'video');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  showModalBottomSheet(
    context: context,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(
              title: "Add Media",
            ),
            const SizedBox(height: 15),
            _buildActionItem(
              context,
              icon: Icons.camera_alt_outlined,
              color: AppColor().primaryColor,
              title: "Take a Photo",
              onTap: () => pickImage(ImageSource.camera),
            ),
            _divider(context),
            _buildActionItem(
              context,
              icon: Icons.image_outlined,
              color: AppColor().primaryColor,
              title: "Select Image from Gallery",
              onTap: () => pickImage(ImageSource.gallery),
            ),
            _divider(context),
            const SizedBox(height: 5),
            _buildActionItem(
              context,
              icon: Icons.videocam_outlined,
              color: AppColor().primaryColor,
              title: "Record a Video",
              onTap: () => pickVideo(ImageSource.camera),
            ),
            _divider(context),
            _buildActionItem(
              context,
              icon: Icons.video_library_outlined,
              color: AppColor().primaryColor,
              title: "Select Video from Gallery",
              onTap: () => pickVideo(ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  required Color color,
  bool isDestructive = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppFontSize(context).descriptionLargeSize,
                  fontFamily: rengular,
                  color: isDestructive ? AppColor().red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _divider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(
      height: 1,
      color: Colors.grey.withValues(alpha: 0.08),
    ),
  );
}
