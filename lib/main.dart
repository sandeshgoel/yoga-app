import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yoga/services/auth.dart';
import 'package:yoga/services/database.dart';
import 'package:yoga/pages/authenticate_page.dart';
import 'package:yoga/services/tts.dart';

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

    if (user != null) {
      _rightAfterSignIn(context, user);
    }

    return ((user != null) ? MyHomePage() : AuthenticatePage());
  }

  void _rightAfterSignIn(context, user) async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    String uid = user.uid;

    settings.initSettings();
    settings.setUid(uid);
    settings.setEmail(user.email);

    print('Signed in user ${settings.getEmail()}, reading DB ...');

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

    if (settings.getName() == '') {
      if (user.displayName == null)
        settings.setName(settings.getEmail().split('@')[0]);
      else
        settings.setName(user.displayName);
    }
    settings.setPhoto(user.photoURL ?? '');

    print('User name: ${settings.getName()}, photo: ${settings.getPhoto()}');

    var voices = await Tts().flutterTts.getVoices;
    List<String> filterVoices = [];
    for (var voice in voices) {
      if (voice['locale'] == 'en-IN') {
        print('Voice: $voice');
        filterVoices.add(voice['name']);
      }
    }
    settings.setVoices(filterVoices);
    if (settings.getVoice() == '') settings.setVoice(filterVoices[0]);
  }
}
