import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormatController extends GetxController {

  void insertBulletPoint(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;

    final insertion =
        (text.isEmpty || text.endsWith('\n')) ? "• " : "\n• ";

    controller.text =
        text.replaceRange(selection.start, selection.end, insertion);

    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + insertion.length),
    );
  }

  void insertNumberedList(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;

    final insertion =
        (text.isEmpty || text.endsWith('\n')) ? "1. " : "\n1. ";

    controller.text =
        text.replaceRange(selection.start, selection.end, insertion);

    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + insertion.length),
    );
  }

  void insertDashList(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;

    final insertion =
        (text.isEmpty || text.endsWith('\n')) ? "- " : "\n- ";

    controller.text =
        text.replaceRange(selection.start, selection.end, insertion);

    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + insertion.length),
    );
  }

  void insertTextAtEnd(
      TextEditingController controller, String insertion) {
    controller.text = controller.text + insertion;

    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }
}