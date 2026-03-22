import 'package:audioplayers/audioplayers.dart';

class AudioPlaybackService {
  static final AudioPlaybackService _instance =
      AudioPlaybackService._internal();

  late final AudioPlayer _player;

  factory AudioPlaybackService() => _instance;

  AudioPlaybackService._internal() {
    _player = AudioPlayer();
  }

  Future<void> playFromUrl(String url) async {
    final normalized = url.trim();
    if (normalized.isEmpty) {
      throw Exception('Audio URL is empty');
    }

    await _player.stop();
    await _player.play(UrlSource(normalized));
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
