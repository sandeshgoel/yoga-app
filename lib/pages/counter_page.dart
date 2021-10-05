import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:yoga/services/database.dart';

import 'package:yoga/services/tts.dart';
import 'package:yoga/services/audio.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/services/user_activity.dart';
import 'package:yoga/shared/constants.dart';

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
  bool _pausePressed = false;
  bool _playAfterPause = false;
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

  late String _uid;
  late String _email;

  @override
  void didChangeDependencies() {
    YogaSettings settings = Provider.of<YogaSettings>(context);
    _uid = settings.getUser().uid;
    _email = settings.getUser().email;

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
  Future dispose() async {
    int duration = _totSeconds.toInt();
    int rounds = _curRound;

    _timerClock.cancel();
    _am.pauseMusic();
    _tts.stop();
    Wakelock.disable();

    super.dispose();

    await _saveActivity(duration, rounds, _uid, _email);
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context);

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
                  // Exercise name
                  SizedBox(height: 20),
                  widget.routine == '' ? Container() : _exerciseName(settings),

                  // info

                  SizedBox(height: 20),
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
                      (_curExercise.altLeftRight & (_curRound % 2 == 0))
                          ? swapLeftRight(_curExercise.stages[_curStage].name)
                          : _curExercise.stages[_curStage].name,
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
                      // Reset button

                      CircleAvatar(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _resetCounter();
                            });
                          },
                          icon: Icon(Icons.restart_alt),
                        ),
                        backgroundColor: Colors.white,
                      ),

                      // Play button

                      CircleAvatar(
                        child: IconButton(
                          onPressed: !_paused ? null : () => _startTimer(),
                          icon: Icon(Icons.play_arrow),
                          iconSize: 40,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        radius: 30,
                      ),

                      // Pause button

                      CircleAvatar(
                        child: IconButton(
                          onPressed: _paused
                              ? null
                              : () {
                                  setState(() {
                                    _paused = true;
                                    _pausePressed = true;
                                    _tts.stop();
                                    _am.pauseMusic();
                                  });
                                },
                          icon: Icon(Icons.pause),
                          //iconSize: 40,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        //radius: 30,
                      ),
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
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseName(YogaSettings settings) {
    return Container(
      //height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip previous button

          Flexible(
            flex: 20,
            child: CircleAvatar(
              child: IconButton(
                onPressed: (_curExIndexInRoutine == 0)
                    ? null
                    : () {
                        setState(() {
                          _resetCounter();
                          _moveExerciseInRoutine(settings, -1);
                        });
                      },
                icon: Icon(Icons.skip_previous),
              ),
              backgroundColor: Colors.white,
            ),
          ),

          // Exercise name

          Flexible(
            flex: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '  Exercise ${_curExIndexInRoutine + 1}/' +
                      '${_routine.exercises.length}',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '$_curExerciseName',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Skip next button

          Flexible(
            flex: 20,
            child: CircleAvatar(
              child: IconButton(
                onPressed:
                    (_routine.exercises.length == _curExIndexInRoutine + 1)
                        ? null
                        : () {
                            setState(() {
                              _resetCounter();
                              _moveExerciseInRoutine(settings, 1);
                            });
                          },
                icon: Icon(Icons.skip_next),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ],
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cp.desc),
                  SizedBox(height: 20),
                  Icon(Icons.construction),
                ],
              ),
              actions: [
                /*
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Web')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Video')), */
                ElevatedButton(
                    onPressed: () => Navigator.pop(context), child: Text('OK'))
              ],
            ),
        barrierDismissible: false);
  }

  Future _saveActivity(
      int duration, int rounds, String uid, String email) async {
    if (duration > 30) {
      Map<String, dynamic> act = UserActivity(uid, email, _curExercise.name,
              DateTime.now(), duration, rounds, widget.routine)
          .toJson();
      await DBService(uid: uid, email: email).addUserActivity(act);
      print('Saved activity $email: ${_curExercise.name} $duration');
    }
  }

  void _resetCounter() async {
    int duration = _totSeconds.toInt();
    int rounds = _curRound;

    setState(() {
      _curCount = 1;
      _curStage = 0;
      _curRound = 1;
      _totSeconds = 0;
      if (widget.routine == '') _totSecondsRoutine = 0;
//      else if (_curExIndexInRoutine + 1 == _routine.exercises.length)
//        _totSecondsRoutine = 0;
      _reset = true;
    });

    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    await _saveActivity(
        duration, rounds, settings.getUser().uid, settings.getUser().email);
  }

  void _startTimer() async {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    setState(() {
      _paused = false;
      if (_pausePressed) {
        _pausePressed = false;
        _playAfterPause = true;
      }
    });

    _am.startMusic();
    if (_reset) {
      String msg = '';
      int gap = settings.getGapRoutine();

      if ((widget.routine != '') & !_playAfterPause & !_routine.noGap) {
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
          if (_paused) return;
        }
      }
      _playAfterPause = false;

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
            msg += ". ";
          else
            msg += ", ";
        }
      }

      msg += " Starting round 1 now ... ";
      await _tts.speak(context, msg);
    }

    _timerClock = new Timer.periodic(
        Duration(milliseconds: settings.getCountDuration()), _handleTimeout);

    if (_reset) {
      String stagename = _curExercise.stages[_curStage].name;
      // if count is muted and count>6, include total counts in stagename
      if (settings.getMuteCounting() &
          (_curExercise.stages[_curStage].count > 6)) {
        stagename += ' for ${_curExercise.stages[_curStage].count} counts . ';
      }

      await _tts.speak(context, stagename);
      _reset = false;
    }
  }

  void _pauseTimer(Timer t) {
    t.cancel();
    _am.pauseMusic();
  }

  void _moveExerciseInRoutine(YogaSettings settings, int step) {
    _curExIndexInRoutine += step;
    _curExerciseName = _routine.exercises[_curExIndexInRoutine].name;
    _curExerciseIndex = settings.findParamIndex(_curExerciseName);
    _curExercise = settings.getParam(_curExerciseIndex);

    _totRounds = _routine.exercises[_curExIndexInRoutine].rounds;
  }

  void _handleTimeout(Timer t) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    if (_paused) {
      _pauseTimer(t);
      return;
    }

    setState(() {
      Stage stage = _curExercise.stages[_curStage];
      int _totStages = _curExercise.stages.length;
      String msg = '';
      String postmsg = '';

      _totSeconds += settings.getCountDuration() / 1000;
      _totSecondsRoutine += settings.getCountDuration() / 1000;

      _curCount = (_curCount + 1);
      if (_curCount == stage.count + 1) _curCount = 1;

      if (_curCount == 1) {
        _curStage = (_curStage + 1) % _totStages;
        if (_curStage == 0) {
          _curRound++;
          if (_curRound > _totRounds) {
            // rounds are complete

            _pauseTimer(t);

            int _totMinutes = (_totSecondsRoutine + 30) ~/ 60;
            _resetCounter();

            if (widget.routine != '') {
              if (_routine.exercises.length > _curExIndexInRoutine + 1) {
                _moveExerciseInRoutine(settings, 1);
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
            // rounds not complete yet
            if (_curRound == _totRounds)
              postmsg = 'Last round . ';
            else if (_curRound == _totRounds - 2)
              postmsg = '3 rounds left . ';
            else if ((_totRounds > 10) & (_curRound == (_totRounds ~/ 2) + 1))
              postmsg = '${_totRounds - _curRound + 1} rounds left . ';
            else {
              if (settings.getMuteCounting()) {
                msg = '';
              } else
                msg = 'Round $_curRound ';
            }
          }
        }

        String stagename = _curExercise.stages[_curStage].name;
        // if count is muted and count>6, include total counts in stagename
        if (settings.getMuteCounting() &
            (_curExercise.stages[_curStage].count > 6)) {
          stagename += ' for ${_curExercise.stages[_curStage].count} counts . ';
        }

        // swap let and right, if needed
        if (_curExercise.altLeftRight & (_curRound % 2 == 0)) {
          stagename = swapLeftRight(stagename);
        }

        msg += stagename + ' . ' + postmsg;
        _tts.speak(context, msg);
      } else {
        if (!settings.getMuteCounting())
          _tts.speak(context, _curCount.toString());
      }
    }); //setState
  }

  // class end
}
