import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';

Widget customNavigationBar({
  required BuildContext context,
  final List<BottomNavigationBarItem>? items,
  required final int currentIndex,
  final Color? selectedItemColor,
  final Color? unselectedItemColor,
  final void Function(int)? onTap,
  final int chatBadgeCount = 0,
}) {
  final double iconSize = context.isPhone ? 25 : 32;
  final double timerIconSize = context.isPhone ? 32 : 34;
  final sizeImg = context.isPhone ? 26.0 : 32.0;
  final Color activeColor = selectedItemColor ?? AppColor().primaryColor;
  final Color inactiveColor = unselectedItemColor ?? AppColor().gray;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: AppDecorations.subtleShadow,
        borderRadius: BorderRadius.circular(30)
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.isPhone ? 6 : 10,
        horizontal: 20
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => onTap?.call(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    context.isPhone ? 6 : 10,
                  ),
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
          GestureDetector(
            onTap: () => onTap?.call(1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    context.isPhone ? 6 : 10,
                  ),
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
          // Exam
          GestureDetector(
            onTap: () => onTap?.call(2),
            child: Container(
              padding: EdgeInsets.all(context.isPhone ? 6 : 10),
              child: Icon(
                currentIndex == 2 ? Icons.date_range_outlined : Icons.date_range,
                size: timerIconSize,
                color: currentIndex == 2 ? activeColor : inactiveColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onTap?.call(3),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    context.isPhone ? 6 : 10,
                  ),
                  child: Image.asset(
                    currentIndex == 3 ? 'assets/images/more_active.png' : 'assets/images/more.png',
                    width: sizeImg,
                    height: sizeImg,
                    color: currentIndex == 3 ? activeColor : inactiveColor,
                  ),
                ),
                if (chatBadgeCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColor().red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          '$chatBadgeCount',
                          style: TextStyle(color: AppColor().white, fontSize: AppFontSize(context).subNormalSize, fontFamily: 'EN-REGULAR'),
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
