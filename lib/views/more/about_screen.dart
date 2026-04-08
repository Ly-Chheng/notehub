import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custome_no_data.dart';

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
      body: Center(
        child: CustomNoData(
          message: "No Data",
        ),
      ),
    );
  }
}
