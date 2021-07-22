import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import 'package:yoga/services/tts.dart';
import 'package:yoga/services/audio.dart';
import 'package:yoga/services/settings.dart';

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
    var settings = Provider.of<Settings>(context);
    int pindex = settings.findParamIndex(widget.cfg);
    _tts.setSpeechRate(settings.speechRate);
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
                Expanded(flex: 5, child: Container()),
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
                          style: TextStyle(fontSize: 40),
                        ),
                        Text(
                          ' of ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          ' ${settings.getParam(pindex).rounds}',
                          style: TextStyle(fontSize: 40),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: Container(
                    margin: EdgeInsets.all(16),
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
                Expanded(flex: 5, child: Container()),
                Expanded(
                  flex: 25,
                  child: Container(
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.6),
                    ),
                    child: Center(
                        child: Text(
                      _curCount.toString(),
                      style: TextStyle(fontSize: 80),
                    )),
                  ),
                ),
                Expanded(flex: 5, child: Container()),
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
                                fontSize: 20, fontWeight: FontWeight.bold))),
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

  void _resetCounter() {
    _curCount = 1;
    _curStage = 0;
    _curRound = 1;
    _totSeconds = 0;
    _reset = true;
  }

  void _startTimer() {
    var settings = Provider.of<Settings>(context, listen: false);

    if (_reset) {
      _tts.speak(context, "Starting routine ...");
      _reset = false;
    }
    _am.startMusic();
    _timerClock = new Timer.periodic(
        Duration(milliseconds: settings.countDuration), _handleTimeout);
    _paused = false;
  }

  void _handleTimeout(Timer t) {
    var settings = Provider.of<Settings>(context, listen: false);
    print(_paused);

    if (_paused) {
      t.cancel();
      _am.pauseMusic();
    } else {
      setState(() {
        int pindex = settings.findParamIndex(widget.cfg);
        ConfigParam cp = settings.getParam(pindex);
        Stage stage = cp.stages[_curStage];
        int _totStages = cp.stages.length;
        String msg = '';

        _totSeconds += settings.countDuration / 1000;

        _curCount = (_curCount + 1);
        if (_curCount == stage.count + 1) _curCount = 1;

        if (_curCount == 1) {
          _curStage = (_curStage + 1) % _totStages;
          if (_curStage == 0) {
            _curRound++;
            if (_curRound > cp.rounds) {
              t.cancel();
              _am.pauseMusic();

              msg = 'Your routine is complete!!\n' +
                  '${cp.rounds} rounds in ${_totSeconds.toInt()} seconds.';
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
