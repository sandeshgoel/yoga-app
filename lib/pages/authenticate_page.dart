import 'package:flutter/material.dart';
import 'package:yoga/auth.dart';

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({Key? key}) : super(key: key);

  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In to Yoga Assist'),
        actions: [
          IconButton(
            onPressed: () => {},
            icon: Icon(Icons.app_registration),
            tooltip: 'Register',
          )
        ],
      ),
      body: _signInPage(),
    );
  }

  Widget _signInPage() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: ElevatedButton(
          onPressed: () async {
            dynamic res = await _auth.signInAnon();
            if (res == null) {
              print("error signing in");
            } else {
              print(res);
            }
          },
          child: Text('Sign In Anonymously'),
        ),
      ),
    );
  }
}
