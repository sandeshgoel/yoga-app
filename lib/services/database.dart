import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yoga/services/settings.dart';

class DBService {
  final String uid;
  final String email;
  static Map<String, dynamic> _lastCfg = {};

  DBService({required this.uid, required this.email});

// -------------------------------------------------

  final CollectionReference cfgCollection =
      FirebaseFirestore.instance.collection('configs');

  Future updateUserData(YogaSettings cfg) async {
    YogaSettings lastCfg = YogaSettings();
    lastCfg.settingsFromJson(_lastCfg);

    if (cfg.equals(lastCfg)) {
      print('updateUserData: config unchanged, skipping write to DB');
    } else {
      print('updateUserData: config changed, writing to DB ...');
      Map<String, dynamic> jval = cfg.settingsToJson();
      _lastCfg = jsonDecode(jsonEncode(jval)); // make a copy
      await cfgCollection.doc(uid).set(jval);
    }
  }

  Future getUserData() async {
    print('Reading from DB configs ...');
    return await cfgCollection.doc(uid).get();
  }

// -------------------------------------------------

  final CollectionReference actCollection =
      FirebaseFirestore.instance.collection('activity');

  Future addUserActivity(Map<String, dynamic> act) async {
    print('Writing to DB activity ...');
    return await actCollection.add(act);
  }

  Future<QuerySnapshot> getUserActivityAll() async {
    print('Reading from DB activity ...');
    return await actCollection
        .where('uid', isEqualTo: uid)
        .orderBy('start', descending: true)
        .get();
  }

  Future<QuerySnapshot> getUserActivityToday() async {
    var now = DateTime.now();
    var lastMidnight = DateTime(now.year, now.month, now.day);
    print('Reading from DB activity ...');
    return await actCollection
        .where('uid', isEqualTo: uid)
        .where('start', isGreaterThanOrEqualTo: lastMidnight)
        .orderBy('start', descending: true)
        .get();
  }

  Future<QuerySnapshot> getUserActivityWeek() async {
    var now = DateTime.now();
    var lastMidnight = DateTime(now.year, now.month, now.day);
    var lastWeekMidnight = lastMidnight.subtract(Duration(days: 7));
    print('Reading from DB activity ...');
    return await actCollection
        .where('uid', isEqualTo: uid)
        .where('start', isGreaterThanOrEqualTo: lastWeekMidnight)
        .orderBy('start', descending: true)
        .get();
  }

  Future<QuerySnapshot> getUserActivityDays(int days) async {
    var now = DateTime.now();
    var lastMidnight = DateTime(now.year, now.month, now.day);
    var startDateMidnight = lastMidnight.subtract(Duration(days: days));
    print('Reading from DB activity ...');
    return await actCollection
        .where('email', isEqualTo: email)
        .where('start', isGreaterThanOrEqualTo: startDateMidnight)
        .orderBy('start', descending: true)
        .get();
  }

// -------------------------------------------------
}
