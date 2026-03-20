import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

Widget customNavigationBar({
  required BuildContext context,
  final List<BottomNavigationBarItem>? items,
  required final int currentIndex,
  final Color? selectedItemColor,
  final Color? unselectedItemColor,
  final void Function(int)? onTap,
  final int chatBadgeCount = 0,
}) {
  final double iconSize = context.isPhone ? 26 : 30;
  final double timerIconSize = context.isPhone ? 29 : 32;
  final Color activeColor = selectedItemColor ?? AppColor().primaryColor;
  final Color inactiveColor = unselectedItemColor ?? Colors.grey.shade700;

  return Padding(
    padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
    child: Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(29)),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Tab
          GestureDetector(
            onTap: () => onTap?.call(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    currentIndex == 0 ? 'assets/images/home_active.png' : 'assets/images/home.png',
                    width: iconSize,
                    height: iconSize,
                    color: currentIndex == 0 ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
          // Timer Tab
          GestureDetector(
            onTap: () => onTap?.call(1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    currentIndex == 1 ? 'assets/images/timer_active.png' : 'assets/images/timer.png',
                    width: timerIconSize,
                    height: timerIconSize,
                    color: currentIndex == 1 ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
          // More Tab (with optional badge)
          GestureDetector(
            onTap: () => onTap?.call(2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    currentIndex == 2 ? 'assets/images/more_active.png' : 'assets/images/more.png',
                    width: iconSize,
                    height: iconSize,
                    color: currentIndex == 2 ? activeColor : inactiveColor,
                  ),
                ),
                if (chatBadgeCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          '$chatBadgeCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
