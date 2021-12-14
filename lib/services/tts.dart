import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Tts {
  final FlutterTts flutterTts = FlutterTts();
  late Completer _speechCompleter;
  bool _playing = false;
  String speechVoice = '';
  double speechRate = 0.3;
  double pitch = 0.8;

  Tts() {
    flutterTts.setSpeechRate(this.speechRate);
    flutterTts.setPitch(this.pitch);

    flutterTts.awaitSpeakCompletion(true);
    flutterTts.setCompletionHandler(() {
      _speechCompleter.complete();
    });

    if (!kIsWeb)
      flutterTts.setVoice({"name": "en-IN-language", "locale": "en-IN"});
    flutterTts.setLanguage("en-IN");
  }

  void setSpeechRate(speechRate) {
    this.speechRate = speechRate;
    flutterTts.setSpeechRate(this.speechRate);
  }

  void setSpeechVoice(speechVoice) {
    this.speechVoice = speechVoice;
    if (!kIsWeb) flutterTts.setVoice({"name": speechVoice, "locale": "en-IN"});
  }

  Future<void> speak(context, String msg) async {
    _playing = true;
    _speechCompleter = Completer();

    await flutterTts.speak(msg);

    await _speechCompleter.future;
    //_speechCompleter = null as Completer;
    _playing = false;
  }

  Future<void> stop() async {
    if (_playing) {
      await flutterTts.stop();
      _speechCompleter.complete();
    }
  }
}
