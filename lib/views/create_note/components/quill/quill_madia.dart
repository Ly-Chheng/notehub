import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:project_structure/views/create_note/components/resizable_media.dart';

class CustomMediaEmbedBuilder implements EmbedBuilder {
  final QuillController controller;
  final String mediaType;

  CustomMediaEmbedBuilder({required this.controller, required this.mediaType});

  @override
  String get key => mediaType;

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final style = embedContext.node.style.attributes['style'];
    double savedWidth = 1.0;

    if (style != null && style.value != null) {
      final RegExp widthRegExp = RegExp(r'width:\s*(\d+)%');
      final match = widthRegExp.firstMatch(style.value.toString());
      if (match != null) {
        savedWidth = int.parse(match.group(1)!) / 100.0;
      }
    }

    return ResizableMediaWidget(
      node: embedContext.node,
      controller: controller,
      initialWidthPercentage: savedWidth,
      isVideo: mediaType == BlockEmbed.videoType,
    );
  }

  @override
  String toPlainText(Embed node) {
    return node.value.data.toString();
  }

  @override
  WidgetSpan buildWidgetSpan(Widget child) {
    return WidgetSpan(child: child);
  }
}
