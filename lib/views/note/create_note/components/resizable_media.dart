import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/note/create_note/components/image_zoom.dart';
import 'package:project_structure/views/note/create_note/components/quill/quill_video.dart';
import 'package:project_structure/widgets/custom_menu_item.dart.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_confirm_bottomsheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ResizableMediaWidget extends StatefulWidget {
  final Embed node;
  final QuillController controller;
  final double initialWidthPercentage;
  final bool isVideo;

  const ResizableMediaWidget({
    super.key,
    required this.node,
    required this.controller,
    required this.initialWidthPercentage,
    required this.isVideo,
  });

  @override
  State<ResizableMediaWidget> createState() => _ResizableMediaWidgetState();
}

class _ResizableMediaWidgetState extends State<ResizableMediaWidget> {
  late double _widthPercentage;
  VideoPlayerController? _videoPlayerController;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    _widthPercentage = widget.initialWidthPercentage;
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    final videoPath = widget.node.value.data.toString();
    if (videoPath.startsWith('http') || videoPath.startsWith('https')) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
    } else {
      _videoPlayerController = VideoPlayerController.file(File(videoPath));
    }

    _videoPlayerController?.initialize().then((_) async {
      if (mounted) {
        await _videoPlayerController?.play();
        await _videoPlayerController?.pause();

        setState(() {
          _isPlayerInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _updateMediaStyleInDocument(double val) {
    final offset = widget.node.documentOffset;
    final int widthInPercent = (val * 100).round();
    final styleString = "width: $widthInPercent%";

    final attribute = Attribute.fromKeyValue('style', styleString);
    if (attribute != null) {
      widget.controller.formatText(offset, 1, attribute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaPath = widget.node.value.data.toString();

    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: _widthPercentage,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: widget.isVideo
                ? CustomVideoPlayerWithControls(
                    controller: _videoPlayerController,
                    isInitialized: _isPlayerInitialized,
                    onLongPress: () => _showMediaActionSheet(context),
                  )
                : GestureDetector(
                    onTap: () {
                      _showMediaActionSheet(context);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: (mediaPath.startsWith('http') || mediaPath.startsWith('https')) ? Image.network(mediaPath, fit: BoxFit.cover) : Image.file(File(mediaPath), fit: BoxFit.cover),
                  ),
          ),
        ),
      ),
    );
  }

  void _showMediaActionSheet(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();

    ConfirmBottomSheet.show(
      context: context,
      title: widget.isVideo ? "video_options".tr : "image_options".tr,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isVideo) ...[
            StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10), boxShadow: AppDecorations.softShadow),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("resize".tr, style: text16(context)),
                              Text(
                                "${(_widthPercentage * 100).round()}%",
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColor().primaryColor, fontFamily: AppFonts().fontEngRegular),
                              ),
                            ],
                          ),
                        ),
                        Slider(
                          value: _widthPercentage,
                          min: 0.25,
                          max: 1.0,
                          divisions: 3,
                          activeColor: AppColor().primaryColor,
                          onChanged: (val) {
                            setModalState(() => _widthPercentage = val);
                            setState(() => _widthPercentage = val);
                          },
                          onChangeEnd: (val) {
                            _updateMediaStyleInDocument(val);
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10), boxShadow: AppDecorations.softShadow),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.isVideo) ...[
                  buildActionItem(
                    context,
                    icon: Icons.zoom_in_outlined,
                    color: AppColor().primaryColor,
                    title: "zoom".tr,
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.back();
                      final imagePath = widget.node.value.data.toString();

                      Get.to(
                        () => ImageZoomCompoenent(imagePath: imagePath),
                        transition: Transition.fadeIn,
                      );
                    },
                  ),
                  divider(context),
                ],
                buildActionItem(
                  context,
                  icon: Icons.share_outlined,
                  color: AppColor().primaryColor,
                  title: "share".tr,
                  onTap: () async {
                    final mediaPath = widget.node.value.data.toString();
                    Get.back();

                    if (mediaPath.startsWith('http')) {
                      final response = await http.get(Uri.parse(mediaPath));
                      final tempDir = await getTemporaryDirectory();

                      final String ext = widget.isVideo ? 'mp4' : 'jpg';
                      final file = File('${tempDir.path}/shared_media.$ext');

                      await file.writeAsBytes(response.bodyBytes);
                      // await Share.shareXFiles([XFile(file.path)]);
                      await SharePlus.instance.share(
                        ShareParams(
                          files: [XFile(file.path)],
                          // text: 'Check out this file',
                        ),
                      );
                    } else {
                      // await Share.shareXFiles([XFile(mediaPath)]);
                      await SharePlus.instance.share(
                        ShareParams(
                          files: [XFile(mediaPath)],
                        ),
                      );
                    }
                  },
                ),
                divider(context),
                buildActionItem(
                  context,
                  icon: Icons.delete_outline,
                  color: AppColor().red,
                  title: "remove".tr,
                  isDestructive: true,
                  onTap: () {
                    Get.back();
                    final offset = widget.node.documentOffset;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.controller.replaceText(
                        offset,
                        1,
                        '',
                        TextSelection.collapsed(offset: offset),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideoPage extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onLongPress;

  const FullScreenVideoPage({
    super.key,
    required this.controller,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: CustomVideoPlayerWithControls(
            controller: controller,
            isInitialized: true,
            onLongPress: onLongPress,
            isFullScreenMode: true,
          ),
        ),
      ),
    );
  }
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