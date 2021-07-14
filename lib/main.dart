import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
//import 'package:just_audio/just_audio.dart';
//import 'package:audio_manager/audio_manager.dart';
import 'package:audioplayers/audioplayers.dart';

import 'settings.dart';
import 'tts.dart';
//import 'pages/home_page.dart';

// ----------------------------------------------------

/*
void initMusic() {
  AudioManager.instance
      .start("assets/audio/yoga.mp3", "Yoga music",
          desc: "Relaxing yoga music", cover: "", auto: false)
      .then((err) {
    print(err);
  });

  AudioManager.instance.onEvents((events, args) {
    if (events != AudioManagerEvents.timeupdate) print("$events, $args");
    if (events == AudioManagerEvents.ended) startMusic();
  });
}

void startMusic() {
  // Play or pause; that is, pause if currently playing, otherwise play
  AudioManager.instance.play();
  print('Starting music');
}

void pauseMusic() {
  // Play or pause; that is, pause if currently playing, otherwise play
  AudioManager.instance.playOrPause();
  print('Pausing music');
}
*/

AudioCache player = AudioCache();
var audioPlayer;
bool audioInitialized = false;

void initMusic() async {
  audioPlayer = await player.loop("audio/yoga.mp3");
  audioInitialized = true;
  //audioPlayer.setUrl("assets/audio/yoga.mp3");
  //audioPlayer.setReleaseMode(ReleaseMode.LOOP);
}

void startMusic() {
  if (!audioInitialized)
    initMusic();
  else
    audioPlayer.resume();
  print('Starting music');
}

void pauseMusic() {
  audioPlayer.pause();
  print('Pausing music');
}

// ----------------------------------------------------

Random r = new Random();
int countDuration = 1800;

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Settings(),
      child: MyApp(),
    ),
  );

  //initSpeak();
  //initMusic();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoga Assist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Yoga Assist'),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ----------------------------------------------------

//import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.login),
          onPressed: () => {},
          tooltip: 'Login',
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => _editSettings(context),
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
          )
        ],
      ),
      body: _listConfigsPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addConfig(context),
        tooltip: 'Add Config',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _listConfigsPage() {
    return Consumer<Settings>(
      builder: (context, settings, _) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: settings.lengthParams(),
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: [
              Expanded(
                flex: 85,
                child: InkWell(
                  onTap: () =>
                      _configSelected(context, settings.getParam(index).name),
                  child: Container(
                    height: 50,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.amber[100],
                    ),
                    child: Center(
                        child: Text(
                      '${settings.getParam(index).name}',
                      style: TextStyle(fontSize: 20),
                    )),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(),
              ),
              Expanded(
                flex: 12,
                child: CircleAvatar(
                  radius: 25,
                  child: IconButton(
                    onPressed: () =>
                        _editConfig(context, settings.getParam(index).name),
                    icon: Icon(Icons.edit),
                    tooltip: 'Edit config',
                  ),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (BuildContext context, int index) => Container(
          height: 20,
        ),
      ),
    );
  }

  void _addConfig(context) {
    var settings = Provider.of<Settings>(context, listen: false);
    String cfgName;

    do {
      cfgName = 'Config ' + r.nextInt(1000).toString();
    } while (settings.findParamIndex(cfgName) != -1);

    settings.addParam(new ConfigParam(cfgName, 10, [Stage('Stagename', 4)]));
    _editConfig(context, cfgName);
  }

  void _configSelected(context, String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return CounterPage(cfg: cfg);
      }),
    ).then((value) {
      setState(() {});
    });
  }

  void _editConfig(context, String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditConfigPage(cfg: cfg);
      }),
    ).then((value) {
      setState(() {});
    });
  }

  void _editSettings(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditSettingsPage();
      }),
    ).then((value) {
      setState(() {});
    });
  }
}

// ----------------------------------------------------

class EditSettingsPage extends StatefulWidget {
  const EditSettingsPage({Key? key}) : super(key: key);

