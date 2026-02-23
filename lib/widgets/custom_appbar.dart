import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/home/components/create_folder_component.dart';

customAppBar({
  required String title,
  final Color? backgroundColor,
  final Color? leadingColor,
  final Color? titleColor,
  final Widget? leading,
  List<Widget>? actions,
  required BuildContext context,
  final bool isLeading = true,
  void Function()? onTap,

  /// NEW
  bool isGrid = false,
  void Function()? onToggleView,
}) {
  return AppBar(
    elevation: 0,
    centerTitle: false, //Title on the left
    titleSpacing: 10, // Control spacing
    // centerTitle: true,
    // backgroundColor:
    //     backgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
    backgroundColor: backgroundColor ?? Color(0xFFF8F9FB),
    title: Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: appbarTextSyle(),
    ),
    automaticallyImplyLeading: false,
    leading: isLeading
        ? Platform.isAndroid
            ? GestureDetector(
                onTap: onTap ??
                    () {
                      Navigator.pop(context);
                    },
                child: Icon(
                  Icons.arrow_back,
                  color: leadingColor ?? Colors.white,
                ),
              )
            : GestureDetector(
                onTap: onTap ??
                    () {
                      Navigator.pop(context);
                    },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: leadingColor ?? Colors.white,
                ),
              )
        : leading,
    // actions: actions,
    /// Actions
    actions: actions ??
        [
          //Create folder button
          IconButton(
            onPressed: () => showCreateFolderSheet(context),
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.format_list_bulleted,color: Colors.black,),
          ),

          /// Toggle view
          // IconButton(
          //   onPressed: onToggleView,
          //   icon: Icon(
          //     isGrid ? Icons.view_list : Icons.grid_view,
          //     color: Colors.black,
          //   ),
          // ),
        ],
  );
}
