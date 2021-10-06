import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import 'package:yoga/services/database.dart';

enum ExCategory { breathing, standing, sitting }

// breathing exercises
const exAnulomVilom = 'Anulom Vilom';
const exDeepBreathing = 'Deep Breathing';
const exBhramari = 'Bhramari';
const exSheetkari = 'Sheetkari';
const exSuryaBhedi = 'Surya Bhedi';
const exChandraBhedi = 'Chandra Bhedi';
const exKapaalBhaati = 'Kapaal Bhaati';
const exBhastrika = 'Bhastrika';
const exShavasana = 'Shava Aasanaa';

// standing exercises
const exSuryaNamaskara = 'Surya Namaskara';
const exSuryaNamaskaraFast = 'Surya Namaskara Fast';
const exHandRotation = 'Arm Rotation';

// sitting exercises
const exNeckUpDown = 'Neck Up-Down';
const exNeckRightLeft = 'Neck Right-Left';
const exButterfly = 'Butterfly';
const exSquat = 'Squat';
const exPawanMukt = 'Pawan Mukt Aasanaa';
const exMarkatasana = 'Markata Aasanaa';
const exChakrasana = 'Chakra Aasanaa';

// Routine library
List<Routine> gRoutineLib = [
  Routine('5 Minute Sampler', [
    Exercise(exAnulomVilom, 4),
    Exercise(exSheetkari, 4),
  ]),
  Routine('10 Minute Breathing', [
    Exercise(exDeepBreathing, 6),
    Exercise(exBhramari, 6),
    Exercise(exAnulomVilom, 5),
    Exercise(exSheetkari, 6),
    Exercise(exShavasana, 1),
  ]),
  Routine('Breathing Routine', [
    Exercise(exDeepBreathing, 15),
    Exercise(exBhramari, 15),
    Exercise(exAnulomVilom, 10),
    Exercise(exSheetkari, 15),
    Exercise(exShavasana, 1),
  ]),
  Routine('Standing Warm Up', [
    Exercise(exHandRotation, 10),
    Exercise(exNeckUpDown, 10),
    Exercise(exNeckRightLeft, 10),
    Exercise(exSuryaNamaskara, 10),
  ]),
  Routine('Sitting Warm Up', [
    Exercise(exSquat, 10),
    Exercise(exButterfly, 10),
    Exercise(exPawanMukt, 4),
    Exercise(exMarkatasana, 6),
  ]),
];

// Exercise Library
List<ConfigParam> gExerciseLib = [
  // breathing

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
      sameCount: true,
      desc:
          'Inhale and exhale from alternating nostrils, this balances our breathing'),
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
      [Stage('Inhale gently', 4), Stage('Exhale with force', 2)]),
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
      Stage('Rub your palms and cup your eyes', 8),
      Stage('Open your eyes with a smile', 4)
    ],
  ),

  // standing

  ConfigParam(
      exSuryaNamaskara,
      ExCategory.standing,
      6,
      [
        Stage('Fold both hands', 3),
        Stage('Hands above your head', 3),
        Stage('Touch your feet', 3),
        Stage('Right leg back', 3),
        Stage('Mountain pose', 3),
        Stage('Prone position', 3),
        Stage('Cobra pose', 3),
        Stage('Mountain pose', 3),
        Stage('Left leg forward', 3),
        Stage('Touch your feet', 3),
        Stage('Hands above your head', 3),
        Stage('Fold your hands', 3),
        Stage('Hands down', 3)
      ],
      sameCount: true,
      altLeftRight: true),
  ConfigParam(
      exSuryaNamaskaraFast,
      ExCategory.standing,
      6,
      [
        Stage('Fold both hands', 2),
        Stage('Hands above your head', 2),
        Stage('Touch your feet', 2),
        Stage('Right leg back', 2),
        Stage('Mountain pose', 2),
        Stage('Prone position', 2),
        Stage('Cobra pose', 2),
        Stage('Mountain pose', 2),
        Stage('Left leg forward', 2),
        Stage('Touch your feet', 2),
        Stage('Hands above your head', 2),
      ],
      sameCount: true,
      altLeftRight: true),
  ConfigParam(exHandRotation, ExCategory.standing, 10, [Stage('Rotate', 2)]),
  ConfigParam(exNeckUpDown, ExCategory.standing, 10,
      [Stage('Neck up', 2), Stage('Neck down', 2)]),
  ConfigParam(exNeckRightLeft, ExCategory.standing, 10,
      [Stage('Neck right', 2), Stage('Neck left', 2)]),

  // sitting

  ConfigParam(
      exButterfly, ExCategory.sitting, 10, [Stage('Flap the knees', 4)]),
  ConfigParam(exSquat, ExCategory.sitting, 4, [Stage('Squat', 10)]),
  ConfigParam(exPawanMukt, ExCategory.sitting, 4,
      [Stage('Lie down and hug your knees', 10)]),
  ConfigParam(exMarkatasana, ExCategory.sitting, 10,
      [Stage('Bend knees to the right and turn head to the left', 10)],
      altLeftRight: true,
      desc: 'Lie down on your back, hands to the side and bend your knees'),
  ConfigParam(exChakrasana, ExCategory.sitting, 2,
      [Stage('Lift your stomach in chakra aasanaa', 20), Stage('Release', 2)]),
];

