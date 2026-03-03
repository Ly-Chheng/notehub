import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

class RecentlyDeletedScreen extends StatelessWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box noteBox = Hive.box('student_notes');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS Light Gray
      appBar: AppBar(title: const Text("Recently Deleted")),
      body: ValueListenableBuilder(
        valueListenable: noteBox.listenable(),
        builder: (context, Box box, _) {
          // KEY LOGIC: Filter only notes where isDeleted is true
          final deletedNotes = box.keys.where((k) => box.get(k)['isDeleted'] == true).toList();

          if (deletedNotes.isEmpty) {
            return const Center(child: Text("No Notes in Trash", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: deletedNotes.length,
            itemBuilder: (context, index) {
              final key = deletedNotes[index];
              final note = box.get(key);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: ListTile(
                  title: Text(note['title'] ?? "Untitled"),
                  subtitle: Text("Will be permanently deleted soon"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // RESTORE BUTTON
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.blue),
                        onPressed: () {
                          var restored = Map<String, dynamic>.from(note);
                          restored['isDeleted'] = false; // Set back to active
                          box.put(key, restored);
                          Get.snackbar("Restored", "Note moved back to folder");
                        },
                      ),
                      // DELETE PERMANENTLY
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => box.delete(key),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}