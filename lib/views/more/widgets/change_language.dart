import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/change_language_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';

class ChangeLanguageView extends GetView<ChangeLanguageController> {
  const ChangeLanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangeLanguageController>(
      init: ChangeLanguageController(),
      builder: (controller) {
        return GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: context.isPhone ? 12 : 16,
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor().primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.language,
                            color: AppColor().primaryColor,
                            size: context.isPhone ? 20 : 24,
                          )),
                      SizedBox(width: 15),
                      Text(
                        'change_language'.tr,
                        style: TextStyle(
                          fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
                          fontSize: context.isPhone ? 14 : 18,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                // Text(
                //   controller.langs[controller.locales.indexOf(Get.locale!)],
                //   style: TextStyle(
                //     fontFamily: Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR',
                //     fontSize: context.isPhone ? 14 : 18,
                //      color: Theme.of(context).textTheme.bodyLarge?.color,
                //   ),
                // ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: context.isPhone ? 14 : 18,
                  color: Colors.grey,
                ),
              ],
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              controller.localeList[index]['image'],
                              width: context.isPhone ? 45 : 65,
                              height: context.isPhone ? 30 : 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            controller.localeList[index]['name'],
                            style: TextStyle(
                                fontFamily: controller.localeList[index]['name'] == 'English' ? 'EN-REGULAR' : 'KH-REGULAR',
                                fontSize: context.isPhone ? 14 : 18,
                                // color: Get.locale == controller.localeList[index]['locale'] ? AppColor().primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                                color: Theme.of(context).textTheme.bodyLarge?.color),
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
