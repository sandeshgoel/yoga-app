import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_tts/flutter_tts.dart';

//import 'package:just_audio/just_audio.dart';
//import 'package:audio_manager/audio_manager.dart';
import 'package:audioplayers/audioplayers.dart';

//import 'pages/home_page.dart';

// ----------------------------------------------------

FlutterTts flutterTts = FlutterTts();
double speechRate = 0.3;

void initSpeak() {
  flutterTts.setSpeechRate(speechRate);
  flutterTts.setPitch(0.8);

  //var voices = await flutterTts.getLanguages;
  //print('Voices: $voices');
  //flutterTts.setVoice({"name": "Karen", "locale": "en-IN"});
}

void speak(context, String msg) {
  flutterTts.speak(msg);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    duration: Duration(milliseconds: 1000),
  ));
}

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

class Stage {
  String name;
  int count;

  Stage(this.name, this.count);

  @override
  String toString() {
    return 'Stage: {name: $name, count: $count}';
  }
}

class ConfigParam {
  String name;
  int rounds;
  List<Stage> stages;

  ConfigParam(this.name, this.rounds, this.stages);
}

int findParamIndex(String cfg) {
  for (var pindex = 0; pindex < gConfigParams.length; pindex++) {
    if (gConfigParams[pindex].name == cfg) return pindex;
  }
  return -1;
}

// ----------------------------------------------------

Random r = new Random();
List<ConfigParam> gConfigParams = <ConfigParam>[];
int countDuration = 1800;

void main() async {
  gConfigParams.add(new ConfigParam('Anulom Vilom', 10, [
    Stage('Inhale Left', 4),
    Stage('Exhale Right', 4),
    Stage('Inhale Right', 4),
    Stage('Exhale Left', 4),
  ]));
  gConfigParams.add(new ConfigParam('Deep Breathing', 20, [
    Stage('Inhale', 4),
    Stage('Exhale', 4),
  ]));

  runApp(MyApp());

  initSpeak();
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
            onPressed: () => _editSettings(),
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
          )
        ],
      ),
      body: _listConfigsPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addConfig,
        tooltip: 'Add Config',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _listConfigsPage() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: gConfigParams.length,
      itemBuilder: (BuildContext context, int index) {
        return Row(
          children: [
            Expanded(
              flex: 85,
              child: InkWell(
                onTap: () => _configSelected(gConfigParams[index].name),
                child: Container(
                  height: 50,
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: Colors.amber[100],
                  ),
                  child: Center(
                      child: Text(
                    '${gConfigParams[index].name}',
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
                  onPressed: () => _editConfig(gConfigParams[index].name),
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
    );
  }

  void _addConfig() {
    String cfgName;

    do {
      cfgName = 'Config ' + r.nextInt(1000).toString();
    } while (findParamIndex(cfgName) != -1);
    gConfigParams.add(new ConfigParam(cfgName, 10, [Stage('Stagename', 4)]));
    _editConfig(cfgName);
  }

  void _configSelected(String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return CounterPage(cfg: cfg);
      }),
    ).then((value) {
      setState(() {});
    });
  }

  void _editConfig(String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditConfigPage(cfg: cfg);
      }),
    ).then((value) {
      setState(() {});
    });
  }

  void _editSettings() {
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
                initialValue: speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                decoration: InputDecoration(
                  labelText: 'Speech Rate',
                ),
                onChanged: (value) {
                  speechRate = value!.toDouble();
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
      body: _editConfigPage(widget.cfg),
    );
  }

  Widget _editConfigPage(cfg) {
    var pindex = findParamIndex(cfg);
    ConfigParam cp = gConfigParams[pindex];

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
            _stageList(cfg) +
            [
              Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () => _saveConfig(cfg),
                          child: Text('Save')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () => _deleteConfig(cfg),
                          child: Text('Delete')),
                    ],
                  )),
            ],
      ),
    );
  }

  void _saveConfig(cfg) {
    int pindex = findParamIndex(cfg);

    _formKey.currentState!.save();
    var values = _formKey.currentState!.value;

    String newName = values['configName'];
    if (newName != gConfigParams[pindex].name) {
      if (findParamIndex(newName) != -1) {
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

    gConfigParams[pindex].name = values['configName'];
    gConfigParams[pindex].rounds = values['rounds'].toInt();
    for (var i = 0; i < gConfigParams[pindex].stages.length; i++) {
      gConfigParams[pindex].stages[i].name = values['stagename' + i.toString()];
      gConfigParams[pindex].stages[i].count =
          int.parse(values['stagecount' + i.toString()]);
    }
    Navigator.pop(context);
  }

  void _deleteConfig(cfg) {
    var pindex = findParamIndex(cfg);
    gConfigParams.removeAt(pindex);
    Navigator.pop(context);
  }

  void _addStage(cfg) {
    setState(() {
      var pindex = findParamIndex(cfg);
      gConfigParams[pindex].stages.add(Stage('Stagename', 4));
    });
  }

  void _deleteStage(cfg, i) {
    setState(() {
      var pindex = findParamIndex(cfg);
      gConfigParams[pindex].stages.removeAt(i);
    });
  }

  List<Container> _stageList(cfg) {
    List<Container> list = [];
    var pindex = findParamIndex(cfg);
    var stages = gConfigParams[pindex].stages;

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
                      onPressed: () => _deleteStage(cfg, i),
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
          onPressed: () => _addStage(cfg),
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
  bool _paused = true;
  bool _reset = true;
  double _totSeconds = 0;

  @override
  Widget build(BuildContext context) {
    int pindex = findParamIndex(widget.cfg);

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
                      ' ${gConfigParams[pindex].rounds}',
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
                  gConfigParams[pindex].stages[_curStage].name,
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
      speak(context, "Starting routine ...");
      _reset = false;
    }
    startMusic();
    new Timer.periodic(Duration(milliseconds: countDuration), _handleTimeout);
    _paused = false;
  }

  void _handleTimeout(Timer t) {
    if (_paused) {
      t.cancel();
      pauseMusic();
    } else {
      setState(() {
        int pindex = findParamIndex(widget.cfg);
        ConfigParam cp = gConfigParams[pindex];
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
              speak(context, msg);
              return;
            } else {
              msg = 'Round $_curRound ';
            }
          }
          msg += cp.stages[_curStage].name;
          speak(context, msg);
        } else {
          speak(context, _curCount.toString());
        }
      });
    }
  }
}

// ----------------------------------------------------