// ------------------------------------------------------

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

  bool equals(Stage s) {
    if ((this.name == s.name) & (this.count == s.count))
      return true;
    else
      return false;
  }
}

// ------------------------------------------------------

class ConfigParam {
  late String name;
  late ExCategory category;
  late int rounds;
  bool altLeftRight = false;
  late List<Stage> stages;
  bool sameCount = false;
  late String desc;

  ConfigParam(this.name, this.category, this.rounds, this.stages,
      {this.altLeftRight = false, this.sameCount = false, this.desc = ''});

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
      'desc': this.desc,
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
    this.desc = json['desc'] ?? '';
    this.stages = json['stages'].map<Stage>((x) => Stage.fromJson(x)).toList();
  }

  static ExCategory strToCategory(String c) {
    ExCategory res = ExCategory.values.firstWhere((e) => describeEnum(e) == c,
        orElse: () => ExCategory.breathing);

    return res;
  }

  bool stagesEquals(List<Stage> stages) {
    if (this.stages.length != stages.length) return false;
    for (int i = 0; i < stages.length; i++) {
      if (!this.stages[i].equals(stages[i])) return false;
    }
    return true;
  }

  bool equals(ConfigParam ex) {
    if ((this.category == ex.category) &
        (this.altLeftRight == ex.altLeftRight) &
        (this.sameCount == ex.sameCount) &
        (this.desc == ex.desc) &
        this.stagesEquals(ex.stages))
      return true;
    else
      return false;
  }

  bool equalsAll(ConfigParam ex) {
    if (this.equals(ex) & (this.rounds == ex.rounds))
      return true;
    else
      return false;
  }
}

// ------------------------------------------------------

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

  bool equals(Exercise ex) {
    if ((this.name == ex.name) & (this.rounds == ex.rounds))
      return true;
    else
      return false;
  }
}

// ------------------------------------------------------

class Routine {
  late String name;
  late List<Exercise> exercises;
  bool shared = false;
  bool noGap = false;

  Routine(this.name, this.exercises);

  @override
  String toString() {
    return '{$name, $shared, $noGap: $exercises}\n';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'exercises': this.exercises.map((x) => x.toJson()).toList(),
      'shared': this.shared,
      'nogap': this.noGap,
    };
  }

  Routine.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.exercises =
        json['exercises'].map<Exercise>((x) => Exercise.fromJson(x)).toList();
    this.shared = json['shared'] ?? false;
    this.noGap = json['nogap'] ?? false;
  }

  bool equals(Routine r) {
    if (this.shared != r.shared) return false;
    if (this.noGap != r.noGap) return false;
    if (this.exercises.length != r.exercises.length) return false;
    for (int i = 0; i < r.exercises.length; i++) {
      if (!this.exercises[i].equals(r.exercises[i])) return false;
    }
    return true;
  }
}

// ------------------------------------------------------

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

  bool equals(UserInfo user) {
    if ((this.name == user.name) &
        (this.email == user.email) &
        (this.uid == user.uid) &
        (this.photo == user.photo) &
        (this.verified == user.verified))
      return true;
    else
      return false;
  }
}

// ------------------------------------------------------

class YogaSettings with ChangeNotifier {
  late UserInfo _user;

  late List<String> _voices;
  late String _speechVoice;
  late double _speechRate;
  late double _speechVolume;
  late int _countDuration;
  late int _dailyTarget;
  late int _gapRoutine;
  late bool _muteCounting;
  late bool _notify;

  late List<ConfigParam> cps;
  late List<Routine> routines;

  late Set<String> friends;
  late Set<String> friendsPending;
  late Set<String> friendsReceived;

  YogaSettings() {
    initSettings();
  }

