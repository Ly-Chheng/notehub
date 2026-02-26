import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/create/components/background_component.dart';
import 'package:project_structure/views/create/components/choose_folder_component.dart';
import 'package:project_structure/views/create/components/emoji_component.dart';
import 'package:project_structure/views/create/components/format_component.dart';
import 'package:project_structure/views/create/components/grid_selector_component.dart';
import 'package:project_structure/views/create/components/media_component.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  // Initialize the controller
  final NoteController controller = Get.put(NoteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: customAppBar(
        title: "Create Note",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          Obx(() => IconButton(
                onPressed: controller.history.length > 1 ? () => controller.undo() : null,
                icon: Image.asset('assets/images/undo.png', width: 24, height: 24, color: controller.history.length > 1 ? AppColor().primaryColor : Colors.grey),
              )),
          Obx(() => IconButton(
                onPressed: controller.redoStack.isNotEmpty ? () => controller.redo() : null,
                icon: Image.asset('assets/images/redo.png', width: 24, height: 24, color: controller.redoStack.isNotEmpty ? AppColor().primaryColor : Colors.grey),
              )),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            offset: const Offset(0, 50),
            color: Colors.white,
            onSelected: (value) => _handleMenuSelection(value, context),
            itemBuilder: (context) => [
              _buildPopupItem('Lock', Icons.lock_outline),
              _buildPopupItem('Pinned', Icons.push_pin_outlined),
              _buildPopupItem('Share', Icons.share_outlined),
              _buildPopupItem('Lines & Grids', Icons.grid_on_outlined),
              _buildPopupItem('Move Folder', Icons.folder_outlined),
              _buildPopupItem('Delete', Icons.delete_outline, color: Colors.red),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'EN-Bold'),
            ),
            Expanded(
              child: TextField(
                controller: controller.contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Note something down',
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'EN-REGULAR'),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _bottomIcon(Icons.image_outlined, () => showMediaSheet(context)),
                  _bottomIcon(Icons.emoji_emotions_outlined, () => showEmojiSheet(context)),
                  _bottomIcon(
                      Icons.text_fields,
                      () => showFormatSheet(
                            context,
                          )),
                  _bottomIcon(Icons.palette_outlined, () => showBackgroundSheet(context)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined, color: Colors.blueAccent),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// --- HELPER WIDGETS ---

Widget _bottomIcon(IconData icon, VoidCallback onPressed) {
  return IconButton(
    icon: Icon(icon, color: Colors.black54, size: 24),
    onPressed: onPressed,
  );
}

PopupMenuItem<String> _buildPopupItem(String title, IconData icon, {Color? color}) {
  return PopupMenuItem<String>(
    value: title,
    child: Row(
      children: [
        Icon(icon, color: color ?? Colors.black87, size: 20),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(color: color ?? Colors.black87, fontSize: 16, fontFamily: 'EN-REGULAR')),
      ],
    ),
  );
}

void _handleMenuSelection(String value, BuildContext context) async {
  final NoteController controller = Get.find<NoteController>();

  switch (value) {
    case 'Lock':
      Get.to(() => const CreatePasswordScreen());
      break;

    case 'Pinned':
      controller.togglePin();
      break;

    case 'Share':
      final text = "${controller.titleController.text}\n\n${controller.contentController.text}";
      if (text.trim().isNotEmpty) {
        debugPrint("Sharing: $text");
      }
      break;

    case 'Lines & Grids':
      showGridSelector(context, controller);
      break;

    case 'Move Folder':
      showChooseFolderSheet(
        context: context,
        onDone: (folder) {
          debugPrint("Moved to: $folder");
        },
      );
      break;

    case 'Delete':
      await showConfirmDeleteDialog(
        context: context,
        title: 'Delete Note',
        subTitle: 'Are you sure you want to delete this note?',
        onConfirm: () {
          Get.back(); // Close dialog
          Get.back(); // Exit screen
        },
      );
      break;
  }
}
