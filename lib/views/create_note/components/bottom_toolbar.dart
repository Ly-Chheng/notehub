import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_layout.dart';

class BottomToolbarComponent extends StatelessWidget {
  final bool showTable;
  final VoidCallback onImagePressed;
  final VoidCallback onFormatPressed;
  final VoidCallback onPalettePressed;
  final VoidCallback onTablePressed;
  final VoidCallback onDrawingPressed;
  final VoidCallback onTemplatePressed;

  const BottomToolbarComponent({
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
            padding: EdgeInsets.symmetric(
              horizontal: context.isPhone ? 15 : 40, 
              vertical: context.isPhone ? 3 : 10
            ),
            decoration: Layout.cardDecoration(radius: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIcon(Icons.image_outlined, onImagePressed, context),
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
