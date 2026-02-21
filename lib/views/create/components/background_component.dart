import 'package:flutter/material.dart';

void showBackgroundSheet(BuildContext context) {
  // Mock data for colors and background image paths
  final List<Color> bgColors = [
    Color(0xFF8D4B3D), Color(0xFF438A3E), Color(0xFFE57C38), Color(0xFF1B998B),
    Color(0xFF4A0E0E), Color(0xFF34495E), Color(0xFF959595), Color(0xFFD4C300),
    Color(0xFF748CAB), Color(0xFF2E5BCC), Color(0xFFE60000), Color(0xFF27AE60),
    Color(0xFF8E00E6), Color(0xFF63392D), Color(0xFFB35E26), Color(0xFF6A1B71),
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Handle & Cancel
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ],
            ),
            // Solid Colors Grid
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                ),
                itemCount: bgColors.length,
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    color: bgColors[index],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: index == 0 // Show checkmark on the selected item
                      ? const Icon(Icons.check, color: Colors.white70, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Image Presets Row
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemBuilder: (context, index) => Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/120x80'), // Replace with your assets
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}