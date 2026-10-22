import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'ss_media_player.dart';

/// Video player using [video_player]. Replace with media_kit implementation later.
class SSVideoPlayer implements SSMediaPlayer {
  SSVideoPlayer();

  VideoPlayerController? _controller;

  VideoPlayerController? get controller => _controller;

  Future<void> initialize(String url) async {
    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller!.initialize();
  }

  @override
  Future<void> play() async {
    await _controller?.play();
  }

  @override
  Future<void> pause() async {
    await _controller?.pause();
  }

  @override
  Future<void> stop() async {
    await _controller?.pause();
    await _controller?.seekTo(Duration.zero);
  }

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  @override
  Stream<bool> get playingStream {
    final c = _controller;
    if (c == null) {
      return Stream.value(false);
    }
    late StreamController<bool> controller;
    void listener() {
      if (!controller.isClosed) {
        controller.add(c.value.isPlaying);
      }
    }

    controller = StreamController<bool>.broadcast(
      onListen: () {
        c.addListener(listener);
        listener();
      },
      onCancel: () => c.removeListener(listener),
    );
    return controller.stream;
  }

  @override
  bool get isPlaying => _controller?.value.isPlaying ?? false;
}

/// Widget wrapper for [SSVideoPlayer].
class SSVideoPlayerView extends StatelessWidget {
  const SSVideoPlayerView({super.key, required this.player});

  final SSVideoPlayer player;

  @override
  Widget build(BuildContext context) {
    final controller = player.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }
}
