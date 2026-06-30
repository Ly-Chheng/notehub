import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_structure/views/note/create_note/components/resizable_media.dart';
import 'package:video_player/video_player.dart';
import 'package:project_structure/core/utils/app_color.dart';

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
