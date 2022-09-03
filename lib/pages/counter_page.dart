import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';
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
  bool _reset = true;
  int _curCount = 0;
  int _curStage = -1;
  int _curRound = 0;
  double _totSeconds = 0;
  late int _totRounds;
  double _totSecondsRoutine = 0;
  bool _paused = true;
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
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white.withOpacity(0.6),
                    ),
                    //height: 80,
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

                  // Stage number and name

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Stage ${_curStage + 1} of ${_curExercise.stages.length}',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: FittedBox(
                              child: Text(
                                _curStage == -1
                                    ? '-'
                                    : (_curExercise.altLeftRight &
                                            (_curRound % 2 == 0))
                                        ? swapLeftRight(
                                            _curExercise.stages[_curStage].name)
                                        : _curExercise.stages[_curStage].name,
                                style: TextStyle(fontSize: 30),
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Count

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
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
                          _curStage == -1
                              ? '/0'
                              : '/${_curExercise.stages[_curStage].count}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    )),
                  ),

                  // Time elapsed

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
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
                          onPressed: () async {
                            _tts.stop();
                            await _resetCounter();
                            setState(() {});
                          },
                          icon: Icon(Icons.restart_alt),
                        ),
                        backgroundColor: Colors.white,
                      ),

                      // Play button

                      CircleAvatar(
                        child: IconButton(
                          onPressed: !_paused
                              ? null
                              : () async {
                                  await _startExercise();
                                },
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
                              : () async {
                                  await _pauseExercise(pauseMusic: true);
                                  setState(() {});
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
                    margin: EdgeInsets.only(top: 30),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: new BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Text(
                      'Voice: ${settings.getVoice()}' +
                          (settings.getMuteCounting() ? ', Count muted' : '') +
                          (_curExercise.altLeftRight ? ', Alt' : ''),
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
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
                    : () async {
                        await _pauseExercise();
                        await _resetCounter();
                        setState(() {});
                        _moveExerciseInRoutine(settings, -1);
                        await _startExercise();
                        setState(() {});
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
                        : () async {
                            await _pauseExercise();
                            await _resetCounter();
                            setState(() {});
                            _moveExerciseInRoutine(settings, 1);
                            await _startExercise();
                            setState(() {});
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
    /*
    VideoPlayerController _controller = VideoPlayerController.network(cp
                .video ==
            ''
        ? 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
        : cp.video)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    */
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Info'),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cp.desc == ''
                      ? Text('No description provided',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 12))
                      : Text(
                          cp.desc,
                          style: TextStyle(fontSize: 14),
                        ),
                  SizedBox(height: 20),
                  cp.image == ''
                      ? Image.asset(
                          "assets/icon/yoga_icon_circular.png",
                          height: 100,
                        )
                      : Image.network(
                          cp.image,
                          height: 100,
                        ),
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: cp.video,
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final url = 'https://sites.google.com/view/yogabuddy';
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                    ),
                  ),

                  //Container(
                  //  height: 100,
                  //  child: AspectRatio(
                  //    aspectRatio: _controller.value.aspectRatio,
                  //    child: VideoPlayer(_controller),
                  //  ),
                  //),
                  SizedBox(height: 20),
                  Text(
                    'Exercise stages:\n',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    cp.stages
                        .map((s) => '- ${s.name} (${s.count} counts)')
                        .toList()
                        .join('\n'),
                    style: TextStyle(fontSize: 14),
                  )
                  //Icon(Icons.construction),
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
      print('Saving activity $email: ${_curExercise.name} $duration');
      await DBService(uid: uid, email: email).addUserActivity(act);
    }
  }

  Future<void> _resetCounter() async {
    int duration = _totSeconds.toInt();
    int rounds = _curRound;

    setState(() {
      _curCount = 0;
      _curStage = -1;
      _curRound = 0;
      _totSeconds = 0;
      if (widget.routine == '') _totSecondsRoutine = 0;
      _reset = true;
    });

    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    await _saveActivity(
        duration, rounds, settings.getUser().uid, settings.getUser().email);
  }

  Future<void> _pauseExercise({bool pauseMusic = false}) async {
    print('Pausing exercise ${_curExercise.name}');
    _paused = true;
    _timerClock.cancel();
    await _tts.stop();
    //await Future.delayed(Duration(milliseconds: 500), () {});
    if (pauseMusic) _am.pauseMusic();
    print('Done pausing exercise ${_curExercise.name}');
  }

  Future<void> _startExercise() async {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    print('Starting exercise ${_curExercise.name}, reset is $_reset');
    setState(() {
      _paused = false;
    });

    if (settings.getMusic()) _am.startMusic();

    bool brief = settings.getBrief();

    if (_reset) {
      String msg = '';
      int gap = settings.getGapRoutine();

      if (widget.routine != '') {
        if (_curExIndexInRoutine == 0) {
          msg = 'This routine has ${_routine.exercises.length} exercises. ';
          if (!_routine.noGap & (gap > 0) & !brief)
            msg += 'We will take a break of $gap seconds after each exercise. ';
          await _tts.speak(context, msg);
        }
      }

      msg = "The next exercise has $_totRounds round" +
          ((_totRounds > 1) ? 's' : '') +
          " of ${_curExercise.name}. ";

      if (!brief) {
        msg += "Each round has ${_curExercise.stages.length} ";
        if (_curExercise.stages.length == 1)
          msg += "stage. ";
        else
          msg += "stages. ";

        if (_curExercise.stages.length <= 2) {
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
      }

      msg += " Starting round 1 now ... ";
      await _tts.speak(context, msg);
      _reset = false;
    }
    _timerClock = new Timer(Duration(milliseconds: 200), _handleTimeout);
  }

  void _moveExerciseInRoutine(YogaSettings settings, int step) {
    _curExIndexInRoutine += step;
    _curExerciseName = _routine.exercises[_curExIndexInRoutine].name;
    _curExerciseIndex = settings.findParamIndex(_curExerciseName);
    _curExercise = settings.getParam(_curExerciseIndex);

    _totRounds = _routine.exercises[_curExIndexInRoutine].rounds;
  }

  void _handleTimeout() async {
    Stopwatch stopwatch = new Stopwatch()..start();
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    if (_paused) return;

    int _totStages = _curExercise.stages.length;
    String msg = '';
    String postmsg = '';

    _totSeconds += settings.getCountDuration() / 1000;
    _totSecondsRoutine += settings.getCountDuration() / 1000;

    _curCount = (_curCount + 1);
    if (_curStage > -1) {
      if (_curCount == _curExercise.stages[_curStage].count + 1) _curCount = 1;
    }

    if (_curCount == 1) {
      _curStage = (_curStage + 1) % _totStages;
      if (_curStage == 0) {
        _curRound++;
        if (_curRound > _totRounds) {
          // rounds are complete

          int _totMinutes = (_totSecondsRoutine + 30) ~/ 60;
          await _resetCounter();

          if (widget.routine != '') {
            if (_routine.exercises.length > _curExIndexInRoutine + 1) {
              _moveExerciseInRoutine(settings, 1);

              int gap = settings.getGapRoutine();
              if (!_routine.noGap &
                  _routine.exercises[_curExIndexInRoutine].gapBefore) {
                msg =
                    'The exercise is now complete, please relax for $gap seconds';

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(msg),
                  duration: Duration(seconds: gap + 4),
                ));

                await _tts.speak(context, msg);

                await Future.delayed(Duration(seconds: gap), () {});
                if (_paused) return;
              }
              await _startExercise();
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
              _am.pauseMusic();
              await _tts.speak(context, msg);
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
            _am.pauseMusic();
            await _tts.speak(context, msg);
          }

          return;
        } else {
          // rounds not complete yet
          if (_curRound == _totRounds) {
            if (_totRounds > 1) postmsg = 'Last round . ';
          } else if (_curRound == _totRounds - 2)
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
      setState(() {});
      await _tts.speak(context, msg);
    } else {
      setState(() {});
      if (!settings.getMuteCounting())
        await _tts.speak(context, _curCount.toString());
    }

    int timeRemaining =
        settings.getCountDuration() - stopwatch.elapsed.inMilliseconds;
    while ((timeRemaining < 100) &
        (_curCount < _curExercise.stages[_curStage].count)) {
      timeRemaining += settings.getCountDuration();
      _curCount += 1;
      _totSeconds += settings.getCountDuration() / 1000;
      _totSecondsRoutine += settings.getCountDuration() / 1000;
      setState(() {});
    }
    if (timeRemaining < 100) {
      timeRemaining = 100;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Speech overflow'),
        duration: Duration(seconds: 1),
      ));
    }
    //print('Done speaking ${stopwatch.elapsed.inMilliseconds}, ' +
    //    'starting timer for $timeRemaining ms...');
    _timerClock =
        new Timer(Duration(milliseconds: timeRemaining), _handleTimeout);
  }

  // class end
}
