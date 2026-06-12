import 'package:flutter/material.dart';

class AppColor {
  Color primaryColor = const Color(0xFF3D5DFF);
  Color secondaryColor = const Color(0xFF66B9C1);
  Color backgroundColor = const Color(0xFFEBEBEB);
  Color white = Colors.white;
  Color black = Colors.black;
  Color gray = const Color(0xFF9E9E9E);
  Color red = const Color(0xFFFF0000);
  Color orange = const Color(0xFFFF9800);
  Color green = const Color(0xFF4CAF50);

  Color darkPrimaryColor = const Color(0xFF212121);
  Color darkSecondaryColor = const Color(0xFF282828);
  Color darkbackgroundColor = const Color(0xFFEBEBEB);
  Color darkGray = const Color(0xFF757575);
  Color darkOrange = const Color(0xFFFFA726);
  Color darkGreen = const Color(0xFF66BB6A);

  List<Color> backgroundColors(BuildContext context) => [
        Colors.white,
        Colors.black,
        const Color(0xFFAEB6BF),
        const Color(0xFFD5F5E3),
        const Color(0xFFFCF3CF),
        const Color(0xFFE5E8E8),
        const Color(0xFFEBDEF0),
        const Color(0xFFBCAAA4),
        const Color(0xFFA5D6A7),
        const Color(0xFFFFCC80),
        const Color(0xFFB2EBF2),
        const Color(0xFF81D4FA),
        const Color(0xFF90CAF9),
        const Color(0xFF9FA8DA),
        const Color(0xFFFFF59D),
        const Color(0xFFFFAB91),
        const Color(0xFFF48FB1),
        const Color(0xFFCE93D8),
        const Color(0xFFF5B7B1),
        const Color(0xFFEDBB99),
        const Color(0xFF85C1E9),
        const Color(0xFF7DCEA0),
        const Color(0xFFF7DC6F),
        const Color(0xFFBB8FCE),
        const Color(0xFFFFD700),
        const Color(0xFF00CED1),
        const Color(0xFFDC143C),
        const Color(0xFF32CD32),
      ];
}

class AppDecorations {
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      blurRadius: 5,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      // color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
