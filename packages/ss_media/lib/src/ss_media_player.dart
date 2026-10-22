/// Common playback controls for SSFluxKit media implementations.
abstract class SSMediaPlayer {
  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();

  Stream<bool> get playingStream;

  bool get isPlaying;
}
