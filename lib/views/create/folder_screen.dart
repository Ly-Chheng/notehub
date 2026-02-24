import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  bool isGridView = false;
  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

  final List<Map<String, dynamic>> notes = [
    {"title": "Homework", "subtitle": "Day to practice class exercises and coding", "date": "02/01/2026", "hasImage": false, "isLocked": false},
    {"title": "Exams & Quizzes", "subtitle": "Test-related work including chemistry quizzes...", "date": "29/01/2026", "hasImage": true, "isLocked": false},
    {"title": "Projects", "subtitle": "Large assignments that require deep research...", "date": "30/01/2026", "hasImage": false, "isLocked": true},
    {"title": "Meeting Notes", "subtitle": "Discussion about the final year project...", "date": "15/02/2026", "hasImage": true, "isLocked": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: customAppBar(
          title: isSelectionMode ? "${selectedIndexes.length} Selected" : "Folder",
          titleColor: AppColor().primaryColor,
          context: context,
          leadingColor: AppColor().primaryColor,
          leading: isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isSelectionMode = false;
                      selectedIndexes.clear();
                    });
                  },
                )
              : null,
          actions: [
            Center(child: Text("My Note", style: TextStyle(color: AppColor().primaryColor, fontWeight: FontWeight.w500, fontSize: 16))),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_outlined, color: AppColor().primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              offset: const Offset(0, 50),
              color: Colors.white,
              onSelected: (value) => _handleMenuSelection(value),
              itemBuilder: (context) => [
                _buildPopupItem(
                  isGridView ? 'List view' : 'Grid view',
                  isGridView ? Icons.list_outlined : Icons.grid_on_outlined,
                ),
                _buildPopupItem('Select Notes', Icons.radio_button_unchecked),
              ],
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildStandardField(
              "Search",
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 20),
            const Text("Today", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: isGridView ? _buildGridView() : _buildListView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isSelectionMode ? _buildBottomActionNav() : null,
    );
  }

  /// LIST VIEW
  Widget _buildListView() {
    return ListView.builder(
      itemCount: notes.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildSlidableNote(
          index: index,
          title: note['title'],
          subtitle: note['subtitle'],
          date: note['date'],
          hasImage: note['hasImage'],
          isLocked: note['isLocked'],
        );
      },
    );
  }

  /// GRID VIEW
  Widget _buildGridView() {
    return GridView.builder(
      itemCount: notes.length,
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(
          index: index,
          title: note['title'],
          subtitle: note['subtitle'],
          date: note['date'],
          hasImage: note['hasImage'],
          isLocked: note['isLocked'],
          isGrid: true,
        );
      },
    );
  }

  /// SLIDABLE NOTE (LIST)
  Widget _buildSlidableNote({
    required int index,
    required String title,
    required String subtitle,
    required String date,
    bool hasImage = false,
    bool isLocked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          key: ValueKey(title),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.5,
            children: [
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.push_pin_outlined,
              ),
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.folder_open,
              ),
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: Colors.red,
                icon: Icons.delete_outline_rounded,
              ),
            ],
          ),
          child: GestureDetector(
            onLongPress: () => _onLongPress(index),
            onTap: () => _onTap(index),
            child: _buildNoteCard(
              index: index,
              title: title,
              subtitle: subtitle,
              date: date,
              hasImage: hasImage,
              isLocked: isLocked,
              isGrid: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard({
    required int index,
    required String title,
    required String subtitle,
    required String date,
    bool hasImage = false,
    bool isLocked = false,
    bool isGrid = false,
  }) {
    bool isSelected = selectedIndexes.contains(index);
    return Row(
      children: [
        // --- SELECTION INDICATOR ---
        if (isSelectionMode)
          GestureDetector(
            onTap: () => _toggleSelection(index),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                // Use blue for selected, grey for unselected to match common UI patterns
                color: isSelected ? AppColor().primaryColor : Colors.grey.shade400,
                size: 28,
              ),
            ),
          ),

        // --- NOTE CARD ---
        // Expanded(
        //   child: Container(
        //     padding: const EdgeInsets.all(15),
        //     decoration: BoxDecoration(
        //       color: selectedIndexes.contains(index) ? Colors.deepPurple.shade50 : Colors.white,
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         if (isGrid && hasImage)
        //           Expanded(
        //             child: Container(
        //               width: double.infinity,
        //               margin: const EdgeInsets.only(bottom: 10),
        //               decoration: BoxDecoration(
        //                 color: Colors.grey[200],
        //                 borderRadius: BorderRadius.circular(8),
        //               ),
        //               child: const Icon(Icons.image, color: Colors.grey),
        //             ),
        //           ),
        //         Row(
        //           children: [
        //             if (isLocked) const Icon(Icons.lock, size: 16, color: Colors.redAccent),
        //             if (isLocked) const SizedBox(width: 5),
        //             Expanded(
        //               child: Text(
        //                 title,
        //                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        //                 maxLines: 1,
        //                 overflow: TextOverflow.ellipsis,
        //               ),
        //             ),
        //             if (!isGrid && hasImage)
        //               Container(
        //                 width: 50,
        //                 height: 50,
        //                 decoration: BoxDecoration(
        //                   color: Colors.grey[100],
        //                   borderRadius: BorderRadius.circular(8),
        //                 ),
        //                 child: const Icon(Icons.image, size: 20, color: Colors.grey),
        //               ),
        //           ],
        //         ),
        //         const SizedBox(height: 5),
        //         Text(
        //           subtitle,
        //           style: const TextStyle(color: Colors.black54, fontSize: 13),
        //           maxLines: isGrid ? 2 : 1,
        //           overflow: TextOverflow.ellipsis,
        //         ),
        //         if (isGrid) const Spacer(),
        //         const SizedBox(height: 8),
        //         Text(
        //           date,
        //           style: const TextStyle(color: Colors.grey, fontSize: 11),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: selectedIndexes.contains(index) ? Colors.deepPurple.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                if (isGrid && hasImage)
                  Container(
                    width: double.infinity,
                    height: 100, // Give it a fixed height for the grid
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: NetworkImage("https://via.placeholder.com/150"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isLocked)
                                const Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(Icons.lock_outline, size: 16, color: Colors.redAccent),
                                ),
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            subtitle,
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                            maxLines: isGrid ? 1 : 2, // Fewer lines in grid to prevent overflow
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            date,
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    // --- 2. IMAGE FOR LIST MODE ---
                    // This shows the image on the RIGHT when in List view
                    if (!isGrid && hasImage)
                      Container(
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage("https://via.placeholder.com/150"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionNav() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomActionItem(
            Icons.folder_outlined,
            "Move",
            AppColor().primaryColor,
            onTap: () {},
          ),
          _bottomActionItem(
            Icons.delete_outline,
            "Deletes",
            AppColor().primaryColor,
            onTap: () {
              setState(() {
                selectedIndexes.toList()
                  ..sort((b, a) => a.compareTo(b))
                  ..forEach((index) {
                    notes.removeAt(index);
                  });
                selectedIndexes.clear();
                isSelectionMode = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _bottomActionItem(IconData icon, String label, Color color, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
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
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// MENU LOGIC
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Show List':
      case 'Show Grid':
        setState(() {
          isGridView = !isGridView;
        });
        break;
      case 'Select Notes':
        setState(() {
          isSelectionMode = true;
          selectedIndexes.clear();
        });
        break;
    }
  }

  /// SELECTION LOGIC
  void _onLongPress(int index) {
    setState(() {
      isSelectionMode = true;
      selectedIndexes.add(index);
    });
  }

  void _onTap(int index) {
    if (isSelectionMode) {
      _toggleSelection(index);
    } else {
      // TODO: open note
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
      if (selectedIndexes.isEmpty) isSelectionMode = false;
    });
  }
}
