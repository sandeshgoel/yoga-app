import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:yoga/services/auth.dart';
import 'package:yoga/shared/constants.dart';

class AuthenticatePage extends StatefulWidget {
  final String ver;
  const AuthenticatePage({required this.ver, Key? key}) : super(key: key);

  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _checkboxValue = false;

  String email = '';
  String password = '';
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text('Welcome to Yoga Buddy'),
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
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Image.asset(
                "assets/icon/yoga_icon_circular.png",
                height: 80,
                width: 80,
              ),
              SizedBox(height: 10),
              Container(
                child: Text(
                  widget.ver,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),

              // Google sign in button

              SizedBox(height: 40),
              SizedBox(
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _googleSignInHandler();
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.orange,
                  ),
                  label: Text(
                    'Sign in with Google',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                ),
              ),

              // OR separator

              Container(
                height: 100,
                child: Center(
                  child: Text(
                    '------- OR -------',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),

              // Email and password

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                child: TextFormField(
                  initialValue: email,
                  validator: (val) => (val!.contains('@') &
                          val.contains('.') &
                          (val.length > 5))
                      ? null
                      : 'Enter a valid email',
                  onChanged: (val) {
                    email = val;
                  },
                  decoration: textInputDeco.copyWith(hintText: 'Email'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 40,
                  child: TextFormField(
                    initialValue: password,
                    obscureText: !_showPassword,
                    validator: (val) => val!.length < 6
                        ? 'Password length must be at least 6'
                        : null,
                    onChanged: (val) {
                      password = val;
                    },
                    decoration: textInputDeco.copyWith(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),

              // Forgot password link

              SizedBox(
                height: 40,
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      if ((email.length < 6) | !email.contains('@'))
                        showMsg(context, 'Enter a valid email');
                      else {
                        await _auth.sendPasswordResetEmail(email);
                        showMsg(context, 'Sent password reset email to $email');
                      }
                    },
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),

              // Sign in button

              SizedBox(height: 10),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  child: Text(_checkboxValue ? 'SIGN UP' : 'SIGN IN',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () async {
                    await _signInHandler();
                  },
                ),
              ),

              // Sign in/up toggle

              SizedBox(
                height: 40,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
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
                    child: Text(
                      _checkboxValue
                          ? 'Already have an account, Sign In'
                          : 'First time user, Sign Up',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),

              // Copyright line

              SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    'Copyright 2021 Sandesh Goel',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _googleSignInHandler() async {
    GoogleSignInProvider google =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    try {
      print('_googleSignInHandler: entered');
      await google.googleLogin();
    } catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text(e.toString()),
                title: Text('Error'),
              ));
    }
  }

  Future _signInHandler() async {
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
                        onPressed: () {
                          _auth.register(email, password);
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
          _auth.register(email, password);
        }
      } else {
        _auth.signIn(email, password);
      }
      if (mounted) {
        setState(() {
          _loading = false;
        });
      } else {
        _loading = false;
      }
    }
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
