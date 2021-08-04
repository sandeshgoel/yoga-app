import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoga/services/database.dart';

class Stage {
  late String name;
  late int count;

  Stage(this.name, this.count);

  @override
  String toString() {
    return '{$name, $count}';
  }

  Map<String, dynamic> toJson() {
    return {'name': this.name, 'count': this.count};
  }

  Stage.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.count = json['count'];
  }
}

// ------------------------------------------------------

class ConfigParam {
  late String name;
  late int rounds;
  late List<Stage> stages;

  ConfigParam(this.name, this.rounds, this.stages);

  @override
  String toString() {
    return '{$name, $rounds, stages: $stages}\n';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'rounds': this.rounds,
      'stages': this.stages.map((x) => x.toJson()).toList()
    };
  }

  ConfigParam.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.rounds = json['rounds'];
    this.stages = json['stages'].map<Stage>((x) => Stage.fromJson(x)).toList();
  }
}

class Exercise {
  late String name;
  late int rounds;

  Exercise(this.name, this.rounds);

  @override
  String toString() {
    return '{$name, $rounds\n';
  }

  Map<String, dynamic> toJson() {
    return {'name': this.name, 'rounds': this.rounds};
  }

  Exercise.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.rounds = json['rounds'];
  }
}

class Routine {
  late String name;
  late List<Exercise> exercises;

  Routine(this.name, this.exercises);

  @override
  String toString() {
    return '{$name, exercises: $exercises}\n';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'exercises': this.exercises.map((x) => x.toJson()).toList()
    };
  }

  Routine.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.exercises =
        json['exercises'].map<Exercise>((x) => Exercise.fromJson(x)).toList();
  }
}

const exAnulomVilom = 'Anulom Vilom';
const exDeepBreathing = 'Deep Breathing';
const exBhramari = 'Bhramari';
const exSheetkari = 'Sheetkari';
const exSuryaBhedi = 'Surya Bhedi';
const exChandraBhedi = 'Chandra Bhedi';
const exKapaalBhaati = 'Kapaal Bhaati';
const exBhastrika = 'Bhastrika';

// ------------------------------------------------------

class YogaSettings with ChangeNotifier {
  late String _uid;
  late String _email;
  late String _name;
  late String _photo;
  late bool _verified;

  late List<String> _voices;
  late String _speechVoice;
  late double _speechRate;
  late int _countDuration;
  late int _dailyTarget;
  late int _gapRoutine;
  late bool _muteCounting;

  late List<ConfigParam> cps;
  late List<Routine> routines;

  YogaSettings() {
    initSettings();
  }

  void initSettings() {
    _name = '';
    _email = '';
    _uid = '';
    _photo = '';
    _verified = false;

    _voices = [];
    _speechVoice = '';
    _speechRate = 0.3;
    _countDuration = 1800;
    _dailyTarget = 10;
    _gapRoutine = 5;
    _muteCounting = false;

    cps = [_exerciseLib[0]];
    routines = [_routineLib[0]];
  }

  // ----------------------------------------------------

  List<Routine> _routineLib = [
    Routine('Daily 10', [
      Exercise(exDeepBreathing, 10),
      Exercise(exBhramari, 10),
      Exercise(exAnulomVilom, 10),
      Exercise(exSheetkari, 10),
    ]),
    Routine('Routine 2', [
      Exercise(exDeepBreathing, 10),
      Exercise(exBhramari, 10),
      Exercise(exChandraBhedi, 10),
      Exercise(exSheetkari, 10),
    ])
  ];

  List<Routine> getRoutineLib() {
    return _routineLib;
  }

  Routine? getRoutineFromLib(String name) {
    for (int i = 0; i < _routineLib.length; i++) {
      if (_routineLib[i].name == name) return _routineLib[i];
    }
    print('getRoutineFromLib: Routine $name not found!!');
    return null;
  }

  // ----------------------------------------------------

