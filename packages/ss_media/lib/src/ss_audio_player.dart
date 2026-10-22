import 'package:just_audio/just_audio.dart';

import 'ss_media_player.dart';

/// Audio player backed by [just_audio]. Swap implementation without changing UI.
class SSAudioPlayer implements SSMediaPlayer {
  SSAudioPlayer({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  Future<void> setUrl(String url) => _player.setUrl(url);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();

  @override
  Stream<bool> get playingStream =>
      _player.playingStream;

  @override
  bool get isPlaying => _player.playing;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  AudioPlayer get rawPlayer => _player;
}
