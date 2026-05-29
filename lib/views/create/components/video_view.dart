import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/widgets/custom_confirm_bottomsheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

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

        // Register custom media builders for both Images and Videos alongside defaults
        embedBuilders: [
          CustomMediaEmbedBuilder(controller: controller, mediaType: BlockEmbed.imageType),
          CustomMediaEmbedBuilder(controller: controller, mediaType: BlockEmbed.videoType),
          ...FlutterQuillEmbeds.editorBuilders(),
        ],

        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            TextStyle(
              fontSize: context.isPhone ? 16 : 18,
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

/// Stateful Wrapper to manage, resize, and display both structural Images and interactive Videos
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
        // Play and pause immediately to force render the first frame as a picture preview thumbnail
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
      widget.controller.formatText(
        offset,
        1,
        attribute,
      );
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
            borderRadius: BorderRadius.circular(12),
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
      title: widget.isVideo ? "Video Options" : "Image Options",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
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
                            Text("Resize", style: text16(context)),
                            Text(
                              "${(_widthPercentage * 100).round()}%",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColor().primaryColor, fontFamily: rengular),
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
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.isVideo) ...[
                  _buildActionItem(
                    context,
                    icon: Icons.zoom_in_outlined,
                    color: AppColor().primaryColor,
                    title: "Zoom",
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.back();
                      final imagePath = widget.node.value.data.toString();

                      Get.to(
                        () => ImageZoomPage(imagePath: imagePath),
                        transition: Transition.fadeIn,
                      );
                    },
                  ),
                  _divider(context),
                ],
                _buildActionItem(
                  context,
                  icon: Icons.share_outlined,
                  color: AppColor().primaryColor,
                  title: "Share",
                  onTap: () async {
                    final mediaPath = widget.node.value.data.toString();
                    Get.back();

                    if (mediaPath.startsWith('http')) {
                      final response = await http.get(Uri.parse(mediaPath));
                      final tempDir = await getTemporaryDirectory();

                      final String ext = widget.isVideo ? 'mp4' : 'jpg';
                      final file = File('${tempDir.path}/shared_media.$ext');
                      await file.writeAsBytes(response.bodyBytes);

                      await Share.shareXFiles([XFile(file.path)]);
                    } else {
                      await Share.shareXFiles([XFile(mediaPath)]);
                    }
                  },
                ),
                _divider(context),
                _buildActionItem(
                  context,
                  icon: Icons.delete_outline,
                  color: AppColor().red,
                  title: "Remove",
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

/// Custom Player Layout displaying controls overlay mirroring your screenshot design
class CustomVideoPlayerWithControls extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isInitialized;
  final VoidCallback onLongPress;

  const CustomVideoPlayerWithControls({
    super.key,
    required this.controller,
    required this.isInitialized,
    required this.onLongPress,
  });

  @override
  State<CustomVideoPlayerWithControls> createState() => _CustomVideoPlayerWithControlsState();
}

class _CustomVideoPlayerWithControlsState extends State<CustomVideoPlayerWithControls> {
  bool _showControls = true;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isInitialized || widget.controller == null) {
      return Container(
        height: 220,
        color: Colors.black87,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final controller = widget.controller!;

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      onLongPress: widget.onLongPress,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Video Frame Viewport
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),

          // 2. Translucent dark shading backdrop matching your image layout
          // if (_showControls)
          //   Positioned.fill(
          //     child: Container(color: Colors.black87),
          //   ),

          // 3. Top Row Utility Menu Controls
          if (_showControls)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.closed_caption_off_outlined, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_off, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

          // 4. Center Primary Navigation Deck (Skip back 10s, Play/Pause, Fast forward 10s)
          if (_showControls)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 42,
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: () {
                    final target = controller.value.position - const Duration(seconds: 10);
                    controller.seekTo(target < Duration.zero ? Duration.zero : target);
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 64,
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      controller.value.isPlaying ? controller.pause() : controller.play();
                    });
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 42,
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: () {
                    final target = controller.value.position + const Duration(seconds: 10);
                    controller.seekTo(target > controller.value.duration ? controller.value.duration : target);
                  },
                ),
              ],
            ),

          // 5. Custom Live Seek Bar and Timeline Display Layer
          if (_showControls)
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, VideoPlayerValue value, child) {
                  final position = value.position;
                  final duration = value.duration;
                  final totalSecs = duration.inSeconds.toDouble();
                  final currentSecs = position.inSeconds.toDouble();

                  return Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white30,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: currentSecs.clamp(0.0, totalSecs > 0 ? totalSecs : 1.0),
                            min: 0.0,
                            max: totalSecs > 0 ? totalSecs : 1.0,
                            onChanged: (val) {
                              controller.seekTo(Duration(seconds: val.toInt()));
                            },
                          ),
                        ),
                      ),
                      Text(
                        "-${_formatDuration(duration - position)}",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildActionItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  required Color color,
  bool isDestructive = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppFontSize(context).descriptionLargeSize,
                  fontFamily: rengular,
                  color: isDestructive ? AppColor().red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _divider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(
      height: 1,
      color: Colors.grey.withValues(alpha: 0.08),
    ),
  );
}

class ImageZoomPage extends StatelessWidget {
  final String imagePath;
  const ImageZoomPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 5,
          child: imagePath.startsWith('http') ? Image.network(imagePath) : Image.file(File(imagePath)),
        ),
      ),
    );
  }
}