  List<ConfigParam> _exerciseLib = [
    ConfigParam(exAnulomVilom, 10, [
      Stage('Inhale Left', 4),
      Stage('Exhale Right', 4),
      Stage('Inhale Right', 4),
      Stage('Exhale Left', 4),
    ]),
    ConfigParam(exDeepBreathing, 20, [Stage('Inhale', 4), Stage('Exhale', 4)]),
    ConfigParam(exBhramari, 10,
        [Stage('Inhale', 3), Stage('Exhale with humming sound', 6)]),
    ConfigParam(exSheetkari, 10,
        [Stage('Inhale from mouth', 4), Stage('Exhale from nose', 4)]),
    ConfigParam(
        exSuryaBhedi, 10, [Stage('Inhale right', 4), Stage('Exhale left', 4)]),
    ConfigParam(exChandraBhedi, 10,
        [Stage('Inhale left', 4), Stage('Exhale right', 4)]),
    ConfigParam(exKapaalBhaati, 10,
        [Stage('Inhale gently', 4), Stage('Exhale with force', 4)]),
    ConfigParam(exBhastrika, 10,
        [Stage('Hands up and Inhale', 4), Stage('Hands down and Exhale', 4)]),
  ];

  List<ConfigParam> getExerciseLib() {
    return _exerciseLib;
  }

  ConfigParam? getExerciseFromLib(String name) {
    for (int i = 0; i < _exerciseLib.length; i++) {
      if (_exerciseLib[i].name == name) return _exerciseLib[i];
    }
    print('getExerciseFromLib: Exercise $name not found!!');

    return null;
  }

  // ----------------------------------------------------

  String getName() {
    return _name;
  }

  void setName(String name) {
    this._name = name;
    notifyListeners();
  }

  String getPhoto() {
    return _photo;
  }

  void setPhoto(String photo) {
    this._photo = photo;
    notifyListeners();
  }

  String getEmail() {
    return _email;
  }

  void setEmail(String email) {
    this._email = email;
    notifyListeners();
  }

  String getUid() {
    return _uid;
  }

  void setUid(String uid) {
    this._uid = uid;
    notifyListeners();
  }

  bool getVerified() {
    return _verified;
  }

  void setVerified(bool v) {
    this._verified = v;
    notifyListeners();
  }

  List<String> getVoices() {
    return _voices;
  }

  void setVoices(List<String> voices) {
    this._voices = voices;
  }

  String getVoice() {
    return _speechVoice;
  }

  void setVoice(String voice) {
    this._speechVoice = voice;
    notifyListeners();
  }

  // ----------------------------------------------------

  void settingsFromJson(Map<String, dynamic> jval) {
    this._name = jval['name'] ?? this._name;
    //this.email = jval['email'] ?? this.email;
    this._speechRate = jval['speechRate'] ?? this._speechRate;
    this._speechVoice = jval['speechVoice'] ?? this._speechVoice;
    this._countDuration = jval['countDuration'] ?? this._countDuration;
    this._dailyTarget = jval['dailyTarget'] ?? this._dailyTarget;
    this._gapRoutine = jval['gapRoutine'] ?? this._gapRoutine;
    this._muteCounting = jval['muteCounting'] ?? this._muteCounting;
    this.cps = (jval['cps'] ?? (this.cps.map((x) => x.toJson()).toList()))
        .map<ConfigParam>((x) => ConfigParam.fromJson(x))
        .toList();
    this.routines =
        (jval['routines'] ?? (this.routines.map((x) => x.toJson()).toList()))
            .map<Routine>((x) => Routine.fromJson(x))
            .toList();
    notifyListeners();
  }

  Map<String, dynamic> settingsToJson() {
    return {
      'name': this._name,
      'email': this._email,
      'speechRate': this._speechRate,
      'speechVoice': this._speechVoice,
      'countDuration': this._countDuration,
      'dailyTarget': this._dailyTarget,
      'gapRoutine': this._gapRoutine,
      'muteCounting': this._muteCounting,
      'cps': this.cps.map((x) => x.toJson()).toList(),
      'routines': this.routines.map((x) => x.toJson()).toList(),
    };
  }

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> jval = settingsToJson();
    String value = jsonEncode(jval);
    print('**** Saving settings');
    prefs.setString('settings', value);

