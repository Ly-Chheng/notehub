import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/change_language_controller.dart';

class ChangeLanguageView extends GetView<ChangeLanguageController> {
  const ChangeLanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangeLanguageController>(
      init: ChangeLanguageController(),
      builder: (controller) {
        return GestureDetector(
          child: Card(
            elevation: 0.7,
            color: Theme.of(context).cardColor,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language),
                      const SizedBox(width: 15),
                      Text(
                        'Language',
                        style: TextStyle(
                          fontFamily: Get.locale == const Locale('km', 'KM')
                              ? 'KH-REGULAR'
                              : 'EN-REGULAR',
                          fontSize: context.isPhone ? 14 : 18,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: context.isPhone ? 24 : 34,
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            buildLanguageDialog(context);
          },
        );
      },
    );
  }

  buildLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Change Language'.tr,
            style: TextStyle(
              fontSize: 18,
              fontFamily: Get.locale == const Locale('km', 'KM')
                  ? 'KH-REGULAR'
                  : 'EN-REGULAR',
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          content: GetBuilder<ChangeLanguageController>(
            init: ChangeLanguageController(),
            builder: (controller) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return CupertinoButton(
                      child: Row(
                        children: [
                          Image.network(
                            controller.localeList[index]['image'],
                            width: context.isPhone ? 45 : 65,
                            height: context.isPhone ? 30 : 40,
                            fit: BoxFit.fill,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            controller.localeList[index]['name'],
                            style: TextStyle(
                              fontFamily: controller.localeList[index]
                                          ['name'] ==
                                      'English'
                                  ? 'EN-REGULAR'
                                  : 'KH-REGULAR',
                              fontSize: context.isPhone ? 14 : 18,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        controller.updateLanguage(
                          controller.langs[index],
                        );
                      },
                    );
                  },
                  itemCount: controller.localeList.length,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
