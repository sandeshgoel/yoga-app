import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yoga/services/auth.dart';
import 'package:yoga/services/database.dart';
import 'package:yoga/pages/authenticate_page.dart';

import 'services/settings.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => Settings(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context, listen: false);
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

class Wrapper extends StatelessWidget {
  Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dynamic user = Provider.of<User?>(context);

    if (user != null) {
      _rightAfterSignIn(context, user);
    }

    return ((user != null)
        ? MyHomePage(title: 'Yoga Assist')
        : AuthenticatePage());
  }

  void _rightAfterSignIn(context, user) async {
    String uid = user.uid;
    Settings settings = Provider.of<Settings>(context, listen: false);
    settings.uid = uid;
    settings.email = user.email;

    print('Signed in user $uid, reading DB, updating local cache');

    var doc = await DBService(uid: uid).getUserData();
    var cfg = doc.data();
    if (cfg != null) {
      if (cfg.isNotEmpty)
        settings.settingsFromJson(cfg);
      else
        print('DB config is empty!!');
    } else {
      print('DB record does not exist!!');
    }
    settings.saveSettings();
  }
}