    await DBService(uid: _uid).updateUserData(jval);
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String value = prefs.getString('settings') ?? '';
    print('**** Loading settings');
    if (value != '') {
      Map<String, dynamic> jval = jsonDecode(value);
      if (jval['email'] == this._email) settingsFromJson(jval);
    }
  }

  // ----------------------------------------------------

  void setDailyTarget(int dailyTarget) {
    this._dailyTarget = dailyTarget;
  }

  int getDailyTarget() {
    return this._dailyTarget;
  }

  // ----------------------------------------------------

  void setGapRoutine(int gap) {
    this._gapRoutine = gap;
  }

  int getGapRoutine() {
    return this._gapRoutine;
  }

  // ----------------------------------------------------

  void setMuteCounting(bool mute) {
    this._muteCounting = mute;
  }

  bool getMuteCounting() {
    return this._muteCounting;
  }

  // ----------------------------------------------------

  void setSpeechRate(double speechRate) {
    this._speechRate = speechRate;
  }

  double getSpeechRate() {
    return this._speechRate;
  }

  // ----------------------------------------------------

  void setCountDuration(int countDuration) {
    this._countDuration = countDuration;
  }

  int getCountDuration() {
    return this._countDuration;
  }

  // ----------------------------------------------------

  int lengthParams() {
    return cps.length;
  }

  void addParam(ConfigParam cp) {
    cps.add(cp);
    print('Added config $cp');
    print(cps);
    notifyListeners();
  }

  int findParamIndex(String cfg) {
    for (var pindex = 0; pindex < cps.length; pindex++) {
      if (cps[pindex].name == cfg) return pindex;
    }
    print('**** findParamIndex: $cfg not found');
    print(cps);
    return -1;
  }

  void removeParam(String cfg) {
    int index = findParamIndex(cfg);
    if (index >= 0) {
      cps.removeAt(index);
      notifyListeners();
    } else {
      print('removeParam $cfg: not found');
    }
  }

  ConfigParam getParam(int index) {
    return cps[index];
  }

  void setParam(int index, ConfigParam cp) {
    cps[index] = cp;
    notifyListeners();
  }
  // ----------------------------------------------------

  int lengthRoutines() {
    return routines.length;
  }

  void addRoutine(Routine cp) {
    routines.add(cp);
    print('addRoutine: Added routine $cp');
    print(routines);
    notifyListeners();
  }

  int findRoutineIndex(String cfg) {
    for (var pindex = 0; pindex < routines.length; pindex++) {
      if (routines[pindex].name == cfg) return pindex;
    }
    print('**** findRoutineIndex: $cfg not found');
    print(routines);
    return -1;
  }

  void removeRoutine(String cfg) {
    int index = findRoutineIndex(cfg);
    if (index >= 0) {
      routines.removeAt(index);
      notifyListeners();
    } else {
      print('removeRoutine $cfg: not found');
    }
  }

  Routine getRoutine(int index) {
    return routines[index];
  }

  void setRoutine(int index, Routine cp) {
    routines[index] = cp;
    notifyListeners();
  }

  List<String> routinesWhichInclude(String ex) {
    List<String> lr = [];

    for (int i = 0; i < routines.length; i++) {
      for (int j = 0; j < routines[i].exercises.length; j++) {
        if (routines[i].exercises[j].name == ex) {
          lr.add(routines[i].name);
          break;
        }
      }
    }

    return lr;
  }

  bool exerciseNotPresent(String ex) {
    for (int i = 0; i < cps.length; i++) {
      if (cps[i].name == ex) return false;
    }
    return true;
  }

  List<String> exercisesNotPresent(Routine r) {
    List<String> np = [];

    for (int i = 0; i < r.exercises.length; i++) {
      if (exerciseNotPresent(r.exercises[i].name)) np.add(r.exercises[i].name);
    }
    return np;
  }
}
