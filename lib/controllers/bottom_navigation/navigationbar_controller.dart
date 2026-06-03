import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/views/focus_track/focus_track_screen.dart';
import 'package:project_structure/views/home/home_screen.dart';
import 'package:project_structure/views/more/more.dart';

class BottomNavigationBarController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  List listTitle = [
    'Student Notes',
    'focus_track'.tr,
    'more'.tr,
  ];
  List screenWidget = [
    const MyHomePage(),
    const FocusTrackScreen(),
    const MoreScreen(),
  ];
}
