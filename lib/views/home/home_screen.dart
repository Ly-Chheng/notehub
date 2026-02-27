import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/controllers/bottom_navigation/navigationbar_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/models/folder_model.dart';
import 'package:project_structure/views/create/create_note_screen.dart';
import 'package:project_structure/views/create/folder_note_list_screen.dart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = Get.find<BottomNavigationBarController>();
  bool isGrid = false;
  final Box<Folder> folderBox = Hive.box<Folder>('folders_box');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Folders', style: TextStyle(fontSize: 18, fontFamily: 'EN-BOLD')),
                // IconButton(
                //   icon: Icon(
                //     isGrid ? Icons.list : Icons.grid_view,
                //     color: Colors.black,
                //     size: 20,
                //   ),
                //   onPressed: () => setState(() => isGrid = !isGrid),
                // )
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: folderBox.listenable(),
                builder: (context, Box<Folder> box, _) {
                  final folders = box.values.toList();

                  if (folders.isEmpty) {
                    return Center(
                        child: Text(
                      "No folders yet. Tap + to create one.",
                      style: TextStyle(fontFamily: 'EN-REGULAR', color: Colors.grey),
                    ));
                  }

                  return isGrid ? _buildGrid(folders) : _buildList(folders);
                },
              ),
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

  Widget _buildList(List<Folder> folders) {
    return ListView.builder(
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return GestureDetector(
          onTap: () => Get.to(() => FolderNoteListScreen()),
          child: Dismissible(
            key: Key(folder.key.toString()),
            onDismissed: (direction) => folder.delete(), // Simple Swipe to Delete
            child: _buildFolderItem(folder),
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<Folder> folders) {
    return GridView.builder(
      itemCount: folders.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) => _buildGridItem(folders[index]),
    );
  }

  Widget _buildFolderItem(Folder folder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.folder, color: Color(folder.colorValue), size: 30),
        title: Text(folder.title, style: TextStyle(fontFamily: 'EN-REGULAR', fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color)),
        trailing: Text("${folder.count}", style: const TextStyle(color: Colors.grey, fontFamily: 'EN-REGULAR', fontSize: 18)),
      ),
    );
  }

  Widget _buildGridItem(Folder folder) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.folder, color: Color(folder.colorValue), size: 35),
          Text(folder.title, style: TextStyle(fontFamily: 'EN-REGULAR', fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }
}
