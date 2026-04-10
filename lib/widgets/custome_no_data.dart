import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNoData extends StatelessWidget {
  final String message;
  final String imagePath;

  const CustomNoData({
    super.key,
    this.message = "No data found",
    this.imagePath = "assets/images/no_data.png",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 100,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            message,
            style: TextStyle(
              fontSize: context.isPhone ? 16 : 18,
              fontFamily: 'EN-REGULAR',
            ),
          ),
        ],
      ),
    );
  }
}
