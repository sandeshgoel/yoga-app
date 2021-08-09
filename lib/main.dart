import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volume_control/volume_control.dart';

import 'package:yoga/pages/email_verify_page.dart';
import 'package:yoga/services/auth.dart';

import 'package:yoga/pages/authenticate_page.dart';
import 'package:yoga/services/database.dart';
import 'package:yoga/services/tts.dart';

import 'services/settings.dart';
import 'pages/home_page.dart';

List<String> filterVoices = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  VolumeControl.setVolume(0.5);
  var voices = await Tts().flutterTts.getVoices;
  for (var voice in voices) {
    if (voice['locale'] == 'en-IN') {
      print('Voice: $voice');
      filterVoices.add(voice['name']);
    }
  }

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
    //var settings = Provider.of<YogaSettings>(context, listen: false);
    //settings.loadSettings();

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
  String _uidSignedIn = '';

  @override
  Widget build(BuildContext context) {
    final dynamic user = Provider.of<User?>(context);

    FirebaseAuth.instance.authStateChanges().listen(_authChangeHandler);

    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return ((user != null)
          ? (settings.getUser().verified ? MyHomePage() : EmailVerifyPage())
          : AuthenticatePage());
    });
  }

  Future _authChangeHandler(User? user) async {
    if (user == null) {
      print('_authChangeHandler: User is currently signed out!');
      _uidSignedIn = '';
    } else {
      if (_uidSignedIn == user.uid) {
        // this is a duplicate sign in event, ignore it
        print(
            '_authChangeHandler: [DUPLICATE, ignoring] User ${user.email} ${user.uid} is signed in!');
        return;
      }

      print('_authChangeHandler: User ${user.email} ${user.uid} is signed in!');
      _uidSignedIn = user.uid;
      await _rightAfterSignIn(context, user);
    }
  }

  Future _rightAfterSignIn(context, user) async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    print('_rightAfterSignIn: ${user.email} ${user.displayName}');

    settings.initSettings();
    settings.setVoices(filterVoices);
    if (!filterVoices.contains(settings.getVoice()))
      settings.setVoice(filterVoices[0]);

    settings.setUser(user.displayName ?? user.email.split('@')[0], user.email,
        user.uid, user.photoURL ?? '', user.emailVerified);

    print(
        '_rightAfterSignIn: Signed in user ${settings.getUser()}, reading DB now ...');

    // read rest of the settings from DB
    var doc = await DBService(uid: user.uid).getUserData();
    var cfg = doc.data();
    if (cfg != null)
      settings.settingsFromJson(cfg);
    else
      print('_rightAfterSignIn: DB returned null record for ${user.uid}!!');

    if (!filterVoices.contains(settings.getVoice()))
      settings.setVoice(filterVoices[0]);

    // save all settings back to DB
    settings.saveSettings();
  }
}
