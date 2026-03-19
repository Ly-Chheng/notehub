import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class CustomListFolder extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final ValueListenable<Box> listenable;
  final VoidCallback onTap;

  const CustomListFolder({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.listenable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: context.isPhone ? 18 : 20,
          fontFamily: 'EN-REGULAR',
        ),
      ),
      trailing: ValueListenableBuilder(
        valueListenable: listenable,
        builder: (context, Box box, _) => Text(
          "${box.length}",
          style: TextStyle(
            color: Colors.grey,
            fontSize: context.isPhone ? 16 : 18,
            fontFamily: 'EN-REGULAR',
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
  // Widget _buildRecentlyDeletedTile(BuildContext context) {
  //   return ListTile(
  //     leading: const Icon(Icons.delete, color: Colors.red),
  //     title: Text("Recently Deleted", style: TextStyle(fontSize: context.isPhone ? 18 : 20, fontFamily: 'EN-REGULAR')),
  //     trailing: ValueListenableBuilder(
  //       valueListenable: trashBox.listenable(),
  //       builder: (context, Box tBox, _) => Text("${tBox.length}", style: TextStyle(color: Colors.grey, fontSize: context.isPhone ? 16 : 18, fontFamily: 'EN-REGULAR')),
  //     ),
  //     onTap: () => Get.to(() => RecentlyDeletedScreen()),
  //   );
  // }
  // child: _buildRecentlyDeletedTile(context),