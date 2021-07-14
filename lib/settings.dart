import 'package:flutter/material.dart';

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

  @override
  String toString() {
    return 'ConfigParam: {name: $name, rounds: $rounds, stages: $stages}\n';
  }
}

class Settings with ChangeNotifier {
  final List<ConfigParam> cps = [
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
    print('$cfg not found');
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