  // defaults
  double defSpeechRate = 0.3;
  double defSpeechVolume = 0.5;
  int defCountDuration = 1800;
  int defGapRoutine = 10;
  bool defMuteCounting = true;
  bool defNotify = true;

  void initSettings() {
    _user = UserInfo();
    _user.initUser();

    _voices = [];
    _speechVoice = '';
    _dailyTarget = 10;

    _speechRate = defSpeechRate;
    _speechVolume = defSpeechVolume;
    _countDuration = defCountDuration;
    _gapRoutine = defGapRoutine;
    _muteCounting = defMuteCounting;
    _notify = defNotify;

    cps = [];
    routines = [_routineLib[0]];

    friends = Set();
    friendsPending = Set();
    friendsReceived = Set();
  }

  bool allDefaults() {
    if ((_speechRate == defSpeechRate) &
        (_speechVolume == defSpeechVolume) &
        (_countDuration == defCountDuration) &
        (_gapRoutine == defGapRoutine) &
        (_muteCounting == defMuteCounting) &
        (_notify = defNotify))
      return true;
    else
      return false;
  }

  // ----------------------------------------------------

  List<Routine> _routineLib = gRoutineLib;

  List<Routine> getRoutineLib() {
    return _routineLib;
  }

  List<Routine> getRoutineLibNotAdded() {
    return _routineLib.where((e) => findRoutineIndex(e.name) == -1).toList();
  }

  Routine? getRoutineFromLib(String name) {
    for (int i = 0; i < _routineLib.length; i++) {
      if (_routineLib[i].name == name) return _routineLib[i];
    }
    print('getRoutineFromLib: Routine $name not found!!');
    return null;
  }

  bool routineDiffInLibOld(String name) {
    Routine? rl = getRoutineFromLib(name);

    if (rl == null)
      return true;
    else {
      Routine r = routines.firstWhere((element) => element.name == name);
      return (!DeepCollectionEquality.unordered()
          .equals(r.toJson(), rl.toJson()));
    }
  }

  bool routineDiffInLib(String name) {
    Routine? rl = getRoutineFromLib(name);

    if (rl == null)
      return true;
    else {
      Routine r = routines.firstWhere((element) => element.name == name);
      return !r.equals(rl);
    }
  }

  // ----------------------------------------------------

  List<ConfigParam> _exerciseLib = gExerciseLib;

  List<ConfigParam> getExerciseLib() {
    return _exerciseLib;
  }

  List<ConfigParam> getExerciseLibNotAdded() {
    return _exerciseLib.where((e) => findParamIndex(e.name) == -1).toList();
  }

  ConfigParam? getExerciseFromLib(String name) {
    for (int i = 0; i < _exerciseLib.length; i++) {
      if (_exerciseLib[i].name == name) return _exerciseLib[i];
    }
    print('getExerciseFromLib: Exercise $name not found!!');

    return null;
  }

  bool exerciseDiffInLibOld(String name) {
    ConfigParam? exl = getExerciseFromLib(name);

    if (exl == null)
      return true;
    else {
      ConfigParam ex = getParam(findParamIndex(name));
      var exJson = ex.toJson();
      var exlJson = exl.toJson();
      exJson.remove('rounds');
      exlJson.remove('rounds');
      return (!DeepCollectionEquality.unordered().equals(exJson, exlJson));
    }
  }

  bool exerciseDiffInLib(String name) {
    ConfigParam? exl = getExerciseFromLib(name);

    if (exl == null)
      return true;
    else {
      ConfigParam ex = getParam(findParamIndex(name));
      return !ex.equals(exl);
    }
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
    this._speechVolume = jval['speechVolume'] ?? this._speechVolume;
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
    this.friends = (jval['friends'] ?? this.friends)
        .map<String>((x) => x as String)
        .toSet();
    this.friendsPending = (jval['friendsPending'] ?? this.friendsPending)
        .map<String>((x) => x as String)
        .toSet();
    this.friendsReceived = (jval['friendsReceived'] ?? this.friendsReceived)
        .map<String>((x) => x as String)
        .toSet();

    notifyListeners();
  }

