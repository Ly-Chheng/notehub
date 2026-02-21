import 'package:flutter/material.dart';

customNavigationBar({
  final List<BottomNavigationBarItem>? items,
  required final int currentIndex,
  final Color? selectedItemColor,
  final Color? unselectedItemColor,
  final void Function(int)? onTap,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(0),
    child: BottomNavigationBar(
      items: items ??
          <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/home.png',
                width: 24,
                height: 24,
              ),
              activeIcon: Image.asset(
                'assets/images/home_active.png',
                width: 24,
                height: 24,
              ),
              // icon: Image.asset(
              //   'assets/images/home.png',
              //   width: 24,
              //   height: 24,
              //   color: currentIndex == 0 ? const Color.fromARGB(255, 108, 39, 176) : Colors.grey,
              // ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/timer.png',
                width: 24,
                height: 24,
              ),
              activeIcon: Image.asset(
                'assets/images/timer_active.png',
                width: 24,
                height: 24,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/more.png',
                width: 24,
                height: 24,
              ),
              activeIcon: Image.asset(
                'assets/images/more_active.png',
                width: 24,
                height: 24,
              ),
              label: '',
            ),
          ],
      currentIndex: currentIndex,
      selectedItemColor: selectedItemColor ?? const Color.fromARGB(255, 108, 39, 176),
      onTap: onTap,
      unselectedItemColor: unselectedItemColor ?? Colors.grey.shade600,
       backgroundColor: const Color(0xFFF8F9FB),
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      showUnselectedLabels: true,
      // selectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      // unselectedLabelStyle: const TextStyle(fontSize: 12),
      showSelectedLabels: false,
    ),
  );
}
