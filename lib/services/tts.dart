import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Tts {
  final FlutterTts flutterTts = FlutterTts();
  double speechRate = 0.3;
  double pitch = 0.8;
  bool _debug = false;
  bool _speaking = false;

  Tts() {
    flutterTts.setSpeechRate(this.speechRate);
    flutterTts.setPitch(this.pitch);

    print('Setting start handler');
    flutterTts.setStartHandler(() {
      _speaking = true;
      print('tts started');
    });

    flutterTts.setCompletionHandler(() {
      _speaking = false;
      print('tts complete');
    });

    //var voices = await flutterTts.getLanguages;
    //print('Voices: $voices');
    //flutterTts.setVoice({"name": "Karen", "locale": "en-IN"});
  }

  void setSpeechRate(speechRate) {
    this.speechRate = speechRate;
    flutterTts.setSpeechRate(this.speechRate);
  }

  Future<void> speak(context, String msg) async {
    _speaking = true;
    var res = await flutterTts.speak(msg);
    print(res);
    if (_debug)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: Duration(milliseconds: 1000),
      ));

    while (_speaking) {
      await Future.delayed(Duration(milliseconds: 1000));
      print(_speaking);
    }
  }
}
