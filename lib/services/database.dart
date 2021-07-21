import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  final CollectionReference cfgCollection =
      FirebaseFirestore.instance.collection('configs');
}
