import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/bottom_navigation/navigationbar_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/event_planner/add_event_screen.dart';
import 'package:project_structure/views/focus_track/focus_track_screen.dart';
import 'package:project_structure/views/home/components/create_folder.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
import 'package:project_structure/widgets/custom_navigationbar.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  final controller = Get.put(BottomNavigationBarController());
  bool isGrid = false;
  int focusSubIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      controller.selectedIndex = index;

      if (index != 1) {
        focusSubIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = false;
        await showConfirmDialog(
          context: context,
          title: "exit_app".tr,
          subTitle: "exit_app_confirm".tr,
          confirmText: "yes".tr,
          onConfirm: () {
            shouldExit = true;
            SystemNavigator.pop();
          },
          showCancel: true,
        );

        return shouldExit;
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        appBar: customAppBar(
          isLeading: false,
          title: controller.currentTitle,
          context: context,
          actions: [
            if (controller.selectedIndex == 0) ...[
              GestureDetector(
                onTap: () {
                  createFolder(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor().primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 1, color: AppColor().white),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColor().white,
                    size: context.isPhone ? 24 : 25,
                  ),
                ),
              ),
            ],
            if (controller.selectedIndex == 1 && focusSubIndex == 1)
              GestureDetector(
                onTap: () => Get.toNamed('/createTimer'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor().primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 1, color: AppColor().white),
                  ),
                  child: Icon(Icons.add, color: AppColor().white, size: context.isPhone ? 24 : 25),
                ),
              ),
            if (controller.selectedIndex == 2) ...[
              GestureDetector(
                onTap: () async {
                  final result = await Get.to(() => const AddEventScreen());

                  if (result == true) {
                    setState(() {});
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor().primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 1, color: AppColor().white),
                  ),
                  child: Icon(Icons.add, color: AppColor().white, size: context.isPhone ? 24 : 25),
                ),
              ),
            ],
            SizedBox(width: 15),
          ],
        ),
        body: Center(
          child: controller.selectedIndex == 1
              ? FocusTrackScreen(
                  onToggleChanged: (index) {
                    setState(() {
                      focusSubIndex = index;
                    });
                  },
                )
              : controller.screenWidget[controller.selectedIndex],
        ),
        bottomNavigationBar: customNavigationBar(
          context: context,
          currentIndex: controller.selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
