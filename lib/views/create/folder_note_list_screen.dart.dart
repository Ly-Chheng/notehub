// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/views/create/create_note_screen.dart';
// // Import your custom widgets (AppColor, customAppBar, etc.) here

// class FolderNoteListScreen extends StatefulWidget {
//   const FolderNoteListScreen({super.key});

//   @override
//   State<FolderNoteListScreen> createState() => _FolderNoteListScreenState();
// }

// class _FolderNoteListScreenState extends State<FolderNoteListScreen> {
//   bool isGridView = false;
//   bool isSelectionMode = false;
//   Set<int> selectedIndexes = {};

//   // Reference to our opened box
//   final Box noteBox = Hive.box('student_notes');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FE),
//       appBar: AppBar(title: const Text("My Notes")), // Use your customAppBar here

//       // ValueListenableBuilder listens to the box for ANY changes
//       body: ValueListenableBuilder(
//         valueListenable: noteBox.listenable(),
//         builder: (context, Box box, _) {
//           // Get all data from local storage
//           final notes = box.values.toList().cast<Map>().reversed.toList();

//           if (notes.isEmpty) {
//             return const Center(child: Text("No notes saved locally."));
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 const TextField(decoration: InputDecoration(hintText: "Search", prefixIcon: Icon(Icons.search))),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: isGridView ? _buildGridView(notes) : _buildListView(notes),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Get.to(() => const CreateNoteScreen()),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildListView(List notes) {
//     return ListView.builder(
//       itemCount: notes.length,
//       itemBuilder: (context, index) {
//         final note = notes[index];
//         return _buildSlidableNote(index, note);
//       },
//     );
//   }

//   Widget _buildSlidableNote(int index, dynamic note) {
//     return Slidable(
//       endActionPane: ActionPane(
//         motion: const ScrollMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (context) {
//               // Delete from local storage using the correct key
//               int actualKeyIndex = noteBox.length - 1 - index;
//               noteBox.deleteAt(actualKeyIndex);
//             },
//             backgroundColor: Colors.red,
//             icon: Icons.delete,
//           ),
//         ],
//       ),
//       child: Card(
//         child: ListTile(
//           title: Text(note['title'] ?? ""),
//           subtitle: Text(note['subtitle'] ?? ""),
//           trailing: Text(note['date'] ?? ""),
//         ),
//       ),
//     );
//   }

//   Widget _buildGridView(List notes) {
//     return GridView.builder(
//       itemCount: notes.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//       itemBuilder: (context, index) => Card(child: Text(notes[index]['title'])),
//     );
//   }
// }

//version 1 with crate and delete features, plus better UI. You can choose which version to use or combine features as needed.
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/views/create/create_note_screen.dart';
// import 'package:project_structure/widgets/custom_appbar.dart';
// import 'package:project_structure/widgets/custom_text_field.dart';
// // Import your custom widgets (AppColor, customAppBar, etc.) here

// class FolderNoteListScreen extends StatefulWidget {
//   const FolderNoteListScreen({super.key});

//   @override
//   State<FolderNoteListScreen> createState() => _FolderNoteListScreenState();
// }

// class _FolderNoteListScreenState extends State<FolderNoteListScreen> {
//   bool isGridView = false;
//   bool isSelectionMode = false;
//   Set<int> selectedIndexes = {};

//   // Reference to our opened box
//   final Box noteBox = Hive.box('student_notes');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FE),

//       appBar: customAppBar(
//           title: isSelectionMode ? "${selectedIndexes.length} Selected" : "Folder",
//           titleColor: AppColor().primaryColor,
//           context: context,
//           leadingColor: AppColor().primaryColor,
//           leading: isSelectionMode
//               ? IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () {
//                     setState(() {
//                       isSelectionMode = false;
//                       selectedIndexes.clear();
//                     });
//                   },
//                 )
//               : null,
//           actions: [
//             Center(child: Text("My Note", style: TextStyle(color: AppColor().primaryColor, fontSize: 16, fontFamily: 'EN-REGULAR'))),
//             PopupMenuButton<String>(
//               icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//               offset: const Offset(0, 50),
//               color: Colors.white,
//               onSelected: (value) => (value),
//               itemBuilder: (context) => [],
//             ),
//           ]),

//       // ValueListenableBuilder listens to the box for ANY changes
//       body: ValueListenableBuilder(
//         valueListenable: noteBox.listenable(),
//         builder: (context, Box box, _) {
//           // Get all data from local storage
//           final notes = box.values.toList().cast<Map>().reversed.toList();

//           if (notes.isEmpty) {
//             return const Center(child: Text("No notes saved locally."));
//           }

//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Column(
//               children: [
//                 buildStandardField(
//                   "Search",
//                   prefixIcon: Icons.search,
//                 ),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: isGridView ? _buildGridView(notes) : _buildListView(notes),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),

//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColor().primaryColor,
//         foregroundColor: Colors.white,
//         onPressed: () => Get.to(() => const CreateNoteScreen()),
//         child: const Icon(Icons.add, size: 30),
//       ),
//     );
//   }

//   Widget _buildListView(List notes) {
//     return ListView.builder(
//       itemCount: notes.length,
//       itemBuilder: (context, index) {
//         final note = notes[index];
//         return _buildSlidableNote(index, note);
//       },
//     );
//   }

//   Widget _buildSlidableNote(int index, dynamic note) {
//     return Slidable(
//       endActionPane: ActionPane(
//         motion: const ScrollMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (context) {
//               // Delete from local storage using the correct key
//               int actualKeyIndex = noteBox.length - 1 - index;
//               noteBox.deleteAt(actualKeyIndex);
//             },
//             backgroundColor: Colors.red,
//             icon: Icons.delete,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           padding: const EdgeInsets.all(15),
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(note['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                   const SizedBox(height: 5),
//                   Text(note['subtitle'] ?? "", style: const TextStyle(color: Colors.black54, fontSize: 16)),
//                   const SizedBox(height: 8),
//                   Text(note['date'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 11)),
//                 ],
//               ),
//               Container(
//                 width: 70,
//                 height: 70,
//                 margin: const EdgeInsets.only(left: 15),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                   image: const DecorationImage(
//                     image: NetworkImage("https://via.placeholder.com/150"),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGridView(List notes) {
//     return GridView.builder(
//       itemCount: notes.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//       itemBuilder: (context, index) => Card(child: Text(notes[index]['title'])),
//     );
//   }
// }

//version 2 with pin and edit features, not have UI. You can choose which version to use or combine features as needed.
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:get/get.dart';
// // Import your custom widgets (AppColor, customAppBar, etc.) here

// class FolderNoteListScreen extends StatefulWidget {
//   const FolderNoteListScreen({super.key});

//   @override
//   State<FolderNoteListScreen> createState() => _FolderNoteListScreenState();
// }

// class _FolderNoteListScreenState extends State<FolderNoteListScreen> {
//   bool isGridView = false;
//   bool isSelectionMode = false;
//   Set<int> selectedIndexes = {};

//   // Reference to our opened box
//   final Box noteBox = Hive.box('student_notes');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FE),
//       appBar: AppBar(title: const Text("My Notes")), // Use your customAppBar here

//       // ValueListenableBuilder listens to the box for ANY changes
//       body: ValueListenableBuilder(
//         valueListenable: noteBox.listenable(),
//         builder: (context, Box box, _) {
//           // Get all data from local storage
//           final notes = box.values.toList().cast<Map>().reversed.toList();

//           if (notes.isEmpty) {
//             return const Center(child: Text("No notes saved locally."));
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 const TextField(decoration: InputDecoration(hintText: "Search", prefixIcon: Icon(Icons.search))),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: isGridView ? _buildGridView(notes) : _buildListView(notes),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Get.to(() => const CreateNoteScreen()),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildListView(List notes) {
//     return ListView.builder(
//       itemCount: notes.length,
//       itemBuilder: (context, index) {
//         final note = notes[index];
//         return _buildSlidableNote(index, note);
//       },
//     );
//   }

//   Widget _buildSlidableNote(int index, dynamic note) {
//     return Slidable(
//       endActionPane: ActionPane(
//         motion: const ScrollMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (context) {
//               // Delete from local storage using the correct key
//               int actualKeyIndex = noteBox.length - 1 - index;
//               noteBox.deleteAt(actualKeyIndex);
//             },
//             backgroundColor: Colors.red,
//             icon: Icons.delete,
//           ),
//         ],
//       ),
//       child: Card(
//         child: ListTile(
//           title: Text(note['title'] ?? ""),
//           subtitle: Text(note['subtitle'] ?? ""),
//           trailing: Text(note['date'] ?? ""),
//         ),
//       ),
//     );
//   }

//   Widget _buildGridView(List notes) {
//     return GridView.builder(
//       itemCount: notes.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//       itemBuilder: (context, index) => Card(child: Text(notes[index]['title'])),
//     );
//   }
// }
//version 2 with pin and edit features, plus better UI. You can choose which version to use or combine features as needed.
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class FolderNoteListScreen extends StatefulWidget {
  const FolderNoteListScreen({super.key});

  @override
  State<FolderNoteListScreen> createState() => _FolderNoteListScreenState();
}

class _FolderNoteListScreenState extends State<FolderNoteListScreen> {
  final Box noteBox = Hive.box('student_notes');
  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(title: "Student Notes", titleColor: AppColor().primaryColor, context: context, leadingColor: AppColor().primaryColor, actions: [
        Center(child: Text("My Note", style: TextStyle(color: AppColor().primaryColor, fontSize: 16, fontFamily: 'EN-REGULAR'))),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          offset: const Offset(0, 50),
          color: Theme.of(context).cardColor,
          onSelected: (value) => _handleMenuSelection(value),
          itemBuilder: (context) => [
            _buildPopupItem('Select Notes', Icons.radio_button_unchecked),
          ],
        ),
      ]),
      body: ValueListenableBuilder(
        valueListenable: noteBox.listenable(),
        builder: (context, Box box, _) {
          // Get data and keys
          List<dynamic> keys = box.keys.toList();
          List<dynamic> values = box.values.toList();

          // 1. Sort: Pinned first, then by date (optional)
          // To keep it simple, we map keys to values so we don't lose the index
          List<MapEntry<int, dynamic>> notesList = [];
          for (int i = 0; i < keys.length; i++) {
            notesList.add(MapEntry(i, values[i]));
          }

          // Sort logic: Pinned notes (true) come before unpinned (false)
          notesList.sort((a, b) {
            bool aPinned = a.value['isPinned'] ?? false;
            bool bPinned = b.value['isPinned'] ?? false;
            if (aPinned && !bPinned) return -1;
            if (!aPinned && bPinned) return 1;
            return 0; // Keep original order otherwise
          });

          if (notesList.isEmpty) return const Center(child: Text("No notes."));

          return ListView.builder(
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              final entry = notesList[index];
              return _buildSlidableNote(entry.key, entry.value);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor().primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => Get.to(() => const CreateNoteScreen()),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildSlidableNote(int actualBoxIndex, dynamic note) {
    bool isPinned = note['isPinned'] ?? false;

    // Retrieve formatting from Hive data
    // 1. Retrieve Text Formatting
    bool noteIsBold = note['isBold'] ?? false;
    bool noteIsItalic = note['isItalic'] ?? false;
    bool noteIsUnderlined = note['isUnderlined'] ?? false;
    bool noteIsStrikethrough = note['isStrikethrough'] ?? false;

    // 2. Retrieve Colors
    int? colorValue = note['colorValue'];
    Color noteColor = colorValue != null ? Color(colorValue) : Colors.black;
    final bgColor = Color(note['bgColorValue'] ?? 0xFFFFFFFF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Slidable(
        key: ValueKey(actualBoxIndex),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.9,
          children: [
            // PIN ACTION
            SlidableAction(
              onPressed: (context) {
                final updatedNote = Map<String, dynamic>.from(note);
                updatedNote['isPinned'] = !isPinned;
                noteBox.putAt(actualBoxIndex, updatedNote);
              },
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              label: isPinned ? 'Unpin' : 'Pin',
            ),
            // UPDATE ACTION
            SlidableAction(
              onPressed: (context) {
                Get.to(() => CreateNoteScreen(
                      isEditing: true,
                      noteKey: actualBoxIndex,
                      existingNote: note,
                    ));
              },
              backgroundColor: Colors.blue,
              icon: Icons.edit,
              label: 'Edit',
            ),
            // DELETE ACTION
            SlidableAction(
              onPressed: (context) => noteBox.deleteAt(actualBoxIndex),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (isPinned) const Icon(Icons.push_pin, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note['title'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontFamily: 'EN-BOLD')),
                    const SizedBox(height: 10),
                    Text(
                      note['subtitle'] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'EN-REGULAR',
                        // --- APPLY FORMATTING HERE ---
                        color: noteColor.withOpacity(0.8),
                        fontWeight: noteIsBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle: noteIsItalic ? FontStyle.italic : FontStyle.normal,
                        // decoration: noteIsUnderlined ? TextDecoration.underline : TextDecoration.none,
                        decoration: TextDecoration.combine([
                          if (noteIsUnderlined) TextDecoration.underline,
                          if (noteIsStrikethrough) TextDecoration.lineThrough,
                        ]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(note['date'] ?? "", style: const TextStyle(fontSize: 12, fontFamily: 'EN-REGULAR')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// POPUP ITEM
  PopupMenuItem<String> _buildPopupItem(String title, IconData icon) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontFamily: 'EN-REGULAR')),
        ],
      ),
    );
  }

  /// MENU LOGIC
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Select Notes':
        setState(() {
          isSelectionMode = true;
          selectedIndexes.clear();
        });
        break;
    }
  }
}
