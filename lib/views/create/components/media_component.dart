// import 'package:flutter/material.dart';

// void showMediaSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//     builder: (context) => Padding(
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Center(
//             child: Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//           Row(children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red)))]),
//           ListTile(
//             leading: const Icon(Icons.camera_alt_outlined),
//             title: const Text("Take a photo"),
//             onTap: () {
//               // Handle camera action
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.image_outlined),
//             title: const Text("Select from gallery"),
//             onTap: () {
//               // Handle gallery selection
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showMediaSheet(
  BuildContext context,
  Function(File image) onImageSelected,
) {
  final ImagePicker picker = ImagePicker();

  Future<void> pick(ImageSource source) async {
    final XFile? file = await picker.pickImage(source: source);

    if (file != null) {
      Navigator.pop(context);
      onImageSelected(File(file.path));
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, color: Colors.grey[300]),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text("Take photo"),
            onTap: () => pick(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text("Gallery"),
            onTap: () => pick(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}