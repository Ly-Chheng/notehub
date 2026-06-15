import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:project_structure/controllers/home/folder_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class FolderSearch extends StatelessWidget {
  final TextEditingController controller;
  final FolderController folderController;
  final GlobalKey showcaseKey;

  const FolderSearch({
    super.key,
    required this.controller,
    required this.folderController,
    required this.showcaseKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Layout.padding(),
      child: Showcase(
        key: showcaseKey,
        description: 'tap_to_search'.tr,
        descTextStyle: text14(context).copyWith(color: AppColor().black),
        onBarrierClick: () {
          ShowcaseView.get().hideFloatingActionWidgetForKeys([
            showcaseKey,
          ]);
        },
        targetBorderRadius: BorderRadius.circular(12),
        tooltipBorderRadius: BorderRadius.circular(12),
        tooltipActionConfig: const TooltipActionConfig(
          alignment: MainAxisAlignment.end,
          position: TooltipActionPosition.outside,
          gapBetweenContentAndAction: 10,
        ),
        child: customTextField(
          "search".tr,
          false,
          null,
          controller: controller,
          onChanged: (v) => folderController.searchFolders(v),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}