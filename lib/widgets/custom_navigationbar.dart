import 'package:flutter/material.dart';

customNavigationBar({
  final List<BottomNavigationBarItem>? items,
  required final int currentIndex,
  final Color? selectedItemColor,
  final Color? unselectedItemColor,
  final void Function(int)? onTap,
}) {
  return BottomNavigationBar(
    items: items ??
        const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
    currentIndex: currentIndex,
    selectedItemColor:
        selectedItemColor ?? const Color.fromARGB(255, 108, 39, 176),
    onTap: onTap,
  );
}
