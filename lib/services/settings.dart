import 'dart:convert';
import 'dart:math';
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

// ------------------------------------------------------

class Settings with ChangeNotifier {
  Random r = new Random();

  late String uid;
  late String email;
  late String _name;

  late double speechRate;
  late int countDuration;

  late List<ConfigParam> cps;

  Settings() {
    initSettings();
  }

  void initSettings() {
    _name = '';
    email = '';
    uid = '';
    speechRate = 0.3;
    countDuration = 1800;
    cps = [
      ConfigParam('Anulom Vilom', 10, [
        Stage('Inhale Left', 4),
        Stage('Exhale Right', 4),
        Stage('Inhale Right', 4),
        Stage('Exhale Left', 4),
      ]),
      ConfigParam('Deep Breathing', 20, [
        Stage('Inhale', 4),
        Stage('Exhale', 4),
      ])
    ];
  }

  // ----------------------------------------------------

  String getName() {
    return _name;
  }

  void setName(String name) {
    this._name = name;
    notifyListeners();
  }

  void setEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  // ----------------------------------------------------

  void settingsFromJson(Map<String, dynamic> jval) {
    this._name = jval['name'] ?? this._name;
    //this.email = jval['email'] ?? this.email;
    this.speechRate = jval['speechRate'] ?? this.speechRate;
    this.countDuration = jval['countDuration'] ?? this.countDuration;
    this.cps = (jval['cps'] ?? (this.cps.map((x) => x.toJson()).toList()))
        .map<ConfigParam>((x) => ConfigParam.fromJson(x))
        .toList();
    notifyListeners();
  }

  Map<String, dynamic> settingsToJson() {
    return {
      'name': this._name,
      'email': this.email,
      'speechRate': this.speechRate,
      'countDuration': this.countDuration,
      'cps': this.cps.map((x) => x.toJson()).toList()
    };
  }

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> jval = settingsToJson();
    String value = jsonEncode(jval);
    print('**** Saving settings');
    prefs.setString('settings', value);

    await DBService(uid: uid).updateUserData(jval);
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String value = prefs.getString('settings') ?? '';
    print('**** Loading settings');
    if (value != '') {
      Map<String, dynamic> jval = jsonDecode(value);
      if (jval['email'] == this.email) settingsFromJson(jval);
    }
  }

  // ----------------------------------------------------

  void setSpeechRate(double speechRate) {
    this.speechRate = speechRate;
  }

  // ----------------------------------------------------

  void setCountDuration(int countDuration) {
    this.countDuration = countDuration;
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
}
