import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';

void showFormatSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColor().white,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red)))]),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffE9E9EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _formatToggle(Icons.format_bold),
                      _formatToggle(Icons.format_italic),
                      _formatToggle(Icons.format_underlined),
                    ],
                  ),
                ),
                const VerticalDivider(),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffE9E9EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _formatToggle(Icons.format_list_bulleted),
                      _formatToggle(Icons.format_list_numbered),
                      _formatToggle(Icons.format_align_left),
                      _formatToggle(Icons.format_align_center),
                      _formatToggle(Icons.format_align_right),
                      _formatToggle(Icons.format_align_justify),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Color dots
          Container(
            decoration: BoxDecoration(
              color: Color(0xffE9E9EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Color(0XFF00FB3F), Color(0XFF9500FF), Colors.red, Color(0XFF002AFC), Colors.blue, Colors.green, Colors.orange, Colors.black]
                    .map((color) => CircleAvatar(backgroundColor: color, radius: 15))
                    .toList(),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _formatToggle(IconData icon) => IconButton(onPressed: () {}, icon: Icon(icon));
