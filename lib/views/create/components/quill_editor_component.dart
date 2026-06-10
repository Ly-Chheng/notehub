import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/create/components/media_logic_component.dart';
import 'package:project_structure/views/create/components/quill_media_components.dart';

class QuillEditorComponent extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final String placeholder;
  final Color? textColor;

  const QuillEditorComponent({
    super.key,
    required this.controller,
    required this.focusNode,
    this.placeholder = 'start_typing',
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = textColor ?? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final String effectivePlaceholder = placeholder.tr;
    return QuillEditor(
      controller: controller,
      scrollController: ScrollController(),
      focusNode: focusNode,
      config: QuillEditorConfig(
        placeholder: effectivePlaceholder,
        padding: EdgeInsets.zero,
        autoFocus: false,
        showCursor: true,
        expands: false,
        scrollable: false,
        embedBuilders: [
          CustomMediaEmbedBuilder(controller: controller, mediaType: BlockEmbed.imageType),
          CustomMediaEmbedBuilder(controller: controller, mediaType: BlockEmbed.videoType),
          CustomFileEmbedBuilder(),
          // TableEmbedBuilder(),
          ...FlutterQuillEmbeds.editorBuilders(),
        ],
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            TextStyle(
              fontSize: context.isPhone ? 16 : 18,
              height: 1.4,
              fontFamily: AppFonts().rengular,
              fontFamilyFallback: const ['KH-REGULAR'],
              color: effectiveColor,
            ),
            const HorizontalSpacing(3, 3),
            const VerticalSpacing(2, 2),
            const VerticalSpacing(2, 2),
            null,
          ),
          placeHolder: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 16,
              height: 1.4,
              fontFamily: AppFonts().rengular,
              fontFamilyFallback: const ['KH-REGULAR'],
              color: effectiveColor.withValues(alpha: 0.6),
            ),
            const HorizontalSpacing(3, 3),
            const VerticalSpacing(2, 2),
            const VerticalSpacing(2, 2),
            null,
          ),
        ),
      ),
    );
  }
}
