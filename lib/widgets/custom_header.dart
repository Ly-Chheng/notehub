import 'package:flutter/material.dart';

Widget customHeader(String title, BuildContext context) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 20,
      fontFamily: 'EN-BOLD',
      color: Theme.of(context).textTheme.bodyLarge?.color,
    ),
  );
}
