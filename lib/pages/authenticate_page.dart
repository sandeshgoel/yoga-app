import 'package:flutter/material.dart';
import 'package:yoga/services/auth.dart';
import 'package:yoga/shared/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({Key? key}) : super(key: key);

  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String email = 'sandesh@gmail.com';
  String password = 'sandesh';

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text('Sign In to Yoga Assist'),
            ),
            body: _signInPage(),
          );
  }

  Widget _signInPage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              initialValue: email,
              validator: (val) =>
                  (val!.contains('@') & val.contains('.') & (val.length > 5))
                      ? null
                      : 'Enter a valid email',
              onChanged: (val) {
                email = val;
              },
              decoration: textInputDeco.copyWith(hintText: 'Email'),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              initialValue: password,
              obscureText: true,
              validator: (val) =>
                  val!.length < 6 ? 'Password length must be at least 6' : null,
              onChanged: (val) {
                password = val;
              },
              decoration: textInputDeco.copyWith(hintText: 'Password'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _loading = true;
                  });

                  print('$email, $password');
                  List res = await _auth.checkEmail(email);
                  if (res.length == 0) {
                    print('User not registered');
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              content: Text(
                                  '$email is not registered, do you want to register now?'),
                              title: Text('Register?'),
                              actions: [
                                ElevatedButton(
                                    onPressed: () async {
                                      dynamic res =
                                          await _auth.register(email, password);
                                      if (res == null) {
                                        print("error registering");
                                      } else {
                                        print(res);
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: Text('Yes')),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('No'))
                              ],
                            ),
                        barrierDismissible: false);
                  } else {
                    dynamic res = await _auth.signIn(email, password);
                    if (res == null) {
                      print("error signing in");
                    } else {
                      print(res);
                    }
                  }

                  setState(() {
                    _loading = false;
                  });
                }
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SpinKitChasingDots(
          color: Colors.blue,
        ),
      ),
    );
  }
}
