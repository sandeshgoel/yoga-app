import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yoga/pages/email_verify_page.dart';
import 'package:yoga/services/auth.dart';

import 'package:yoga/pages/authenticate_page.dart';

import 'services/settings.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<YogaSettings>(create: (_) => YogaSettings()),
        ChangeNotifierProvider<GoogleSignInProvider>(
            create: (_) => GoogleSignInProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    settings.loadSettings();

    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Yoga Assist',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Wrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class Wrapper extends StatefulWidget {
  Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final dynamic user = Provider.of<User?>(context);

    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return ((user != null)
          ? (settings.getVerified() ? MyHomePage() : EmailVerifyPage())
          : AuthenticatePage());
    });
  }
}
