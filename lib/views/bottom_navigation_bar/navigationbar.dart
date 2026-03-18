import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/bottom_navigation/navigationbar_controller.dart';
import 'package:project_structure/views/home/components/create_folder_component.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_navigationbar.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  final controller = Get.put(BottomNavigationBarController());
  bool isGrid = false;

  void _onItemTapped(int index) {
    setState(() {
      controller.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: const Icon(
                Icons.warning,
                color: Colors.red,
                size: 60,
              ),
              content: const SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    "Are you sure you want to exit the app?",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(result: false),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: const Center(
                            child: Text(
                              "No",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => SystemNavigator.pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).primaryColor,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        appBar: customAppBar(
          isLeading: false,
          title: controller.listTitle[controller.selectedIndex],
          context: context,
          actions: [
            // Index 0 → Grid + Add icons
            if (controller.selectedIndex == 0) ...[
              GestureDetector(
                onTap: () {
                  showFolderSheet(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 1),
                  ),
                  child: Icon(
                    Icons.add,
                    size: context.isPhone ? 24 : 25,
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              )
            ],

            // Index 1 → Time icon
            if (controller.selectedIndex == 1)
              GestureDetector(
                onTap: () {
                  Get.toNamed('/createTimer');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 1),
                  ),
                  child: Icon(Icons.add, size: context.isPhone ? 24 : 25),
                ),
              ),
            SizedBox(width: 10),

            // Index 2 → no icon (empty)
          ],
        ),
        body: Center(
          child: controller.screenWidget[controller.selectedIndex],
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
