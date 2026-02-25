import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: customAppBar(
        title: "About",
        titleColor:AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().black,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- APP LOGO SECTION ---
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('assets/images/logo.png', errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.description_rounded, size: 50, color: AppColor().primaryColor);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "BELTEI Student Note",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // --- INFO GROUP ---
            _buildAboutContainer([
              _buildAboutTile(Icons.language, "Website", "www.beltei.edu.kh"),
              _buildAboutTile(Icons.email_outlined, "Support", "info@beltei.edu.kh"),
              _buildAboutTile(Icons.policy_outlined, "Privacy Policy", "Read here"),
              _buildAboutTile(Icons.verified_user_outlined, "Terms of Service", "Read here", isLast: true),
            ]),

            const SizedBox(height: 40),
            const Text(
              "Developed by BELTEI Students\n© 2026 BELTEI Group. All rights reserved.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildAboutContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAboutTile(IconData icon, String title, String value, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87, size: 22),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          onTap: () {}, // Handle navigation or URL launching
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 55,
            endIndent: 15,
            color: Colors.grey.withOpacity(0.1),
          ),
      ],
    );
  }
}
