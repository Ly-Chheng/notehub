import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/notes/test_note_controller.dart' show NoteController;

import 'package:project_structure/models/note/note_model.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/test_create_note_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

import 'package:project_structure/widgets/custom_text_field.dart';
import 'package:project_structure/widgets/custome_no_data.dart';

class FolderNoteListScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  const FolderNoteListScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<FolderNoteListScreen> createState() => _FolderNoteListScreenState();
}

class _FolderNoteListScreenState extends State<FolderNoteListScreen> {
  final NoteController controller = Get.put(NoteController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchNotesByFolder(widget.folderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: widget.folderName,
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {}, // Add selection mode logic here if needed
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.notes.isEmpty) {
                return const CustomNoData(message: "No notes found");
              }

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: controller.notes.length,
                itemBuilder: (context, index) {
                  final note = controller.notes[index];
                  return _buildSlidableNote(note);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor().primaryColor,
        onPressed: () {
          // Navigate to create screen with folderId
          Get.to(() => CreateNoteScreen(folderId: widget.folderId));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSlidableNote(NoteModel note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(note.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (c) => controller.deleteNote(note.id!, widget.folderId),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(note.title ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(note.date ?? ""),
            trailing: note.isLocked ? const Icon(Icons.lock, size: 18) : null,
            onTap: () {
              // Get.to(() => CreateNoteScreen(isEditing: true, note: note));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: customTextField(
        "Search notes...",
        false,
        null,
        controller: searchController,
        onChanged: (val) => controller.searchNotes(val, widget.folderId),
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
