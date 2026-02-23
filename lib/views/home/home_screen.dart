// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/views/create/create_note_screen.dart';
// import 'package:project_structure/widgets/custom_text_field.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({
//     super.key,
//   });

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   bool isGrid = false;

//   final List<Map<String, dynamic>> folders = [
//     {"icon": Icons.folder, "title": "My Noted", "count": "10", "color": Colors.blue},
//     {"icon": Icons.folder, "title": "Personal", "count": "15", "color": Colors.blue},
//     {"icon": Icons.folder, "title": "Assingments", "count": "15", "color": Colors.blue},
//     {"icon": Icons.folder, "title": "Work", "count": "1", "color": Colors.blue},
//     {"icon": Icons.delete, "title": "Recently Deleted", "count": "1", "color": Colors.red},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FB),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(isGrid ? Icons.list : Icons.grid_view),
//             onPressed: () {
//               setState(() {
//                 isGrid = !isGrid;
//               });
//             },
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),

//             buildStandardField(
//               "Search",
//               prefixIcon: Icons.search,
//             ),

//             const SizedBox(height: 25),

//             const Text(
//               'Folder',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 15),

//             /// List or Grid
//             Expanded(
//               child: isGrid ? _buildGrid() : _buildList(),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColor().primaryColor,
//         foregroundColor: Colors.white,
//         onPressed: () {
//           setState(() {
//             Get.to(CreateNoteScreen());
//           });
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   /// List View
//   Widget _buildList() {
//     return ListView.builder(
//       itemCount: folders.length,
//       itemBuilder: (context, index) {
//         final item = folders[index];
//         return _buildFolderItem(
//           item["icon"],
//           item["title"],
//           item["count"],
//           item["color"],
//         );
//       },
//     );
//   }

//   /// Grid View
//   Widget _buildGrid() {
//     return GridView.builder(
//       itemCount: folders.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         childAspectRatio: 1.4,
//       ),
//       itemBuilder: (context, index) {
//         final item = folders[index];
//         return _buildGridItem(
//           item["icon"],
//           item["title"],
//           item["count"],
//           item["color"],
//         );
//       },
//     );
//   }

//   /// List item
//   Widget _buildFolderItem(IconData icon, String title, String count, Color iconColor) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: iconColor, size: 28),
//         title: Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
//         ),
//         trailing: Text(
//           count,
//           style: const TextStyle(color: Colors.grey),
//         ),
//       ),
//     );
//   }

//   /// Grid item
//   Widget _buildGridItem(IconData icon, String title, String count, Color iconColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(icon, color: iconColor, size: 35),
//               Text(count, style: const TextStyle(color: Colors.grey)),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/views/create/folder_screen.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isGrid = false;

  final List<Map<String, dynamic>> folders = [
    {"icon": Icons.folder, "title": "My Notes", "count": "10", "color": Colors.blue},
    {"icon": Icons.folder, "title": "Personal", "count": "15", "color": Colors.blue},
    {"icon": Icons.folder, "title": "Assignments", "count": "15", "color": Colors.blue},
    {"icon": Icons.folder, "title": "Work", "count": "1", "color": Colors.blue},
    {"icon": Icons.delete, "title": "Recently Deleted", "count": "1", "color": Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   centerTitle: false,
      //   title: const Text(
      //     "Noted",
      //     style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(isGrid ? Icons.list : Icons.grid_view, color: Colors.blue),
      //       onPressed: () => setState(() => isGrid = !isGrid),
      //     )
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            /// Reusable Search Field
            buildStandardField(
              "Search",
              prefixIcon: Icons.search,
            ),

            const SizedBox(height: 25),

            const Text(
              'Folder',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            /// List or Grid View
            Expanded(
              child: isGrid ? _buildGrid() : _buildList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor().primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => Get.to(() => const CreateNoteScreen()),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  /// List View Logic
  Widget _buildList() {
    return ListView.builder(
      itemCount: folders.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = folders[index];
        return _buildFolderItem(
          item["icon"],
          item["title"],
          item["count"],
          item["color"],
        );
      },
    );
  }

  /// Grid View Logic
  Widget _buildGrid() {
    return GridView.builder(
      itemCount: folders.length,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final item = folders[index];
        return _buildGridItem(
          item["icon"],
          item["title"],
          item["count"],
          item["color"],
        );
      },
    );
  }

  /// List Item UI
  Widget _buildFolderItem(IconData icon, String title, String count, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        onTap: () => Get.to(() => const FolderScreen()), // Navigation
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(count, style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Grid Item UI
  Widget _buildGridItem(IconData icon, String title, String count, Color iconColor) {
    return GestureDetector(
      onTap: () => Get.to(() => const FolderScreen()), // Navigation
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 35),
                Text(
                  count,
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}