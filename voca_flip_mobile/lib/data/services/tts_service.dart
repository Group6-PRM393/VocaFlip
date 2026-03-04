import 'package:flutter_tts/flutter_tts.dart';


class TtsService {
  static final TtsService _instance = TtsService._internal();

  late final FlutterTts _tts;

  factory TtsService() {
    return _instance;
  }
  TtsService._internal() {
    _tts = FlutterTts()
      ..setLanguage('en-US')
      ..setSpeechRate(0.45)
      ..setVolume(1.0)
      ..setPitch(1.0);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.speak(text);
  }
  Future<void> stop() async {
    await _tts.stop();
  }
}
