import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';

Widget customNavigationBar({
  required BuildContext context,
  required int currentIndex,
  required Function(int) onTap,
  int chatBadgeCount = 0,
}) {
  return CurvedNavigationBar(
    index: currentIndex,
    backgroundColor: Colors.transparent,
    color: Theme.of(context).cardColor,
    buttonBackgroundColor: AppColor().primaryColor,
    animationDuration: Duration(milliseconds: 600),
    animationCurve: Curves.easeInOut,
    onTap: onTap,
    items: [
      CurvedNavigationBarItem(
        child: Icon(
          currentIndex == 0 ? Icons.home : Icons.home_outlined,
          size: context.isPhone ? 25 : 30,
          color: currentIndex == 0 ? AppColor().white : AppColor().gray,
        ),
      ),
      CurvedNavigationBarItem(
        child: Icon(
          currentIndex == 1 ? Icons.timer : Icons.timer_outlined,
          size: context.isPhone ? 25 : 30,
          color: currentIndex == 1 ? AppColor().white : AppColor().gray,
        ),
      ),
      CurvedNavigationBarItem(
        child: Icon(
          currentIndex == 2 ? Icons.date_range : Icons.date_range,
          size: context.isPhone ? 25 : 30,
          color: currentIndex == 2 ? AppColor().white : AppColor().gray,
        ),
      ),
      CurvedNavigationBarItem(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              currentIndex == 3 ? 'assets/images/more_active.png' : 'assets/images/more.png',
              width: context.isPhone ? 25 : 30,
              height: context.isPhone ? 25 : 30,
              color: currentIndex == 3 ? AppColor().white : AppColor().gray,
            ),
            if (chatBadgeCount > 0)
              Positioned(
                right: context.isPhone ? -8 : -10,
                top: context.isPhone ? -8 : -10,
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
