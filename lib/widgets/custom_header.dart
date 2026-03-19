import 'package:flutter/material.dart';

Widget customHeader(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'EN-BOLD',
    ),
  );
}