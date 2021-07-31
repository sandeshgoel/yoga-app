import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:yoga/services/database.dart';

import 'package:yoga/services/tts.dart';
import 'package:yoga/services/audio.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/services/user_activity.dart';

class CounterPage extends StatefulWidget {
  final String cfg;
  const CounterPage({Key? key, required this.cfg}) : super(key: key);

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _curCount = 1;
  int _curStage = 0;
  int _curRound = 1;
  double _totSeconds = 0;
  bool _paused = true;
  bool _reset = true;
  Timer _timerClock = Timer(Duration(milliseconds: 100), () {});
  Tts _tts = Tts();
  AudioMusic _am = AudioMusic();

  @override
  void dispose() {
    _timerClock.cancel();
    _am.pauseMusic();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<YogaSettings>(context);
    int pindex = settings.findParamIndex(widget.cfg);
    _tts.setSpeechRate(settings.getSpeechRate());
    Wakelock.enable();

    return WillPopScope(
      onWillPop: () async {
        _paused = true;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.cfg),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 15,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Round ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          ' $_curRound ',
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' of ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          ' ${settings.getParam(pindex).rounds}',
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    //margin: EdgeInsets.all(16),
                    child: Center(
                        child: Text(
                      'Stage ${_curStage + 1} of ${settings.getParam(pindex).stages.length}',
                      style: TextStyle(fontSize: 12),
                    )),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.amber.withOpacity(0.6),
                    ),
                    child: Center(
                        child: Text(
                      settings.getParam(pindex).stages[_curStage].name,
                      style: TextStyle(fontSize: 40),
                    )),
                  ),
                ),
                Expanded(flex: 10, child: Container()),
                Expanded(
                  flex: 20,
                  child: Container(
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.8),
                            blurRadius: 10.0,
                            spreadRadius: 10.0,
                          ),
                        ]),
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _curCount.toString(),
                          style: TextStyle(
                              fontSize: 80, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '/${settings.getParam(pindex).stages[_curStage].count}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    )),
                  ),
                ),
                Expanded(flex: 10, child: Container()),
                Expanded(
                  flex: 10,
                  child: Container(
                    margin: EdgeInsets.all(16),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Center(
                      child: Text(
                        'TIME ELAPSED : ' +
                            (_totSeconds ~/ 60).toString() +
                            ' min ' +
                            (_totSeconds.toInt() % 60).toString() +
                            ' sec',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () => _startTimer(),
                            child: Text('Start')),
                        ElevatedButton(
                            onPressed: () {
                              _paused = true;
                            },
                            child: Text('Pause')),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _resetCounter();
                              });
                            },
                            child: Text('Reset')),
                      ],
                    )),
                Expanded(flex: 5, child: Container()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetCounter() async {
    /*
    var voices = await _tts.flutterTts.getVoices;
    for (var voice in voices) {
      if (voice['locale'] == 'en-IN') print('Voice: $voice');
    }*/
    int duration = _totSeconds.toInt();

    setState(() {
      _curCount = 1;
      _curStage = 0;
      _curRound = 1;
      _totSeconds = 0;
      _reset = true;
    });

    if (duration > 10) {
      var settings = Provider.of<YogaSettings>(context, listen: false);
      int pindex = settings.findParamIndex(widget.cfg);
      ConfigParam cp = settings.getParam(pindex);

      Map<String, dynamic> act =
          UserActivity(settings.uid, cp.name, DateTime.now(), duration)
              .toJson();
      await DBService(uid: settings.uid).addUserActivity(act);
    }
  }

  void _startTimer() async {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    int pindex = settings.findParamIndex(widget.cfg);
    ConfigParam cp = settings.getParam(pindex);

    _am.startMusic();
    if (_reset) {
      String msg = "This routine has ${cp.rounds} rounds of ${cp.name}. ";
      msg += "Each round has ${cp.stages.length} stages. ";
      for (var i = 0; i < cp.stages.length; i++) {
        msg += "${cp.stages[i].name}";
        if (i == (cp.stages.length - 2))
          msg += " and ";
        else if (i == (cp.stages.length - 1))
          msg += ".";
        else
          msg += ", ";
      }
      msg += " Starting round 1 now ... ${cp.stages[0].name}";
      print(msg);
      await _tts.speak(context, msg);
      _reset = false;
    }

    _timerClock = new Timer.periodic(
        Duration(milliseconds: settings.getCountDuration()), _handleTimeout);
    _paused = false;
  }

  void _pauseTimer(Timer t) {
    t.cancel();
    _am.pauseMusic();
  }

  void _handleTimeout(Timer t) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    print(_paused);

    if (_paused) {
      _pauseTimer(t);
    } else {
      setState(() {
        int pindex = settings.findParamIndex(widget.cfg);
        ConfigParam cp = settings.getParam(pindex);
        Stage stage = cp.stages[_curStage];
        int _totStages = cp.stages.length;
        String msg = '';

        _totSeconds += settings.getCountDuration() / 1000;

        _curCount = (_curCount + 1);
        if (_curCount == stage.count + 1) _curCount = 1;

        if (_curCount == 1) {
          _curStage = (_curStage + 1) % _totStages;
          if (_curStage == 0) {
            _curRound++;
            if (_curRound > cp.rounds) {
              _pauseTimer(t);

              msg = 'Your routine is complete!!\n' +
                  '${cp.rounds} rounds in about ${(_totSeconds + 30) ~/ 60} minutes.';
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        content: Text(msg),
                        title: Text('Complete'),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                _resetCounter();
                                Navigator.pop(context);
                              },
                              child: Text('OK'))
                        ],
                      ),
                  barrierDismissible: false);
              _tts.speak(context, msg);
              return;
            } else {
              msg = 'Round $_curRound ';
            }
          }
          msg += cp.stages[_curStage].name;
          _tts.speak(context, msg);
        } else {
          _tts.speak(context, _curCount.toString());
        }
      });
    }
  }
}
