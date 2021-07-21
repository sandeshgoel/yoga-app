import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class Settings with ChangeNotifier {
  Random r = new Random();

  double speechRate = 0.3;
  int countDuration = 1800;

  List<ConfigParam> cps = [
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

  // ----------------------------------------------------

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String value = jsonEncode({
      'speechRate': this.speechRate,
      'countDuration': this.countDuration,
      'cps': this.cps.map((x) => x.toJson()).toList()
    });
    print('**** Saving settings: $value');
    prefs.setString('settings', value);
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String value = prefs.getString('settings') ?? '';
    print('**** Loading settings: $value');
    if (value != '') {
      Map<String, dynamic> jval = jsonDecode(value);
      this.speechRate = jval['speechRate'];
      this.countDuration = jval['countDuration'];
      this.cps =
          jval['cps'].map<ConfigParam>((x) => ConfigParam.fromJson(x)).toList();
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
