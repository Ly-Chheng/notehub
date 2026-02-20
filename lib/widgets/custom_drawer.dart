import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Widget child;
  const CustomDrawer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      width: MediaQuery.of(context).size.width - 50,
      child: child,
    );
  }
}
