import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Tts {
  FlutterTts flutterTts = FlutterTts();
  double speechRate = 0.3;
  double pitch = 0.8;
  bool _debug = false;

  Tts() {
    flutterTts.setSpeechRate(this.speechRate);
    flutterTts.setPitch(this.pitch);

    //var voices = await flutterTts.getLanguages;
    //print('Voices: $voices');
    //flutterTts.setVoice({"name": "Karen", "locale": "en-IN"});
  }

  void setSpeechRate(speechRate) {
    this.speechRate = speechRate;
    flutterTts.setSpeechRate(this.speechRate);
  }

  void speak(context, String msg) {
    flutterTts.speak(msg);
    if (_debug)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: Duration(milliseconds: 1000),
      ));
  }
}