  Map<String, dynamic> settingsToJson() {
    return {
      'user': (this._user).toJson(),
      'speechRate': this._speechRate,
      'speechVolume': this._speechVolume,
      'speechVoice': this._speechVoice,
      'countDuration': this._countDuration,
      'dailyTarget': this._dailyTarget,
      'gapRoutine': this._gapRoutine,
      'muteCounting': this._muteCounting,
      'notify': this._notify,
      'cps': this.cps.map((x) => x.toJson()).toList(),
      'routines': this.routines.map((x) => x.toJson()).toList(),
      'friends': this.friends.toList(),
      'friendsPending': this.friendsPending.toList(),
      'friendsReceived': this.friendsReceived.toList(),
    };
  }

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> jval = settingsToJson();
    String value = jsonEncode(jval);
    print('**** Saving settings');
    prefs.setString('settings', value);

    await DBService(uid: _user.uid, email: _user.email).updateUserData(this);
    await DBService(uid: _user.uid, email: _user.email).updateShared(this);
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

  bool cpsEquals(List<ConfigParam> cps) {
    if (this.cps.length != cps.length) return false;
    for (int i = 0; i < cps.length; i++) {
      if (!this.cps[i].equalsAll(cps[i])) return false;
    }
    return true;
  }

  bool routinesEquals(List<Routine> routines) {
    if (this.routines.length != routines.length) return false;
    for (int i = 0; i < routines.length; i++) {
      if (!this.routines[i].equals(routines[i])) return false;
    }
    return true;
  }

  bool equals(YogaSettings cfg) {
    if (this._user.equals(cfg._user) &
        (this._speechRate == cfg._speechRate) &
        (this._speechVolume == cfg._speechVolume) &
        (this._speechVoice == cfg._speechVoice) &
        (this._countDuration == cfg._countDuration) &
        (this._dailyTarget == cfg._dailyTarget) &
        (this._gapRoutine == cfg._gapRoutine) &
        (this._muteCounting == cfg._muteCounting) &
        (this._notify == cfg._notify) &
        this.cpsEquals(cfg.cps) &
        this.routinesEquals(cfg.routines) &
        DeepCollectionEquality.unordered().equals(this.friends, cfg.friends) &
        DeepCollectionEquality.unordered()
            .equals(this.friendsPending, cfg.friendsPending) &
        DeepCollectionEquality.unordered()
            .equals(this.friendsReceived, cfg.friendsReceived))
      return true;
    else
      return false;
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

  void setSpeechVolume(double speechVolume) {
    this._speechVolume = speechVolume;
  }

  double getSpeechVolume() {
    return this._speechVolume;
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

  List<String> removeRoutine(String cfg) {
    int index = findRoutineIndex(cfg);
    List<String> delEx = [];

    if (index >= 0) {
      for (int i = 0; i < routines[index].exercises.length; i++) {
        Exercise e = routines[index].exercises[i];
        if (routinesWhichInclude(e.name).length <= 1) delEx.add(e.name);
      }

      routines.removeAt(index);
      notifyListeners();
    } else {
      print('removeRoutine $cfg: not found');
    }
    return delEx;
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

  void addExercisesNotPresent() {
    for (int i = 0; i < routines.length; i++) {
      List<String> np = exercisesNotPresent(routines[i]);
      for (int j = 0; j < np.length; j++) {
        ConfigParam? ex = getExerciseFromLib(np[j]);
        if (ex != null)
          addParam(ex);
        else
          print('Exercise ${np[j]} not found!!');
      }
    }
  }

  // ----------------------------------------------------

  Set<String> getFriends() {
    return friends;
  }

  Set<String> getFriendsPending() {
    return friendsPending;
  }

  Set<String> getFriendsReceived() {
    return friendsReceived;
  }

  bool friendsContains(String email) {
    return friends.contains(email);
  }

  bool friendsPendingContains(String email) {
    return friendsPending.contains(email);
  }

  bool friendsReceivedContains(String email) {
    return friendsReceived.contains(email);
  }

  void addFriends(String email) {
    if (!friendsContains(email)) friends.add(email);
    friendsPending.remove(email);
    friendsReceived.remove(email);
    saveSettings();
  }

  void addFriendsPending(String email) {
    if (!friendsPendingContains(email)) friendsPending.add(email);
    saveSettings();
  }

  void addFriendsReceived(String email) {
    if (!friendsReceivedContains(email)) friendsReceived.add(email);
    saveSettings();
  }

  void alignFriends() {
    Set<String> inter = friendsPending.intersection(friendsReceived);

    for (String s in inter) {
      addFriends(s);
      friendsPending.remove(s);
      friendsReceived.remove(s);
    }
  }

  void delFriendsAll(String email) {
    friendsPending.remove(email);
    friendsReceived.remove(email);
    friends.remove(email);

    saveSettings();
  }
  // ----------------------------------------------------
}
