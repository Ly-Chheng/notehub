import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_structure/controllers/notes/media_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_button.dart';
import 'package:project_structure/widgets/custom_menu_item.dart.dart';
import 'package:project_structure/widgets/app_snack_bar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_sheet_header.dart';
import 'package:speech_to_text/speech_to_text.dart';

void showMediaSheet({
  required BuildContext context,
  required Function(File mediaFile, String type) onMediaSelected,
  Function(String text)? onTextScanned,
}) {
  final MediaController controller = Get.put(MediaController());
  final themeColor = Theme.of(context).cardColor;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(
              title: "add_media".tr,
            ),
            const SizedBox(height: 15),
            buildActionItem(
              context,
              icon: Icons.camera_alt_outlined,
              color: AppColor().primaryColor,
              title: "take_photo".tr,
              onTap: () => controller.pickImage(source: ImageSource.camera, onResult: onMediaSelected),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.image_outlined,
              color: AppColor().primaryColor,
              title: "gallery_image".tr,
              onTap: () => controller.pickImage(source: ImageSource.gallery, onResult: onMediaSelected),
            ),
            divider(context),
            const SizedBox(height: 5),
            buildActionItem(
              context,
              icon: Icons.video_library_outlined,
              color: AppColor().primaryColor,
              title: "gallery_video".tr,
              onTap: () => controller.pickVideo(source: ImageSource.gallery, onResult: onMediaSelected),
            ),
            divider(context),
            buildActionItem(
              context,
              icon: Icons.note_outlined,
              color: AppColor().primaryColor,
              title: "attach_file".tr,
              onTap: () => controller.pickFile(onResult: onMediaSelected),
            ),
            divider(context),
            buildActionItem(context, icon: Icons.document_scanner_outlined, color: AppColor().primaryColor, title: "scan_text".tr, onTap: () {
              Get.back();
              controller.scanText(
                context: context,
                onTextScanned: (text) {
                  if (onTextScanned != null) {
                    onTextScanned(text);
                  }
                },
              );
            }),
            divider(context),
            buildActionItem(context,
                icon: Icons.mic_none,
                color: AppColor().primaryColor,
                title: "voice_note".tr,
                onTap: () => controller.startVoiceScan(
                      onResult: (text) => onTextScanned?.call(text),
                      dialogBuilder: (speechEngine) => VoiceListeningDialog(
                        speech: speechEngine,
                        backgroundColor: themeColor,
                        onResult: (text) => onTextScanned?.call(text),
                      ),
                    )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}

Widget divider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(
      height: 1,
      color: Colors.grey.withValues(alpha: 0.08),
    ),
  );
}

class VoiceListeningDialog extends StatefulWidget {
  final SpeechToText speech;
  final Function(String) onResult;
  final Color backgroundColor;

  const VoiceListeningDialog({
    super.key,
    required this.speech,
    required this.onResult,
    required this.backgroundColor,
  });

  @override
  State<VoiceListeningDialog> createState() => _VoiceListeningDialogState();
}

class _VoiceListeningDialogState extends State<VoiceListeningDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isListening = false;
  String _recognizedWords = "";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // _startListening();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // void _startListening() async {
  //   setState(() {
  //     _isListening = true;
  //     _recognizedWords = "";
  //   });
  //   _animationController.repeat(reverse: true);

  //   await widget.speech.listen(
  //     onResult: (result) {
  //       setState(() {
  //         _recognizedWords = result.recognizedWords;
  //       });

  //       if (result.finalResult) {
  //         _finalizeSpeech();
  //       }
  //     },
  //   );
  // }

  void _startListening() async {
    if (_isListening) return; // Prevent double trigger

    setState(() {
      _isListening = true;
      _recognizedWords = "";
    });
    _animationController.repeat(reverse: true);

    await widget.speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedWords = result.recognizedWords;
        });

        if (result.finalResult) {
          _finalizeSpeech();
        }
      },
    );
  }

  void _stopListening() async {
    await widget.speech.stop();
    _finalizeSpeech();
  }

  void _finalizeSpeech() {
    if (!mounted) return;
    _animationController.stop();
    setState(() => _isListening = false);

    if (_recognizedWords.trim().isNotEmpty) {
      widget.onResult(_recognizedWords);
    } else {
      AppSnackbar.showError(
        title: "error".tr,
        message: "no_text_detected_in_the_image".tr,
      );
    }
    Get.back();
  }

  void _cancelListening() async {
    await widget.speech.cancel();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: widget.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelListening,
                color: AppColor().gray,
              ),
            ),
            ScaleTransition(
              scale: _isListening
                  ? Tween(begin: 0.9, end: 1.1).animate(
                      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
                    )
                  : const AlwaysStoppedAnimation(1.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? AppColor().primaryColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                ),
                child: Icon(_isListening ? Icons.mic_rounded : Icons.mic_off_rounded, size: 54, color: _isListening ? AppColor().primaryColor : AppColor().gray),
              ),
            ),
            const SizedBox(height: 20),
            Text(_isListening ? "listening".tr : "listening".tr, style: text18(context)),
            const SizedBox(height: 8),
            Text(
              _isListening ? "speak_now".tr : "paused_speak".tr,
              style: text14(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "start".tr,
                    // onPressed: _isListening ? null : _startListening, // Trigger voice listening here
                    onPressed: _startListening,
                    backgroundColor: Colors.transparent,
                    // textColor: _startListening ? AppColor().gray : AppColor().black,
                    textColor: AppColor().black,
                    borderColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _isListening ? "stop".tr : "resume".tr,
                    onPressed: _isListening ? _stopListening : _startListening,
                    backgroundColor: _isListening ? AppColor().red : AppColor().primaryColor,
                    textColor: AppColor().white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
