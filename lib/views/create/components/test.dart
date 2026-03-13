import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {

  final TextEditingController titleController = TextEditingController();

  late QuillController contentController;

  @override
  void initState() {
    super.initState();
    contentController = QuillController.basic();
  }

  void saveNote() {

    final title = titleController.text;

    final content = contentController.document.toDelta().toJson();

    debugPrint("TITLE: $title");
    debugPrint("CONTENT: $content");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note saved")),
    );
  }

  void showFormatSheet() {

    showModalBottomSheet(
      context: context,
      builder: (context) {

        return Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 10,
            children: [

              IconButton(
                icon: const Icon(Icons.format_bold),
                onPressed: () {
                  contentController.formatSelection(Attribute.bold);
                },
              ),

              IconButton(
                icon: const Icon(Icons.format_italic),
                onPressed: () {
                  contentController.formatSelection(Attribute.italic);
                },
              ),

              IconButton(
                icon: const Icon(Icons.format_underlined),
                onPressed: () {
                  contentController.formatSelection(Attribute.underline);
                },
              ),

              IconButton(
                icon: const Icon(Icons.format_strikethrough),
                onPressed: () {
                  contentController.formatSelection(Attribute.strikeThrough);
                },
              ),

              IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: () {
                  contentController.formatSelection(Attribute.ul);
                },
              ),

              IconButton(
                icon: const Icon(Icons.format_list_numbered),
                onPressed: () {
                  contentController.formatSelection(Attribute.ol);
                },
              ),

              IconButton(
                icon: const Icon(Icons.format_color_text),
                onPressed: () {
                  contentController.formatSelection(
                    Attribute.fromKeyValue('color', '#ff0000'),
                  );
                },
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create Note"),
        actions: [

          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveNote,
          ),

        ],
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuillEditor.basic(
                controller: contentController,
              ),
            ),
          ),

        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showFormatSheet,
        child: const Icon(Icons.text_fields),
      ),

    );
  }
}