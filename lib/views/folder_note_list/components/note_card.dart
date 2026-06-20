import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import 'package:project_structure/controllers/note/note_controller.dart';
import 'package:project_structure/core/functions/fomat_date.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/models/note/note_model.dart';
import 'package:project_structure/widgets/custom_slidableasction.dart';
import 'package:project_structure/widgets/rounded_file_image.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final NoteController controller;
  final bool isSelectionMode;
  final bool isSelected;
  final int folderId;

  final VoidCallback onTap;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.controller,
    required this.isSelectionMode,
    required this.isSelected,
    required this.folderId,
    required this.onTap,
    required this.onMove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = note.imagePaths;

    final Color noteBgColor = note.bgColor == 0 ? Theme.of(context).cardColor : Color(note.bgColor);

    final Color itemTextColor = note.bgColor == 0
        ? (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black)
        : (ThemeData.estimateBrightnessForColor(noteBgColor) == Brightness.dark ? AppColor().white : AppColor().black);

    final Color itemSubTextColor = itemTextColor.withValues(alpha: 0.7);

    final String titleText = note.title.trim().isNotEmpty ? note.title : controller.getPlainTextFromNote(note.content).trim();

    final String plainContent = controller.getPlainTextFromNote(note.content).trim();

    final String subtitleText = note.title.trim().isNotEmpty ? plainContent : "";

    return Padding(
      padding: Layout.padding(),
      child: Slidable(
        key: ValueKey(note.id),
        enabled: !isSelectionMode,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.7,
          children: [
            AppSlidableAction(
              onPressed: () => controller.togglePinNote(note, folderId),
              icon: note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              label: note.isPinned ? 'unpin'.tr : 'pin'.tr,
              backgroundColor: AppColor().orange,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            AppSlidableAction(
              onPressed: onMove,
              icon: Icons.folder,
              label: 'folder'.tr,
              backgroundColor: AppColor().primaryColor,
            ),
            AppSlidableAction(
              onPressed: onDelete,
              icon: Icons.delete,
              label: 'delete'.tr,
              backgroundColor: AppColor().red,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: noteBgColor,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(
                      color: AppColor().primaryColor,
                      width: 1.5,
                    )
                  : null,
              boxShadow: AppDecorations.subtleShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 14,
              ),
              child: Row(
                children: [
                  if (isSelectionMode)
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: AppColor().primaryColor,
                      size: 24,
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (note.isLocked)
                              Container(
                                width: 26,
                                height: 26,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor().primaryColor.withValues(alpha: 0.1),
                                ),
                                child: Icon(
                                  Icons.lock,
                                  size: 18,
                                  color: AppColor().primaryColor,
                                ),
                              ),
                            SizedBox(
                              width: note.isLocked ? 6 : 0,
                            ),
                            Flexible(
                              child: Text(titleText.isNotEmpty ? titleText : "untitled".tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  // style: text18(context).copyWith(
                                  //   color: itemTextColor,
                                  // ),
                                  style: fix18(context).copyWith(
                                    color: itemTextColor,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              formatDateForLocale(
                                note.date,
                              ),
                              style: text16(context).copyWith(
                                color: itemSubTextColor,
                              ),
                            ),
                            if (subtitleText.isNotEmpty) ...[
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  subtitleText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text14(context).copyWith(
                                    color: itemSubTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (imagePaths.isNotEmpty)
                    RoundedFileImage(
                      path: imagePaths.first,
                    ),
                  if (imagePaths.isNotEmpty) const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
