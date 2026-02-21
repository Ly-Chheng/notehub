import 'package:flutter/material.dart';

void showEmojiSheet(BuildContext context) {
  // A diverse list of common emojis
  final List<String> emojis = ["😊", "😂", "🥰", "😎", "🤔", "😴", "🥳", "👍", "🔥", "✨", "🌈", "🍎", "⚽️", "🚗", "💡", "❤️", "🎉", "💻", "🍕", "🐶", "🚀", "🌍", "🎁", "📸", "🎨", "⭐", "🦄", "✅"];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => Container(
      height: 350, // Slightly taller for better spacing
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Drag handle at the top
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Header with Cancel button
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ],
          ),
          // Emoji Grid
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    debugPrint("Selected: ${emojis[index]}");
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      emojis[index],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
