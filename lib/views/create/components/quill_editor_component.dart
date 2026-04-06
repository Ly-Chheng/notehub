import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class QuillEditorComponent extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final String placeholder;

  const QuillEditorComponent({
    super.key,
    required this.controller,
    required this.focusNode,
    this.placeholder = "Start typing...",
  });

  @override
  Widget build(BuildContext context) {
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
              height: 1.5,
              fontFamily: 'EN-REGULAR',
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            const HorizontalSpacing(5, 5),
            const VerticalSpacing(3, 3),
            const VerticalSpacing(2, 2),
            null,
          ),
          placeHolder: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 16,
              height: 1.5,
              fontFamily: 'EN-REGULAR',
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            const HorizontalSpacing(5, 5),
            const VerticalSpacing(3, 3),
            const VerticalSpacing(2, 2),
            null,
          ),
        ),
      ),
    );
  }
}
