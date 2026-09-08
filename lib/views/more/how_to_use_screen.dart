import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  String get _bodyFont => Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR';
  String get _boldFont => Get.locale == const Locale('km', 'KM') ? 'KH-BOLD' : 'EN-BOLD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: "how_to_use".tr,
        context: context,
        actions: [],
      ),
      body: ListView(
        padding: Layout.padding(),
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: AppColor().primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.menu_book_rounded, color: AppColor().white, size: 45),
                const SizedBox(height: 14),
                Text(
                  "how_to_use_title".tr,
                  style: TextStyle(color: AppColor().white, fontSize: 26, fontFamily: _boldFont),
                ),
                const SizedBox(height: 8),
                Text(
                  "how_to_use_desc".tr,
                  style: TextStyle(color: Colors.white70, fontSize: 15, fontFamily: _bodyFont),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildTimelineCard(context, "01", "step_01_title".tr, "step_01_desc".tr, Icons.edit_note_rounded, AppColor().primaryColor),
          _buildTimelineCard(context, "02", "step_02_title".tr, "step_02_desc".tr, Icons.folder_copy_rounded, AppColor().orange),
          _buildTimelineCard(context, "03", "step_03_title".tr, "step_03_desc".tr, Icons.lock_rounded, AppColor().red),
          _buildTimelineCard(context, "04", "step_04_title".tr, "step_04_desc".tr, Icons.timer_rounded, AppColor().green),
          _buildTimelineCard(context, "05", "step_05_title".tr, "step_05_desc".tr, Icons.event_rounded, Colors.blue),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, String step, String title, String description, IconData icon, Color color) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
                child: Icon(icon, color: color, size: 26),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppDecorations.subtleShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(30)),
                    child: Text(
                      "${'step'.tr} $step",
                      style: TextStyle(color: color, fontSize: AppFontSize(context).normalTextSize, fontFamily: _boldFont),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(title, style: text20(context)),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: text14(context).copyWith(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
