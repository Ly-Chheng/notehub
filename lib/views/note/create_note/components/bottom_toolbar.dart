import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_layout.dart';

class BottomToolbar extends StatelessWidget {
  final bool showTable;
  final VoidCallback onImagePressed;
  final VoidCallback onFormatPressed;
  final VoidCallback onPalettePressed;
  final VoidCallback onTablePressed;
  final VoidCallback onDrawingPressed;
  final VoidCallback onTemplatePressed;

  const BottomToolbar({
    super.key,
    required this.showTable,
    required this.onImagePressed,
    required this.onFormatPressed,
    required this.onPalettePressed,
    required this.onTablePressed,
    required this.onDrawingPressed,
    required this.onTemplatePressed,
  });

  Widget _buildIcon(IconData icon, VoidCallback onTap, BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onTap,
      iconSize: context.isPhone ? 24 : 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: UnconstrainedBox(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 10 : 40, vertical: context.isPhone ? 4 : 10),
            decoration: Layout.cardDecoration(radius: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIcon(Icons.attach_file_outlined, onImagePressed, context),
                _buildIcon(Icons.text_fields, onFormatPressed, context),
                _buildIcon(Icons.palette_outlined, onPalettePressed, context),
                _buildIcon(showTable ? Icons.table_chart_outlined : Icons.table_chart_outlined, onTablePressed, context),
                _buildIcon(Icons.mode_outlined, onDrawingPressed, context),
                _buildIcon(Icons.widgets_outlined, onTemplatePressed, context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
