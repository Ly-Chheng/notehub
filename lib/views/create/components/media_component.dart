import 'package:flutter/material.dart';

void showMediaSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Row(children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red)))]),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text("Take a photo"),
            onTap: () {
              // Handle camera action
            },
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text("Select from gallery"),
            onTap: () {
              // Handle gallery selection
            },
          ),
        ],
      ),
    ),
  );
}
