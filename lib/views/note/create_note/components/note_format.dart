import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:project_structure/widgets/navigation_create_note/format_note.dart';

class NoteFormatComponents {
  static void openFormattingSheet(BuildContext context, QuillController controller) {
    final selectionStyle = controller.getSelectionStyle();
    final attributes = selectionStyle.attributes;
    final currentSize = attributes[Attribute.size.key]?.value ?? 'normal';

    showFormatSheet(
      context: context,
      initialFontSize: currentSize,
      isLeftAligned: selectionStyle.attributes[Attribute.align.key]?.value == 'left' || selectionStyle.attributes[Attribute.align.key] == null,
      isCenterAligned: selectionStyle.attributes[Attribute.align.key]?.value == 'center',
      isRightAligned: selectionStyle.attributes[Attribute.align.key]?.value == 'right',
      isJustifyAligned: attributes[Attribute.align.key]?.value == 'justify',
      isBold: selectionStyle.attributes.containsKey(Attribute.bold.key),
      isItalic: selectionStyle.attributes.containsKey(Attribute.italic.key),
      isUnderlined: selectionStyle.attributes.containsKey(Attribute.underline.key),
      isStrikethrough: selectionStyle.attributes.containsKey(Attribute.strikeThrough.key),
      selectedColor: Colors.transparent,
      selectedHighlightColor: Colors.transparent,
      onBoldChanged: (v) => controller.formatSelection(v ? Attribute.bold : Attribute.clone(Attribute.bold, null)),
      onItalicChanged: (v) => controller.formatSelection(v ? Attribute.italic : Attribute.clone(Attribute.italic, null)),
      onUnderlineChanged: (v) => controller.formatSelection(v ? Attribute.underline : Attribute.clone(Attribute.underline, null)),
      onStrikethroughChanged: (v) => controller.formatSelection(v ? Attribute.strikeThrough : Attribute.clone(Attribute.strikeThrough, null)),
      onLeftAlignPressed: () => controller.formatSelection(Attribute.leftAlignment),
      onCenterAlignPressed: () => controller.formatSelection(Attribute.centerAlignment),
      onRightAlignPressed: () => controller.formatSelection(Attribute.rightAlignment),
      onJustifyAlignPressed: () => controller.formatSelection(Attribute.justifyAlignment),
      onHighlightColorChanged: (color) {
        final hex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
        controller.formatSelection(BackgroundAttribute(hex));
      },
      onFontSizeChanged: (String size) {
        if (size == 'normal') {
          controller.formatSelection(Attribute.clone(Attribute.size, null));
        } else {
          controller.formatSelection(SizeAttribute(size));
        }
      },
      onColorChanged: (color) {
        final hex = '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
        controller.formatSelection(ColorAttribute(hex));
      },
      onBulletPressed: () => controller.formatSelection(Attribute.ul),
      onNumberedPressed: () => controller.formatSelection(Attribute.ol),
      onHyphenPressed: () => controller.formatSelection(Attribute.blockQuote),
    );
  }
}
