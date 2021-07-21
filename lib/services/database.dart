import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  final String uid;

  DBService({required this.uid});

  final CollectionReference cfgCollection =
      FirebaseFirestore.instance.collection('configs');

  Future updateUserData(cfg) async {
    return await cfgCollection.doc(uid).set(cfg);
  }

  Future getUserData() async {
    return await cfgCollection.doc(uid).get();
  }
}