  @override
  _EditSettingsPageState createState() => _EditSettingsPageState();
}

class _EditSettingsPageState extends State<EditSettingsPage> {
  final _settingsFormKey = new GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: _editSettingsPage(),
    );
  }

  Widget _editSettingsPage() {
    var settings = Provider.of<Settings>(context, listen: false);

    return Column(children: <Widget>[
      FormBuilder(
        key: _settingsFormKey,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: FormBuilderSlider(
                name: 'duration',
                initialValue: countDuration.toDouble() / 1000,
                min: 1,
                max: 3,
                divisions: 20,
                decoration: InputDecoration(
                  labelText: 'Count Duration (seconds)',
                ),
                onChanged: (value) {
                  countDuration = (value! * 1000).toInt();
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: FormBuilderSlider(
                name: 'speech_rate',
                initialValue: settings.speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                decoration: InputDecoration(
                  labelText: 'Speech Rate',
                ),
                onChanged: (value) {
                  settings.setSpeechRate(value!.toDouble());
                },
              ),
            ),
          ],
        ),
      )
    ]);
  }
}

// ----------------------------------------------------

class EditConfigPage extends StatefulWidget {
  final String cfg;

  const EditConfigPage({Key? key, required this.cfg}) : super(key: key);

  @override
  _EditConfigPageState createState() => _EditConfigPageState();
}

class _EditConfigPageState extends State<EditConfigPage> {
  final _formKey = new GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Config'),
      ),
      body: _editConfigPage(context, widget.cfg),
    );
  }

  Widget _editConfigPage(context, cfg) {
    var settings = Provider.of<Settings>(context, listen: false);
    print('**** _editConfigPage: ${settings.cps}');
    var pindex = settings.findParamIndex(cfg);
    ConfigParam cp = settings.getParam(pindex);

    return FormBuilder(
      key: _formKey,
      child: ListView(
        children: [
              Container(
                  padding: EdgeInsets.all(16),
                  child: FormBuilderTextField(
                    name: 'configName',
                    initialValue: cfg,
                    decoration: InputDecoration(
                      labelText: 'Config Name',
                    ),
                  )),
              Container(
                  padding: EdgeInsets.all(16),
                  child: FormBuilderSlider(
                      name: 'rounds',
                      initialValue: cp.rounds.toDouble(),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      decoration: InputDecoration(
                        labelText: 'Number of rounds',
                      ))),
            ] +
            _stageList(settings, cfg) +
            [
              Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () => _saveConfig(context, cfg),
                          child: Text('Save')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () => _deleteConfig(context, cfg),
                          child: Text('Delete')),
                    ],
                  )),
            ],
      ),
    );
  }

  void _saveConfig(context, cfg) {
    var settings = Provider.of<Settings>(context, listen: false);
    int pindex = settings.findParamIndex(cfg);

    _formKey.currentState!.save();
    var values = _formKey.currentState!.value;

    String newName = values['configName'];
    if (newName != settings.getParam(pindex).name) {
      if (settings.findParamIndex(newName) != -1) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
                'The config name \'$newName\' already exists, choose a different name!!'),
            title: Text('ERROR'),
          ),
        );
        return;
      }
    }

    ConfigParam cp = settings.getParam(pindex);
    cp.name = values['configName'];
    cp.rounds = values['rounds'].toInt();
    for (var i = 0; i < cp.stages.length; i++) {
      cp.stages[i].name = values['stagename' + i.toString()];
      cp.stages[i].count = int.parse(values['stagecount' + i.toString()]);
    }
    settings.setParam(pindex, cp);

    Navigator.pop(context);
  }

  void _deleteConfig(context, cfg) {
    var settings = Provider.of<Settings>(context, listen: false);
    print('**** _deleteConfig: ${settings.cps}');
    settings.removeParam(cfg);

    Navigator.pop(context);
  }

  void _addStage(context, cfg) {
    var settings = Provider.of<Settings>(context, listen: false);

    setState(() {
      var pindex = settings.findParamIndex(cfg);
      ConfigParam cp = settings.getParam(pindex);
      cp.stages.add(Stage('Stagename', 4));
      settings.setParam(pindex, cp);
    });
  }

  void _deleteStage(context, cfg, i) {
    var settings = Provider.of<Settings>(context, listen: false);
    setState(() {
      var pindex = settings.findParamIndex(cfg);
      ConfigParam cp = settings.getParam(pindex);
      cp.stages.removeAt(i);
      settings.setParam(pindex, cp);
    });
  }

  List<Container> _stageList(settings, cfg) {
    List<Container> list = [];
    var pindex = settings.findParamIndex(cfg);
    var stages = settings.getParam(pindex).stages;

    list.add(Container(
        padding: EdgeInsets.all(16),
        child: Center(
            child: Text(
          'Stages: ${stages.length}',
          style: TextStyle(fontSize: 20),
        ))));

    for (var i = 0; i < stages.length; i++) {
      list.add(Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(flex: 10, child: Container()),
            Expanded(
              flex: 50,
              child: FormBuilderTextField(
                name: 'stagename$i',
                initialValue: stages[i].name,
              ),
            ),
            Expanded(flex: 10, child: Container()),
            Expanded(
              flex: 10,
              child: FormBuilderTextField(
                name: 'stagecount$i',
                initialValue: stages[i].count.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(flex: 5, child: Container()),
            Expanded(
              flex: 5,
              child: stages.length == 1
                  ? Container()
                  : IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _deleteStage(context, cfg, i),
                    ),
            ),
            Expanded(flex: 10, child: Container()),
          ],
        ),
      ));
    }

    list.add(Container(
      padding: EdgeInsets.all(16),
      child: CircleAvatar(
        child: IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _addStage(context, cfg),
          tooltip: 'Add Stage',
        ),
      ),
    ));

    return list;
  }
}

