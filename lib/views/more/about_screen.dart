import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  String get _bodyFont => Get.locale == const Locale('km', 'KM') ? 'KH-REGULAR' : 'EN-REGULAR';
  String get _boldFont => Get.locale == const Locale('km', 'KM') ? 'KH-BOLD' : 'EN-BOLD';

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColor().primaryColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "about".tr,
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                  Text("about_app_name".tr, style: TextStyle(fontSize: 28, color: AppColor().white, fontFamily: _boldFont)),
                  const SizedBox(height: 8),
                  Text("about_slogan".tr, style: TextStyle(color: AppColor().white.withValues(alpha: 0.9), fontSize: 15, fontFamily: _boldFont)),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColor().white.withValues(alpha: 0.16)),
                    child: Text("about_version".tr, style: TextStyle(color: AppColor().white, fontWeight: FontWeight.w600, fontFamily: _boldFont)),
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
                      Text("about_features".tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: _boldFont)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(Icons.note_alt_outlined, "about_create_notes".tr, "about_create_notes_sub".tr),
                  _buildFeatureItem(Icons.edit_note_rounded, "about_edit_anytime".tr, "about_edit_anytime_sub".tr),
                  _buildFeatureItem(Icons.school_outlined, "about_study_smarter".tr, "about_study_smarter_sub".tr),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// CONTACT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppDecorations.subtleShadow,
              ),
              child: Column(
                children: [
                  _buildContactTile(Icons.email_outlined, "contact_email".tr, "support@studentnoteapp.com"),
                  Divider(color: Colors.grey.withValues(alpha: 0.2)),
                  _buildContactTile(Icons.language_rounded, "contact_website".tr, "www.studentnoteapp.com"),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text("copyright_footer".tr, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontFamily: _bodyFont)),
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
          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColor().primaryColor), const SizedBox(width: 10), Text(title, style: TextStyle(fontSize: 18, fontFamily: _boldFont))]),
          const SizedBox(height: 16),
          Text(desc, style: TextStyle(fontSize: 15, height: 1.7, fontFamily: _bodyFont, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
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
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: _boldFont)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontFamily: _bodyFont)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: AppColor().primaryColor.withValues(alpha: 0.1), child: Icon(icon, color: AppColor().primaryColor)),
      title: Text(title, style: TextStyle(fontFamily: _bodyFont)),
      subtitle: Text(subtitle, style: TextStyle(fontFamily: _bodyFont)),
    );
  }
}
