// // --- BACKGROUND PALETTE SHEET ---
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// void showPaletteSheet({
//   required BuildContext context,
//   required Function(Color) onColorSelected,
// }) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//     builder: (context) => Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(bottom: 10),
//             decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text("Cancel",
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: context.isPhone ? 16 : 18,
//                         fontFamily: 'EN-REGULAR',
//                       ))),
//               Text("Note Background",
//                   style: TextStyle(
//                     fontSize: context.isPhone ? 16 : 18,
//                     fontFamily: 'EN-BOLD',
//                   )),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Wrap(
//             spacing: 15,
//             runSpacing: 15,
//             children: [
//               Colors.white,
//               // const Color(0xFFFFF9C4),
//               // const Color(0xFFF8BBD0),
//               // const Color(0xFFE1F5FE),
//               // const Color(0xFFE8F5E9),
//               // const Color(0xFFFFE0B2),
//               // // More soft pastel colors
//               // const Color(0xFFEDE7F6), // Light purple
//               // const Color(0xFFD1C4E9), // Lavender
//               // const Color(0xFFF3E5F5), // Soft violet
//               // const Color(0xFFFFEBEE), // Very light red
//               // const Color(0xFFFFF3E0), // Cream orange
//               // const Color(0xFFE0F7FA), // Cyan light
//               // const Color(0xFFF1F8E9), // Lime light
//               // const Color(0xFFFFFDE7), // Very soft yellow
//               // const Color(0xFFECEFF1), // Light grey
//               // const Color(0xFFD7CCC8), // Light brown

//               const Color(0xFFFFF1F0),
//               const Color(0xFFFFF7E6),
//               const Color(0xFFFFFBEB),
//               const Color(0xFFF0FFF4),
//               const Color(0xFFE6FFFA),
//               const Color(0xFFF0F5FF),
//               const Color(0xFFF9F0FF),
//               const Color(0xFFFFE4E1),
//               const Color(0xFFFFEFD5),
//               const Color(0xFFFFF0F5),
//               const Color(0xFFF0FFFF),
//               const Color(0xFFF5FFFA),

//               const Color(0xFFEAF4F4),
//               const Color(0xFFDFF5E1),
//               const Color(0xFFF7FBEF),
//               const Color(0xFFE3F6F5),
//               const Color(0xFFF6FFF8),
//               const Color(0xFFE8F8F5),
//               const Color(0xFFF0FDF4),
//               const Color(0xFFE6F7FF),

//               const Color(0xFFFFE4F0),
//               const Color(0xFFFFF0F6),
//               const Color(0xFFFFF5E4),
//               const Color(0xFFE4F9FF),
//               const Color(0xFFEAF0FF),
//               const Color(0xFFF4E4FF),
//               const Color(0xFFFFE4E4),

//               const Color(0xFFFAFAFA),
//               const Color(0xFFF7F7F7),
//               const Color(0xFFF5F5F5),
//               const Color(0xFFF3F4F6),
//               const Color(0xFFF1F5F9),
//               const Color(0xFFF8FAFC),
//             ]
//                 .map((color) => GestureDetector(
//                       onTap: () {
//                         onColorSelected(color);
//                         Navigator.pop(context);
//                       },
//                       child: CircleAvatar(
//                         backgroundColor: color,
//                         radius: 25,
//                         child: Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12))),
//                       ),
//                     ))
//                 .toList(),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     ),
//   );
// }

// // --- BACKGROUND PALETTE SHEET ---
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// void showPaletteSheet({
//   required BuildContext context,
//   required Function(Color) onColorSelected,
//   Color? selectedColor,
// }) {
//   final colors = [
//     Colors.white,
//     const Color(0xFFFFF1F0),
//     const Color(0xFFFFF7E6),
//     const Color(0xFFFFFBEB),
//     const Color(0xFFF0FFF4),
//     const Color(0xFFE6FFFA),
//     const Color(0xFFF0F5FF),
//     const Color(0xFFF9F0FF),
//     const Color(0xFFFFE4E1),
//     const Color(0xFFFFEFD5),
//     const Color(0xFFFFF0F5),
//     const Color(0xFFF0FFFF),
//     const Color(0xFFF5FFFA),
//     const Color(0xFFEAF4F4),
//     const Color(0xFFDFF5E1),
//     const Color(0xFFF7FBEF),
//     const Color(0xFFE3F6F5),
//     const Color(0xFFF6FFF8),
//     const Color(0xFFE8F8F5),
//     const Color(0xFFF0FDF4),
//     const Color(0xFFE6F7FF),
//   ];

//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) => DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.6,
//       maxChildSize: 0.9,
//       minChildSize: 0.4,
//       builder: (context, scrollController) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: SingleChildScrollView(
//             controller: scrollController,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// Drag indicator
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     margin: const EdgeInsets.only(bottom: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),

//                 /// Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: Text("Cancel",
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontSize: context.isPhone ? 16 : 18,
//                               fontFamily: 'EN-REGULAR',
//                             ))),
//                     Text("Note Background",
//                         style: TextStyle(
//                           fontSize: context.isPhone ? 16 : 18,
//                           fontFamily: 'EN-BOLD',
//                         )),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 /// Color grid
//                 GridView.builder(
//                   controller: scrollController,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: colors.length,
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: context.isPhone ? 4 : 6,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 1.6,
//                   ),
//                   itemBuilder: (context, index) {
//                     final color = colors[index];
//                     final isSelected = selectedColor == color;

//                     return GestureDetector(
//                       onTap: () {
//                         onColorSelected(color);
//                         Navigator.pop(context);
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: color,
//                           border: Border.all(
//                             color: isSelected ? Colors.blue : Colors.black12,
//                             width: isSelected ? 2 : 1,
//                           ),
//                         ),
//                         child: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }
