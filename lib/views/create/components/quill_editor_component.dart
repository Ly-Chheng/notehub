import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class QuillEditorComponent extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final String placeholder;
  final Color? textColor;

  const QuillEditorComponent({
    super.key,
    required this.controller,
    required this.focusNode,
    this.placeholder = "Start typing...",
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = textColor ?? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return QuillEditor(
      controller: controller,
      scrollController: ScrollController(),
      focusNode: focusNode,
      config: QuillEditorConfig(
        placeholder: placeholder,
        padding: EdgeInsets.zero,
        autoFocus: false,
        showCursor: true,
        expands: false,
        scrollable: false,
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 16,
              height: 1.4,
              fontFamily: 'EN-REGULAR',
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
              fontFamily: 'EN-REGULAR',
              fontFamilyFallback: const ['KH-REGULAR'],
              color: effectiveColor,
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
