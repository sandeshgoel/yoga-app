import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

// auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future signInAnon() async {
    try {
      UserCredential res = await _auth.signInAnonymously();
      dynamic user = res.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
