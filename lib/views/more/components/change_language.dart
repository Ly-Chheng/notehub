import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/more/change_language_controller.dart';
import 'package:project_structure/widgets/card_and_button/custom_card_setting.dart';

class ChangeLanguageView extends GetView<ChangeLanguageController> {
  const ChangeLanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangeLanguageController>(
      init: ChangeLanguageController(),
      builder: (controller) {
        return CustomCardSetting(
          icon: Icons.language,
          title: "change_language".tr,
          onTap: () => buildLanguageDialog(context),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
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
