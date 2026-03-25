import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNoData extends StatelessWidget {
  final String message;

  const CustomNoData({
    super.key,
    this.message = "No data found",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Image.asset("assets/images/no_data.png",height: 100,),
          SizedBox(height: 10,),
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
