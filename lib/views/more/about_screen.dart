import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColor().primaryColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "about".tr,
        titleColor: AppColor().primaryColor,
        context: context,
      ),
      body: SingleChildScrollView(
        padding: Layout.padding(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.75)],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 95,
                    width: 95,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor().white.withValues(alpha: 0.18),
                    ),
                    child: Icon(Icons.auto_stories_rounded, size: 50, color: AppColor().white),
                  ),
                  const SizedBox(height: 18),
                  Text("about_app_name".tr,
                      style: text18(context).copyWith(
                        fontSize: 28,
                        color: AppColor().white,
                      )),
                  const SizedBox(height: 8),
                  Text("about_slogan".tr, style: text14(context).copyWith(color: AppColor().white.withValues(alpha: 0.9))),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColor().white.withValues(alpha: 0.16)),
                    child: Text("about_version".tr, style: text14(context).copyWith(color: AppColor().white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildCard(context, Icons.info_outline_rounded, "about_application".tr, "about_description".tr),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppDecorations.subtleShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_outline_rounded, color: AppColor().primaryColor),
                      const SizedBox(width: 10),
                      Text("about_features".tr, style: text18(context)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(Icons.note_alt_outlined, "about_create_notes".tr, "about_create_notes_sub".tr, context),
                  _buildFeatureItem(Icons.edit_note_rounded, "about_edit_anytime".tr, "about_edit_anytime_sub".tr, context),
                  _buildFeatureItem(Icons.school_outlined, "about_study_smarter".tr, "about_study_smarter_sub".tr, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String title, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColor().black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColor().primaryColor), const SizedBox(width: 10), Text(title, style: text18(context))]),
          const SizedBox(height: 16),
          Text(desc, style: text14(context).copyWith(height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColor().primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: AppColor().primaryColor)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text16(context).copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: text16(context).copyWith(color: AppColor().gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
