import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        title: "About",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x0D000000),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Image.asset('assets/images/note_book.png', errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/icons/note_book.png',
                      height: 50,
                      width: 50,
                    );
                  }),
                ),
              ),
            ),
            Center(child: customHeader("Student Note")),
            const SizedBox(height: 40),
            _buildAboutContainer(context, [
              _buildAboutTile(Icons.language, "Website", "www.beltei.edu.kh"),
              _buildAboutTile(Icons.email_outlined, "Support", "info@beltei.edu.kh"),
              _buildAboutTile(Icons.policy_outlined, "Privacy Policy", "Read here"),
              _buildAboutTile(Icons.verified_user_outlined, "Terms of Service", "Read here", isLast: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutContainer(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAboutTile(IconData icon, String title, String value, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 22),
          title: Text(title, style: const TextStyle(fontSize: 16, fontFamily: 'EN-ENGULAR')),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'EN-ENGULAR')),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          onTap: () {},
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 55,
            endIndent: 15,
            color: const Color(0x1A9E9E9E),
          ),
      ],
    );
  }
}
