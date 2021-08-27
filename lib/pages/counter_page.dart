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
  final String exercise;
  final String routine;
  const CounterPage({Key? key, required this.exercise, required this.routine})
      : super(key: key);

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _curCount = 1;
  int _curStage = 0;
  int _curRound = 1;
  late int _totRounds;
  double _totSeconds = 0;
  double _totSecondsRoutine = 0;
  bool _paused = true;
  bool _reset = true;
  Timer _timerClock = Timer(Duration(milliseconds: 100), () {});
  Tts _tts = Tts();
  AudioMusic _am = AudioMusic();

  late String _curExerciseName;
  late int _curExerciseIndex;
  late ConfigParam _curExercise;

  // following will be initialised and used only if widget.routine is not empty
  late int _routineIndex;
  late Routine _routine;
  int _curExIndexInRoutine = 0;

  @override
  void didChangeDependencies() {
    var settings = Provider.of<YogaSettings>(context);
    if (widget.routine == '') {
      _curExerciseName = widget.exercise;
    } else {
      _routineIndex = settings.findRoutineIndex(widget.routine);
      _routine = settings.getRoutine(_routineIndex);
      _curExerciseName = _routine.exercises[0].name;
    }
    _curExerciseIndex = settings.findParamIndex(_curExerciseName);
    _curExercise = settings.getParam(_curExerciseIndex);

    if (widget.routine == '')
      _totRounds = _curExercise.rounds;
    else
      _totRounds = _routine.exercises[_curExIndexInRoutine].rounds;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timerClock.cancel();
    _am.pauseMusic();
    _tts.stop();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<YogaSettings>(context);

    _tts.setSpeechRate(settings.getSpeechRate());
    _tts.setSpeechVoice(settings.getVoice());

    Wakelock.enable();

    double dur = (widget.routine == '') ? _totSeconds : _totSecondsRoutine;

    return WillPopScope(
      onWillPop: () async {
        _paused = true;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.routine == ''
              ? 'Exercise: ${widget.exercise}'
              : 'Routine: ${widget.routine}'),
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
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),

                  // Exercise name

                  widget.routine == ''
                      ? Container()
                      : Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_curExerciseName',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '  Exercise ${_curExIndexInRoutine + 1}/' +
                                    '${_routine.exercises.length}',
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                        ),

                  // info

                  ElevatedButton(
                      onPressed: () {
                        _infoExercise(_curExerciseName);
                      },
                      child: Text('Know more about this exercise')),

                  // Round number

                  Container(
                    height: 80,
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
                          ' $_totRounds',
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Stage number

                  Container(
                    padding: EdgeInsets.all(10),
                    child: Center(
                        child: Text(
                      'Stage ${_curStage + 1} of ${_curExercise.stages.length}',
                      style: TextStyle(fontSize: 12),
                    )),
                  ),

                  // Stage name

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.amber.withOpacity(0.6),
                    ),
                    child: Center(
                        child: Text(
                      _curExercise.stages[_curStage].name,
                      style: TextStyle(fontSize: 30),
                    )),
                  ),

                  // Count

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 40),
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
                          '/${_curExercise.stages[_curStage].count}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    )),
                  ),

                  // Time elapsed

                  Container(
                    margin: EdgeInsets.all(20),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Center(
                      child: Text(
                        'TIME ELAPSED : ${dur ~/ 60} min ' +
                            '${dur.toInt() % 60} sec',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Buttons

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () => _startTimer(), child: Text('Start')),
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
                  ),

                  // Voice and info

                  Container(
                    margin: EdgeInsets.only(top: 40),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: new BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Text('Voice: ${settings.getVoice()}' +
                        (settings.getMuteCounting() ? ', Count muted' : '') +
                        (_curExercise.altLeftRight ? ', Alt' : '')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _infoExercise(String cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    int index = settings.findParamIndex(cfg);
    ConfigParam cp = settings.getParam(index);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Info'),
              content: Text(cp.desc),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Web')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Video')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context), child: Text('OK'))
              ],
            ),
        barrierDismissible: false);
  }

  void _resetCounter() async {
    int duration = _totSeconds.toInt();
    int rounds = _curRound;

    setState(() {
      _curCount = 1;
      _curStage = 0;
      _curRound = 1;
      _totSeconds = 0;
      if (widget.routine == '')
        _totSecondsRoutine = 0;
      else if (_curExIndexInRoutine + 1 == _routine.exercises.length)
        _totSecondsRoutine = 0;
      _reset = true;
    });

    if (duration > 30) {
      var settings = Provider.of<YogaSettings>(context, listen: false);

      Map<String, dynamic> act = UserActivity(
              settings.getUser().uid,
              settings.getUser().email,
              _curExercise.name,
              DateTime.now(),
              duration,
              rounds,
              widget.routine)
          .toJson();
      await DBService(uid: settings.getUser().uid).addUserActivity(act);
    }
  }

  void _startTimer() async {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    _am.startMusic();
    if (_reset) {
      String msg = '';
      int gap = settings.getGapRoutine();

      if (widget.routine != '') {
        if (_curExIndexInRoutine == 0) {
          msg = 'This routine has ${_routine.exercises.length} exercises. ';
          msg += 'We will take a break of $gap seconds after each exercise. ';
          await _tts.speak(context, msg);
        } else {
          msg = 'The exercise is now complete, please relax for $gap seconds';

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            duration: Duration(seconds: gap + 4),
          ));

          await _tts.speak(context, msg);
          await Future.delayed(Duration(seconds: gap), () {});
        }
      }
      msg =
          "The next exercise has $_totRounds rounds of ${_curExercise.name}. ";
      msg += "Each round has ${_curExercise.stages.length} ";
      if (_curExercise.stages.length == 1)
        msg += "stage. ";
      else
        msg += "stages. ";

      if (_curExercise.stages.length <= 4) {
        for (var i = 0; i < _curExercise.stages.length; i++) {
          msg += "${_curExercise.stages[i].name}";
          if (i == (_curExercise.stages.length - 2))
            msg += " and ";
          else if (i == (_curExercise.stages.length - 1))
            msg += ".";
          else
            msg += ", ";
        }
      }

      msg += " Starting round 1 now ... ";
      await _tts.speak(context, msg);
      _reset = false;
    }

    _timerClock = new Timer.periodic(
        Duration(milliseconds: settings.getCountDuration()), _handleTimeout);
    _paused = false;

    await _tts.speak(context, _curExercise.stages[0].name);
  }

  void _pauseTimer(Timer t) {
    t.cancel();
    _am.pauseMusic();
  }

  void _handleTimeout(Timer t) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    if (_paused) {
      _pauseTimer(t);
    } else {
      setState(() {
        Stage stage = _curExercise.stages[_curStage];
        int _totStages = _curExercise.stages.length;
        String msg = '';

        _totSeconds += settings.getCountDuration() / 1000;
        _totSecondsRoutine += settings.getCountDuration() / 1000;

        _curCount = (_curCount + 1);
        if (_curCount == stage.count + 1) _curCount = 1;

        if (_curCount == 1) {
          _curStage = (_curStage + 1) % _totStages;
          if (_curStage == 0) {
            _curRound++;
            if (_curRound > _totRounds) {
              _pauseTimer(t);

              int _totMinutes = (_totSecondsRoutine + 30) ~/ 60;
              _resetCounter();

              if (widget.routine != '') {
                if (_routine.exercises.length > _curExIndexInRoutine + 1) {
                  _curExIndexInRoutine += 1;
                  _curExerciseName =
                      _routine.exercises[_curExIndexInRoutine].name;
                  _curExerciseIndex = settings.findParamIndex(_curExerciseName);
                  _curExercise = settings.getParam(_curExerciseIndex);

                  _totRounds = _routine.exercises[_curExIndexInRoutine].rounds;

                  _startTimer();
                } else {
                  msg = 'Your routine is complete!!\n' +
                      '${_routine.exercises.length} exercises in about ' +
                      '$_totMinutes minutes.';
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            content: Text(msg),
                            title: Text('Routine Complete'),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    int count = 0;
                                    Navigator.of(context)
                                        .popUntil((_) => count++ >= 2);
                                  },
                                  child: Text('OK'))
                            ],
                          ),
                      barrierDismissible: false);
                  _tts.speak(context, msg);
                }
              } else {
                msg = 'Your exercise is complete!!\n' +
                    '$_totRounds rounds in about ' +
                    '$_totMinutes minutes.';
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          content: Text(msg),
                          title: Text('Exercise Complete'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  int count = 0;
                                  Navigator.of(context)
                                      .popUntil((_) => count++ >= 2);
                                },
                                child: Text('OK'))
                          ],
                        ),
                    barrierDismissible: false);
                _tts.speak(context, msg);
              }

              return;
            } else {
              if (_curRound == _totRounds)
                msg = 'Last round . ';
              else if (_curRound == _totRounds - 2)
                msg = '3 rounds left . ';
              else {
                if (settings.getMuteCounting()) {
                  msg = '';
                } else
                  msg = 'Round $_curRound ';
              }
            }
          }

          String stagename = _curExercise.stages[_curStage].name;
          if (_curExercise.altLeftRight & (_curRound % 2 == 0)) {
            List<String> words = stagename.split(' ');
            for (var i = 0; i < words.length; i++) {
              if (words[i].toLowerCase() == 'left')
                words[i] = 'right';
              else if (words[i].toLowerCase() == 'right') words[i] = 'left';
            }
            stagename = words.join(' ');
          }
          print(stagename);
          msg += stagename;
          _tts.speak(context, msg);
        } else {
          if (!settings.getMuteCounting() |
              ((_curRound == 1) & (_totRounds > 1)))
            _tts.speak(context, _curCount.toString());
        }
      });
    }
  }
}