// ----------------------------------------------------

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

  @override
  void dispose() {
    _timerClock.cancel();
    pauseMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);
    int pindex = settings.findParamIndex(widget.cfg);
    _tts.setSpeechRate(settings.speechRate);

    return WillPopScope(
      onWillPop: () async {
        _paused = true;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.cfg),
        ),
        body: Column(
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
                  color: Colors.amber[100],
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
                  color: Colors.green,
                ),
                child: Center(
                    child: Text(
                  _curCount.toString(),
                  style: TextStyle(fontSize: 80),
                )),
              ),
            ),
            Expanded(
              flex: 20,
              child: Container(
                child: Center(
                    child: Text(
                  'TIME ELAPSED : ' +
                      (_totSeconds ~/ 60).toString() +
                      ' min ' +
                      (_totSeconds.toInt() % 60).toString() +
                      ' sec',
                  style: TextStyle(fontSize: 20),
                )),
              ),
            ),
            Expanded(
                flex: 10,
                child: Row(
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
                )),
            Expanded(flex: 5, child: Container()),
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
    if (_reset) {
      _tts.speak(context, "Starting routine ...");
      _reset = false;
    }
    startMusic();
    _timerClock = new Timer.periodic(
        Duration(milliseconds: countDuration), _handleTimeout);
    _paused = false;
  }

  void _handleTimeout(Timer t) {
    var settings = Provider.of<Settings>(context, listen: false);
    print(_paused);

    if (_paused) {
      t.cancel();
      pauseMusic();
    } else {
      setState(() {
        int pindex = settings.findParamIndex(widget.cfg);
        ConfigParam cp = settings.getParam(pindex);
        Stage stage = cp.stages[_curStage];
        int _totStages = cp.stages.length;
        String msg = '';

        _totSeconds += countDuration / 1000;

        _curCount = (_curCount + 1);
        if (_curCount == stage.count + 1) _curCount = 1;

        if (_curCount == 1) {
          _curStage = (_curStage + 1) % _totStages;
          if (_curStage == 0) {
            _curRound++;
            if (_curRound > cp.rounds) {
              t.cancel();

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

// ----------------------------------------------------
