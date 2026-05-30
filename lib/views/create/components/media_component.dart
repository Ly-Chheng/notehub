import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/multi_style.dart';

void showMediaSheet({
  required BuildContext context,
  required Function(File mediaFile, String type) onMediaSelected,
}) {
  final ImagePicker picker = ImagePicker();

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

  // Future<void> pickFile() async {
  //   try {
  //     // FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     FilePickerResult? result = await FilePicker.pickFiles(
  //       type: FileType.any, // You can change this to FileType.custom and specify allowedExtensions if needed
  //     );

  //     if (result != null && result.files.single.path != null && context.mounted) {
  //       File file = File(result.files.single.path!);
  //       onMediaSelected(file, 'file'); // Passes 'file' type to callback
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     debugPrint("Error picking file: $e");
  //   }
  // }
  Future<void> pickFile() async {
    try {
      // FIX: Removed '.platform' and calling 'pickFiles()' directly
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'zip',
          'rar',
        ],
      );

      if (result != null && result.files.single.path != null && context.mounted) {
        final file = File(result.files.single.path!);

        onMediaSelected(file, 'file');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
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
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(
              title: "Add Media",
            ),
            const SizedBox(height: 15),
            buildActionItem(
              context,
              icon: Icons.camera_alt_outlined,
              color: AppColor().primaryColor,
              title: "Take a Photo",
              onTap: () => pickImage(ImageSource.camera),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.image_outlined,
              color: AppColor().primaryColor,
              title: "Select Image from Gallery",
              onTap: () => pickImage(ImageSource.gallery),
            ),
            divider(context),
            const SizedBox(height: 5),
            buildActionItem(
              context,
              icon: Icons.videocam_outlined,
              color: AppColor().primaryColor,
              title: "Record a Video",
              onTap: () => pickVideo(ImageSource.camera),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.video_library_outlined,
              color: AppColor().primaryColor,
              title: "Select Video from Gallery",
              onTap: () => pickVideo(ImageSource.gallery),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.attach_file_outlined,
              color: AppColor().primaryColor,
              title: "Attach File",
              onTap: pickFile,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/widgets/multi_style.dart';

// void showMediaSheet({
//   required BuildContext context,
//   required Function(List<File> mediaFiles, String type) onMediaSelected,
// }) {
//   final ImagePicker picker = ImagePicker();

//   // Helper to show a quick choice dialog for combined actions
//   Future<String?> _showTypeChoiceDialog(BuildContext context, String title) {
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: const Text("Would you like to capture/select a Photo or a Video?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, 'image'),
//             child: const Text("Photo / Image"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, 'video'),
//             child: const Text("Video"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Handles Camera (Photo or Video)
//   Future<void> handleCameraAction() async {
//     final type = await _showTypeChoiceDialog(context, "Camera");
//     if (type == null || !context.mounted) return;

//     try {
//       XFile? file;
//       if (type == 'image') {
//         file = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
//       } else {
//         file = await picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(minutes: 5));
//       }

//       if (file != null && context.mounted) {
//         onMediaSelected([File(file.path)], type);
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       debugPrint("Error capturing camera media: $e");
//     }
//   }

//   // Handles Gallery (Multiple Images or Single Video)
//   Future<void> handleGalleryAction() async {
//     final type = await _showTypeChoiceDialog(context, "Gallery");
//     if (type == null || !context.mounted) return;

//     try {
//       if (type == 'image') {
//         final List<XFile> files = await picker.pickMultiImage(imageQuality: 70);
//         if (files.isNotEmpty && context.mounted) {
//           onMediaSelected(files.map((f) => File(f.path)).toList(), 'image');
//           Navigator.pop(context);
//         }
//       } else {
//         final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
//         if (file != null && context.mounted) {
//           onMediaSelected([File(file.path)], 'video');
//           Navigator.pop(context);
//         }
//       }
//     } catch (e) {
//       debugPrint("Error picking gallery media: $e");
//     }
//   }

//   showModalBottomSheet(
//     context: context,
//     constraints: const BoxConstraints(maxWidth: double.infinity),
//     backgroundColor: Theme.of(context).cardColor,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) => SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SheetHeader(
//               title: "Add Media",
//             ),
//             const SizedBox(height: 15),
//             buildActionItem(
//               context,
//               icon: Icons.image_outlined,
//               color: AppColor().primaryColor,
//               title: "Image Gallery or  Video Gallery",
//               onTap: () {
//                 Get.back();
//                 handleGalleryAction();
//               },
//             ),
//             divider(context),
//             buildActionItem(
//               context,
//               icon: Icons.camera_alt_outlined,
//               color: AppColor().primaryColor,
//               title: "Take Photo or Record Video",
//               onTap: () {
//                 Get.back();
//                 handleCameraAction();
//               },
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     ),
//   );
// }
