import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  final String uid;

  DBService({required this.uid});

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

  Future<QuerySnapshot> getUserActivity() async {
    print('Reading from DB activity ...');
    return await actCollection
        .where('uid', isEqualTo: uid)
        .orderBy('start', descending: true)
        .get();
  }
}
