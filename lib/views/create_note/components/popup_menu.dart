import 'package:flutter/material.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dropdown.dart';

class NotePopupMenu extends StatelessWidget {
  final bool isEmpty;
  final bool isPinned;
  final bool isLocked;
  final VoidCallback onOpened;
  final Function(String) onSelected;

  const NotePopupMenu({
    super.key,
    required this.isEmpty,
    required this.isPinned,
    required this.isLocked,
    required this.onOpened,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isEmpty ? AppColor().gray : AppColor().primaryColor;

    return PopupMenuButton<String>(
      color: Theme.of(context).cardColor,
      enabled: !isEmpty,
      onOpened: onOpened,
      icon: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: iconColor, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(Icons.more_vert_outlined, color: iconColor, size: 18),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      offset: const Offset(0, 50),
      onSelected: onSelected,
      itemBuilder: (context) => [
        buildPopupItem(context, isPinned ? 'unpin' : 'pin', Icons.push_pin_outlined),
        buildPopupItem(context, 'share', Icons.share_outlined),
        buildPopupItem(context, 'move_note', Icons.folder_outlined),
        buildPopupItem(context, isLocked ? 'unlock_note' : 'lock_note', isLocked ? Icons.lock_open : Icons.lock_outline),
        buildPopupItem(context, 'delete', Icons.delete_outline, color: AppColor().red),
      ],
    );
  }
}
