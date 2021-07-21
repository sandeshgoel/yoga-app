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
      return res.user;
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

  Future register(String email, String password) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return res.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signIn(String email, String password) async {
    try {
      UserCredential res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return res.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future checkEmail(String email) async {
    List<String> res = await _auth.fetchSignInMethodsForEmail(email);
    return res;
  }
}
