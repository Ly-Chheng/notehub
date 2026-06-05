import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  // Helper to get correct font family based on locale
  String get _bodyFont => Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR';
  String get _boldFont => Get.locale == const Locale('km', 'KM') ? 'KH-BOLD' : 'EN-BOLD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: "how_to_use".tr,
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          /// HEADER
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [AppColor().primaryColor, AppColor().primaryColor.withValues(alpha: 0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu_book_rounded, color: Colors.white, size: 45),
                const SizedBox(height: 14),
                Text(
                  "how_to_use_title".tr,
                  style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: _boldFont),
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
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
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
                  Text(title, style: TextStyle(fontSize: 20, fontFamily: _boldFont, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade700, fontFamily: _bodyFont),
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
