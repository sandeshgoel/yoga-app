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
  bool _checkboxValue = false;

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
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/background.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                _signInPage()
              ],
            ),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              child: Text(_checkboxValue ? 'Register' : 'Sign In'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _loading = true;
                  });

                  print('Checking $email, $password in firebase ...');
                  List userAuthList = await _auth.checkEmail(email);
                  if (userAuthList.length == 0) {
                    print('User not registered');
                    if (!_checkboxValue)
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                content: Text('$email is not registered,' +
                                    ' do you want to register now?'),
                                title: Text('Register?'),
                                actions: [
                                  ElevatedButton(
                                    child: Text('Yes'),
                                    onPressed: () async {
                                      dynamic regResult =
                                          await _auth.register(email, password);
                                      if (regResult == null)
                                        print("error registering");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text('No'),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              ),
                          barrierDismissible: false);
                    else {
                      dynamic regResult = await _auth.register(email, password);
                      if (regResult == null) print("error registering");
                    }
                  } else {
                    dynamic signResult = await _auth.signIn(email, password);
                    if (signResult == null) print("error signing in");
                  }
                  if (mounted) {
                    setState(() {
                      _loading = false;
                    });
                  } else {
                    _loading = false;
                  }
                }
              },
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              color: Colors.white.withOpacity(0.6),
              child: CheckboxListTile(
                value: _checkboxValue,
                onChanged: (val) {
                  if (_checkboxValue == false) {
                    setState(() {
                      _checkboxValue = true;
                    });
                  } else if (_checkboxValue == true) {
                    setState(() {
                      _checkboxValue = false;
                    });
                  }
                },
                title: Text(
                  'I don\'t have an account, need to register',
                  style: TextStyle(
                      fontSize: 16.0,
//                      color: Colors.black,
//                      backgroundColor: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
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
