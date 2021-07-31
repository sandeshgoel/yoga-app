import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  final String uid;

  DBService({required this.uid});

// -------------------------------------------------

  final CollectionReference cfgCollection =
      FirebaseFirestore.instance.collection('configs');

  Future updateUserData(cfg) async {
    print('Writing to DB configs ...');
    return await cfgCollection.doc(uid).set(cfg);
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

// -------------------------------------------------
}
