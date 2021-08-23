import 'dart:convert';
import 'package:flutter/foundation.dart';
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

enum ExCategory { breathing, standing, sitting }

class ConfigParam {
  late String name;
  late ExCategory category;
  late int rounds;
  bool altLeftRight = false;
  late List<Stage> stages;
  bool sameCount = false;

  ConfigParam(this.name, this.category, this.rounds, this.stages,
      {this.altLeftRight = false, this.sameCount = false});

  @override
  String toString() {
    return '{$name, $category, $rounds, $altLeftRight, $sameCount : $stages}\n';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'category': describeEnum(this.category),
      'rounds': this.rounds,
      'altLeftRight': this.altLeftRight,
      'sameCount': this.sameCount,
      'stages': this.stages.map((x) => x.toJson()).toList()
    };
  }

  ConfigParam.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.category =
        strToCategory(json['category'] ?? describeEnum(ExCategory.breathing));
    this.rounds = json['rounds'];
    this.altLeftRight = json['altLeftRight'];
    this.sameCount = json['sameCount'] ?? false;
    this.stages = json['stages'].map<Stage>((x) => Stage.fromJson(x)).toList();
  }

  static ExCategory strToCategory(String c) {
    ExCategory res = ExCategory.values.firstWhere((e) => describeEnum(e) == c,
        orElse: () => ExCategory.breathing);

    return res;
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
const exShavasana = 'Shava Aasanaa';
const exSuryaNamaskara = 'Surya Namaskara';
const exHandRotation = 'Arm Rotation';
const exNeckUpDown = 'Neck Up-Down';
const exNeckRightLeft = 'Neck Right-Left';

class UserInfo {
  late String uid;
  late String email;
  late String name;
  late String photo;
  late bool verified;

  UserInfo() {
    initUser();
  }

  void initUser() {
    name = '';
    email = '';
    uid = '';
    photo = '';
    verified = false;
  }

  @override
  String toString() {
    return '{$name, $email, $verified, $uid, $photo}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'email': this.email,
      'uid': this.uid,
      'photo': this.photo,
      'verified': this.verified,
    };
  }

  UserInfo.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.email = json['email'];
    this.uid = json['uid'];
    this.photo = json['photo'];
    this.verified = json['verified'];
  }
}

// ------------------------------------------------------

class YogaSettings with ChangeNotifier {
  late UserInfo _user;

  late List<String> _voices;
  late String _speechVoice;
  late double _speechRate;
  late int _countDuration;
  late int _dailyTarget;
  late int _gapRoutine;
  late bool _muteCounting;
  late bool _notify;

  late List<ConfigParam> cps;
  late List<Routine> routines;

  YogaSettings() {
    initSettings();
  }

  void initSettings() {
    _user = UserInfo();
    _user.initUser();

    _voices = [];
    _speechVoice = '';
    _speechRate = 0.3;
    _countDuration = 1800;
    _dailyTarget = 10;
    _gapRoutine = 5;
    _muteCounting = false;
    _notify = true;

    cps = [_exerciseLib[0]];
    routines = [];
  }

  // ----------------------------------------------------

