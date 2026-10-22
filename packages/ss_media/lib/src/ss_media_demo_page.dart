import 'package:flutter/material.dart';

import 'ss_audio_player.dart';
import 'ss_video_player.dart';

/// Demo URLs — public samples, no API keys required.
class SSMediaSamples {
  SSMediaSamples._();

  static const audioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  static const videoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
}

class SSMediaDemoPage extends StatefulWidget {
  const SSMediaDemoPage({super.key});

  @override
  State<SSMediaDemoPage> createState() => _SSMediaDemoPageState();
}

class _SSMediaDemoPageState extends State<SSMediaDemoPage> {
  late final SSAudioPlayer _audioPlayer;
  late final SSVideoPlayer _videoPlayer;
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = SSAudioPlayer();
    _videoPlayer = SSVideoPlayer();
    _initMedia();
  }

  Future<void> _initMedia() async {
    try {
      await _audioPlayer.setUrl(SSMediaSamples.audioUrl);
      await _videoPlayer.initialize(SSMediaSamples.videoUrl);
    } catch (_) {
      // Network may fail in CI — UI still renders controls.
    }
    if (mounted) {
      setState(() => _audioReady = true);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('音频示例', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton(
              onPressed: _audioReady ? () => _audioPlayer.play() : null,
              child: const Text('播放'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _audioReady ? () => _audioPlayer.pause() : null,
              child: const Text('暂停'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('视频示例', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SSVideoPlayerView(player: _videoPlayer),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton(
              onPressed: () => _videoPlayer.play(),
              child: const Text('播放'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _videoPlayer.pause(),
              child: const Text('暂停'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '说明：当前使用 video_player 作为 MVP 实现；后续可替换为 media_kit 而不改业务层 API。',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
