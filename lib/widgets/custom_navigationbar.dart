import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:project_structure/core/utils/app_color.dart';

Widget customNavigationBar({
  required BuildContext context,
  required int currentIndex,
  required Function(int) onTap,
  int chatBadgeCount = 0,
}) {
  return CurvedNavigationBar(
    index: currentIndex,
    height: 70,
    backgroundColor: Colors.transparent,
    color: Theme.of(context).cardColor,
    buttonBackgroundColor: AppColor().primaryColor,
    animationDuration: const Duration(milliseconds: 300),
    animationCurve: Curves.easeInOut,
    onTap: onTap,
    items: [
      CurvedNavigationBarItem(
        child: Icon(
          currentIndex == 0 ? Icons.home : Icons.home_outlined,
          size: 25,
          color: currentIndex == 0 ? AppColor().white : AppColor().gray,
        ),
      ),
      CurvedNavigationBarItem(
        child: Icon(
          currentIndex == 1 ? Icons.timer : Icons.timer_outlined,
          size: 25,
          color: currentIndex == 1 ? AppColor().white : AppColor().gray,
        ),
      ),
      CurvedNavigationBarItem(
        child: Icon(
          currentIndex == 2 ? Icons.date_range : Icons.date_range_sharp,
          size: 25,
          color: currentIndex == 2 ? AppColor().white : AppColor().gray,
        ),
      ),
      CurvedNavigationBarItem(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              currentIndex == 3 ? 'assets/images/more_active.png' : 'assets/images/more.png',
              width: 25,
              height: 25,
              color: currentIndex == 3 ? AppColor().white : AppColor().gray,
            ),
            if (chatBadgeCount > 0)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColor().red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$chatBadgeCount',
                    style: TextStyle(
                      color: AppColor().white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