  List<Routine> _routineLib = [
    Routine('Breathing Routine', [
      Exercise(exDeepBreathing, 10),
      Exercise(exBhramari, 10),
      Exercise(exAnulomVilom, 10),
      Exercise(exSheetkari, 10),
      Exercise(exShavasana, 1)
    ]),
    Routine('Warm Up', [
      Exercise(exHandRotation, 10),
      Exercise(exNeckUpDown, 10),
      Exercise(exNeckRightLeft, 10),
      Exercise(exSuryaNamaskara, 4),
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
    ConfigParam(
        exAnulomVilom,
        ExCategory.breathing,
        10,
        [
          Stage('Inhale Left', 4),
          Stage('Exhale Right', 4),
          Stage('Inhale Right', 4),
          Stage('Exhale Left', 4),
        ],
        sameCount: true),
    ConfigParam(exDeepBreathing, ExCategory.breathing, 20,
        [Stage('Inhale', 4), Stage('Exhale', 4)]),
    ConfigParam(exBhramari, ExCategory.breathing, 10,
        [Stage('Inhale', 3), Stage('Exhale with humming sound', 6)]),
    ConfigParam(exSheetkari, ExCategory.breathing, 10,
        [Stage('Inhale from mouth', 4), Stage('Exhale from nose', 4)]),
    ConfigParam(exSuryaBhedi, ExCategory.breathing, 10,
        [Stage('Inhale right', 4), Stage('Exhale left', 4)]),
    ConfigParam(exChandraBhedi, ExCategory.breathing, 10,
        [Stage('Inhale left', 4), Stage('Exhale right', 4)]),
    ConfigParam(exKapaalBhaati, ExCategory.breathing, 10,
        [Stage('Inhale gently', 4), Stage('Exhale with force', 4)]),
    ConfigParam(exBhastrika, ExCategory.breathing, 10,
        [Stage('Hands up and Inhale', 4), Stage('Hands down and Exhale', 4)]),
    ConfigParam(
      exShavasana,
      ExCategory.sitting,
      1,
      [
        Stage('Lie down still with eyes closed and relax', 60),
        Stage('Stretch all your muscles', 10),
        Stage('Sit back up', 10),
        Stage('Chant om shanti shanti', 10),
        Stage('Rub your palms and cup your eyes', 10),
        Stage('Open your eyes with a smile', 6)
      ],
    ),
    ConfigParam(
        exSuryaNamaskara,
        ExCategory.standing,
        4,
        [
          Stage('Fold both hands', 4),
          Stage('Hands above your head', 4),
          Stage('Touch your feet', 4),
          Stage('Right leg back', 4),
          Stage('Mountain pose', 4),
          Stage('Prone position', 4),
          Stage('Cobra pose', 4),
          Stage('Mountain pose', 4),
          Stage('Left leg forward', 4),
          Stage('Touch your feet', 4),
          Stage('Hands above your head', 4),
          Stage('Fold your hands', 4),
          Stage('Hands down', 4)
        ],
        sameCount: true,
        altLeftRight: true),
    ConfigParam(exHandRotation, ExCategory.standing, 10, [Stage('Rotate', 2)]),
    ConfigParam(exNeckUpDown, ExCategory.sitting, 10,
        [Stage('Neck down', 2), Stage('Neck up', 2)]),
    ConfigParam(exNeckRightLeft, ExCategory.sitting, 10,
        [Stage('Neck right', 2), Stage('Neck left', 2)]),
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

  void setUser(
      String name, String email, String uid, String photo, bool verified) {
    this._user.name = name;
    this._user.email = email;
    this._user.uid = uid;
    this._user.photo = photo;
    this._user.verified = verified;
    notifyListeners();
  }

  UserInfo getUser() {
    return _user;
  }

  void setUserName(String name) {
    this._user.name = name;
    notifyListeners();
  }

  void setUserVerified(bool v) {
    this._user.verified = v;
    notifyListeners();
  }

  // ----------------------------------------------------

  List<String> getVoices() {
    return _voices;
  }

  void setVoices(List<String> voices) {
    this._voices = voices;
    if (!_voices.contains(_speechVoice)) _speechVoice = _voices[0];
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
    this._user = UserInfo.fromJson(jval['user'] ?? (this._user).toJson());
    this._speechRate = jval['speechRate'] ?? this._speechRate;
    this._speechVoice = jval['speechVoice'] ?? this._speechVoice;
    this._countDuration = jval['countDuration'] ?? this._countDuration;
    this._dailyTarget = jval['dailyTarget'] ?? this._dailyTarget;
    this._gapRoutine = jval['gapRoutine'] ?? this._gapRoutine;
    this._muteCounting = jval['muteCounting'] ?? this._muteCounting;
    this._notify = jval['notify'] ?? this._notify;
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
      'user': (this._user).toJson(),
      'speechRate': this._speechRate,
      'speechVoice': this._speechVoice,
      'countDuration': this._countDuration,
      'dailyTarget': this._dailyTarget,
      'gapRoutine': this._gapRoutine,
      'muteCounting': this._muteCounting,
      'notify': this._notify,
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

    await DBService(uid: _user.uid).updateUserData(jval);
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String value = prefs.getString('settings') ?? '';
    print('**** Loading settings');
    if (value != '') {
      Map<String, dynamic> jval = jsonDecode(value);
      if (jval['email'] == this._user.email) settingsFromJson(jval);
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

  void setNotify(bool notify) {
    this._notify = notify;
  }

  bool getNotify() {
    return this._notify;
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
