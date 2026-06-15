// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/views/focus_track/focus_track_screen.dart';
// import 'package:project_structure/views/home/home_screen.dart';
// import 'package:project_structure/views/more/more.dart';

// class BottomNavigationBarController extends GetxController {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   int selectedIndex = 0;
//   List listTitle = [
//     'Quick Notes',
//     'focus_track'.tr,
//     'more'.tr,
//   ];
//   List screenWidget = [
//     const MyHomePage(),
//     const FocusTrackScreen(),
//     const MoreScreen(),
//   ];
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/views/focus_track/focus_track_screen.dart';
import 'package:project_structure/views/home/home_screen.dart';
import 'package:project_structure/views/more/more_screen.dart';

class BottomNavigationBarController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  String get currentTitle {
    switch (selectedIndex) {
      case 0:
        return 'Quick Notes';
      case 1:
        return 'focus_track'.tr;
      case 2:
        return 'more'.tr;
      default:
        return '';
    }
  }

  final List<Widget> screenWidget = const [
    MyHomePage(),
    FocusTrackScreen(),
    MoreScreen(),
  ];

  void changeTab(int index) {
    selectedIndex = index;
    update();
  }
}
