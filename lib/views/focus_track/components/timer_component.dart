import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/create_note_screen.dart';

class TimerComponent extends StatefulWidget {
  const TimerComponent({super.key});

  @override
  State<TimerComponent> createState() => _TimerComponentState();
}

class _TimerComponentState extends State<TimerComponent> {
  bool isGridView = false;
  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

  // Reference to our opened box
  final Box noteBox = Hive.box('student_notes');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
}
