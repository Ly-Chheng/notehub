import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/views/exam_planner/exam_list_screen.dart';
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
        return 'exam'.tr;
      case 3:
        return 'more'.tr;
      default:
        return '';
    }
  }

  final List<Widget> screenWidget = const [
    MyHomePage(),
    FocusTrackScreen(),
    ExamListScreen(),
    MoreScreen(),
  ];

  void changeTab(int index) {
    selectedIndex = index;
    update();
  }
}
