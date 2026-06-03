import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/views/create/components/image_zoom_compoenent.dart';
import 'package:project_structure/widgets/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/multi_style.dart';
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

        // Register custom builders for both content profiles
        embedBuilders: [
          CustomMediaEmbedBuilder(controller: controller, mediaType: BlockEmbed.imageType),
          CustomMediaEmbedBuilder(controller: controller, mediaType: BlockEmbed.videoType),
          CustomFileEmbedBuilder(),
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

// CUSTOM MEDIA (IMAGE/VIDEO) EMBED BUILDER
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
      title: widget.isVideo ? "Video Options" : "Image Options",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isVideo) ...[
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
          ],
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
                  buildActionItem(
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
                  divider(context),
                ],
                buildActionItem(
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
                divider(context),
                buildActionItem(
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

// CUSTOM FILE EMBED BUILDER WITH VIEW ACTION
class CustomFileEmbedBuilder implements EmbedBuilder {
  CustomFileEmbedBuilder();

  @override
  String get key => 'file';

  @override
  bool get expanded => false;

  Future<void> _viewFile(String filePath) async {
    if (filePath.isEmpty) {
      Get.snackbar("Error", "File path is empty.");
      return;
    }

    final File file = File(filePath);
    if (await file.exists()) {
      try {
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          Get.snackbar(
            "Cannot Open File",
            "No compatible application found on your device to open this file.",
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        Get.snackbar("Error", "An error occurred while trying to open the file: $e");
      }
    } else {
      Get.snackbar(
        "File Not Found",
        "The file no longer exists at its recorded path storage directory.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final String rawData = embedContext.node.value.data.toString();
    Map<String, dynamic> fileData = {};

    try {
      fileData = jsonDecode(rawData);
    } catch (e) {
      debugPrint("Error parsing custom file block metadata payload string: $e");
    }

    final String fileName = fileData['name'] ?? 'Unknown File';
    final String fileSize = fileData['size'] ?? '0 B';
    final String filePath = fileData['path'] ?? '';

    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: context.isPhone ? 0.85 : 0.65,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: GestureDetector(
            onTap: () => _viewFile(filePath),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColor().primaryColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.insert_drive_file_outlined,
                      color: AppColor().primaryColor,
                      size: context.isPhone ? 24 : 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text14(context),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fileSize,
                          style: text12,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, size: context.isPhone ? 24 : 26, color: AppColor().gray),
                    onPressed: () => _showFileActionSheet(context, embedContext, filePath, fileName),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFileActionSheet(BuildContext context, EmbedContext embedContext, String filePath, String fileName) {
    FocusManager.instance.primaryFocus?.unfocus();

    ConfirmBottomSheet.show(
      context: context,
      title: "File Options",
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              buildActionItem(
                context,
                icon: Icons.share_outlined,
                color: AppColor().primaryColor,
                title: "Share",
                onTap: () async {
                  Get.back();
                  if (filePath.isNotEmpty && await File(filePath).exists()) {
                    await Share.shareXFiles(
                      [XFile(filePath)],
                    );
                  } else {
                    Get.snackbar("Error", "File path doesn't exist anymore.");
                  }
                },
              ),
              divider(context),

              // Remove Option Item
              buildActionItem(
                context,
                icon: Icons.delete_outline,
                color: AppColor().red,
                title: "Remove",
                isDestructive: true,
                onTap: () {
                  Get.back();
                  final offset = embedContext.node.documentOffset;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    embedContext.controller.replaceText(
                      offset,
                      1,
                      '',
                      TextSelection.collapsed(offset: offset),
                    );

                    embedContext.controller.updateSelection(
                      const TextSelection.collapsed(offset: -1),
                      ChangeSource.local,
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  String toPlainText(Embed node) {
    try {
      final data = jsonDecode(node.value.data.toString());
      return "[File: ${data['name'] ?? ''}]\n";
    } catch (_) {
      return "[File]\n";
    }
  }

  @override
  WidgetSpan buildWidgetSpan(Widget child) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: child,
    );
  }
}

// VIDEO CONTROLLER COMPONENTS & VIEWS
class CustomVideoPlayerWithControls extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isInitialized;
  final VoidCallback onLongPress;
  final bool isFullScreenMode;

  const CustomVideoPlayerWithControls({
    super.key,
    required this.controller,
    required this.isInitialized,
    required this.onLongPress,
    this.isFullScreenMode = false,
  });

  @override
  State<CustomVideoPlayerWithControls> createState() => _CustomVideoPlayerWithControlsState();
}

class _CustomVideoPlayerWithControlsState extends State<CustomVideoPlayerWithControls> {
  bool _showControls = true;
  bool _isMuted = false;
  bool _isLocked = false;
  double _currentSpeed = 1.0;

  final List<double> _speeds = const [0.5, 1.0, 1.25, 2.0];

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _isMuted = widget.controller!.value.volume == 0;
      widget.controller!.addListener(_videoListener);
    }
  }

  void _videoListener() {
    if (widget.controller != null && mounted) {
      final value = widget.controller!.value;

      final isCurrentlyMuted = value.volume == 0;
      if (_isMuted != isCurrentlyMuted) {
        setState(() {
          _isMuted = isCurrentlyMuted;
        });
      }

      if (value.position >= value.duration && value.duration != Duration.zero) {
        setState(() {
          _showControls = true;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_videoListener);
    super.dispose();
  }

  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _handleFullScreenToggle(VideoPlayerController controller) {
    _closeKeyboard();
    if (widget.isFullScreenMode) {
      Get.back();
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      Get.to(
        () => FullScreenVideoPage(
          controller: controller,
          onLongPress: widget.onLongPress,
        ),
        transition: Transition.fadeIn,
      )?.then((_) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isInitialized || widget.controller == null) {
      return Container(
        height: widget.isFullScreenMode ? double.infinity : 220,
        color: Colors.black87,
        child: Center(
            child: CircularProgressIndicator(
          color: AppColor().white,
        )),
      );
    }

    final controller = widget.controller!;
    final bool isFinished = controller.value.position >= controller.value.duration && controller.value.duration != Duration.zero;

    return GestureDetector(
      onTap: () {
        _closeKeyboard();
        setState(() => _showControls = !_showControls);
      },
      onLongPress: _isLocked ? null : widget.onLongPress,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            if (_showControls)
              Positioned.fill(
                child: Container(color: Colors.black26),
              ),
            if (_isLocked && _showControls)
              Positioned(
                left: 0,
                top: 0,
                child: IconButton(
                  iconSize: context.isPhone ? 28 : 35,
                  icon: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(
                      Icons.lock_outline,
                      color: AppColor().white,
                      size: context.isPhone ? 20 : 25,
                    ),
                  ),
                  onPressed: () {
                    _closeKeyboard();
                    setState(() => _isLocked = false);
                  },
                ),
              ),
            if (_showControls && !_isLocked)
              Positioned(
                top: 12,
                left: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            size: context.isPhone ? 28 : 35,
                            widget.isFullScreenMode ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: AppColor().white,
                          ),
                          onPressed: () => _handleFullScreenToggle(controller),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.lock_open_outlined,
                            color: AppColor().white,
                            size: context.isPhone ? 20 : 30,
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _isLocked = true);
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        size: context.isPhone ? 20 : 25,
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: AppColor().white,
                      ),
                      onPressed: () {
                        _closeKeyboard();
                        setState(() {
                          if (_isMuted) {
                            controller.setVolume(1.0);
                            _isMuted = false;
                          } else {
                            controller.setVolume(0.0);
                            _isMuted = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            if (_showControls && !_isLocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: context.isPhone ? 28 : 35,
                    icon: Icon(
                      Icons.replay_10,
                      color: AppColor().white,
                    ),
                    onPressed: () {
                      _closeKeyboard();
                      final target = controller.value.position - const Duration(seconds: 10);
                      controller.seekTo(target < Duration.zero ? Duration.zero : target);
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    iconSize: context.isPhone ? 50 : 55,
                    icon: Icon(
                      (controller.value.isPlaying && !isFinished) ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: AppColor().white,
                    ),
                    onPressed: () {
                      _closeKeyboard();
                      setState(() {
                        if (isFinished) {
                          controller.seekTo(Duration.zero).then((_) => controller.play());
                        } else if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    iconSize: context.isPhone ? 28 : 35,
                    icon: Icon(
                      Icons.forward_10,
                      color: AppColor().white,
                    ),
                    onPressed: () {
                      _closeKeyboard();
                      final target = controller.value.position + const Duration(seconds: 10);
                      controller.seekTo(target > controller.value.duration ? controller.value.duration : target);
                    },
                  ),
                ],
              ),
            if (_showControls && !_isLocked)
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
                          style: TextStyle(color: AppColor().white, fontSize: 12),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                              activeTrackColor: AppColor().white,
                              inactiveTrackColor: Colors.white30,
                              thumbColor: AppColor().white,
                            ),
                            child: Slider(
                              value: currentSecs.clamp(0.0, totalSecs > 0 ? totalSecs : 1.0),
                              min: 0.0,
                              max: totalSecs > 0 ? totalSecs : 1.0,
                              onChangeStart: (_) {
                                _closeKeyboard();
                              },
                              onChanged: (val) {
                                controller.seekTo(Duration(seconds: val.toInt()));
                              },
                            ),
                          ),
                        ),
                        Text(
                          "-${_formatDuration(duration - position)}",
                          style: TextStyle(color: AppColor().white, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<double>(
                          icon: Icon(Icons.more_horiz, color: AppColor().white, size: context.isPhone ? 20 : 24),
                          tooltip: 'Playback Speed',
                          onOpened: () {
                            _closeKeyboard();
                          },
                          onSelected: (double speed) {
                            setState(() {
                              _currentSpeed = speed;
                              controller.setPlaybackSpeed(speed);
                            });
                          },
                          color: Theme.of(context).cardColor.withValues(alpha: 0.95),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (BuildContext context) {
                            return _speeds.map((double speed) {
                              final bool isSelected = _currentSpeed == speed;
                              return PopupMenuItem<double>(
                                value: speed,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      speed == 1.0 ? 'Normal' : '${speed}x',
                                      style: TextStyle(
                                        fontFamily: 'EN-REGULAR',
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? AppColor().primaryColor : null,
                                      ),
                                    ),
                                    if (isSelected) Icon(Icons.check, size: context.isPhone ? 16 : 20, color: AppColor().primaryColor),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
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
