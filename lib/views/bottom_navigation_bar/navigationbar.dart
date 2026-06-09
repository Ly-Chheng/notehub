import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/bottom_navigation/navigationbar_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/views/focus_track/focus_track_screen.dart';
import 'package:project_structure/views/home/components/create_folder_component.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
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
                  showFolderSheet(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 1, color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColor().gray),
                  ),
                  child: Icon(
                    Icons.add,
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 1, color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColor().gray),
                  ),
                  child: Icon(Icons.add, size: context.isPhone ? 24 : 25),
                ),
              ),
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
        bottomNavigationBar: SafeArea(
          child: customNavigationBar(
            context: context,
            currentIndex: controller.selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
