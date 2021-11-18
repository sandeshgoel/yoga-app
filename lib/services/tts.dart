import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Tts {
  final FlutterTts flutterTts = FlutterTts();
  String speechVoice = '';
  double speechRate = 0.3;
  double pitch = 0.8;
  bool _debug = false;

  Tts() {
    flutterTts.setSpeechRate(this.speechRate);
    flutterTts.setPitch(this.pitch);

    flutterTts.awaitSpeakCompletion(true);

    //var voices = await flutterTts.getLanguages;
    //print('Voices: $voices');
    flutterTts.setVoice({"name": "en-IN-language", "locale": "en-IN"});
    flutterTts.setLanguage("en-IN");
  }

  void setSpeechRate(speechRate) {
    this.speechRate = speechRate;
    flutterTts.setSpeechRate(this.speechRate);
  }

  void setSpeechVoice(speechVoice) {
    this.speechVoice = speechVoice;
    flutterTts.setVoice({"name": speechVoice, "locale": "en-IN"});
  }

  Future<void> speak(context, String msg) async {
    await flutterTts.speak(msg);

    if (_debug)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: Duration(milliseconds: 1000),
      ));
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }
}
