import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volume_control/volume_control.dart';
import 'package:workmanager/workmanager.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:yoga/pages/email_verify_page.dart';
import 'package:yoga/services/auth.dart';

import 'package:yoga/pages/authenticate_page.dart';
import 'package:yoga/services/database.dart';
import 'package:yoga/services/notifications.dart';
import 'package:yoga/services/tts.dart';
import 'package:yoga/services/user_activity.dart';

import 'services/settings.dart';
import 'pages/home_page.dart';

List<String> filterVoices = [];
String appVersion = '';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService().init();
    //await NotificationService().show('Info', '$task called');
    print("Native called background task: $task 222");

    await Firebase.initializeApp();

    // Read daily target and notify from settings
    YogaSettings settings = YogaSettings();
    String uid = inputData!['uid'];
    String email = inputData['email'];

    var doc = await DBService(uid: uid, email: email).getUserData();
    var cfg = doc.data();
    if (cfg != null) settings.settingsFromJson(cfg);

    if (settings.getNotify()) {
      // Read activity
      QuerySnapshot queryRef =
          await DBService(uid: uid, email: email).getUserActivityToday();
      List<UserActivity> actList =
          queryRef.docs.map((doc) => UserActivity.fromJson(doc)).toList();

      int totTime = 0;
      for (UserActivity act in actList) totTime += act.duration;
      totTime ~/= 60;
      int timeLeft = settings.getDailyTarget() - totTime;

      String msg = '';
      if (timeLeft > 0) {
        msg = '$timeLeft minutes to go today, let\'s go!!';
      } else {
        msg =
            'You have completed $totTime minutes today, way to nail the target. Yay!!';
      }

      // create notification and send
      await NotificationService().show(inputData['name'], msg);
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (!kIsWeb) {
    VolumeControl.setVolume(0.5);

    var voices = await Tts().flutterTts.getVoices;
    for (var voice in voices) {
      if (voice['locale'] == 'en-IN') {
        print('Voice: $voice');
        filterVoices.add(voice['name']);
      }
    }
  }

  await NotificationService().init();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appVersion =
      'Version ' + packageInfo.version + ' +' + packageInfo.buildNumber;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
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
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: Center(
        child: SizedBox(
          width: kIsWeb ? 400 : double.infinity,
          height: kIsWeb ? 800 : double.infinity,
          child: MaterialApp(
            title: 'Yoga Buddy',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: kIsWeb ? Wrapper() : UpgradeAlert(child: Wrapper()),
            debugShowCheckedModeBanner: false,
          ),
        ),
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
          : AuthenticatePage(ver: appVersion));
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

    if (!kIsWeb) {
      settings.setVoices(filterVoices);
      if (!filterVoices.contains(settings.getVoice()))
        settings.setVoice(filterVoices[0]);
    }

    String userName = user.displayName ?? user.email.split('@')[0];
    settings.setUser(userName, user.email, user.uid, user.photoURL ?? '',
        user.emailVerified);
    settings.addExercisesNotPresent();

    print(
        '_rightAfterSignIn: Signed in user ${settings.getUser()}, reading DB now ..');

    // read rest of the settings from DB
    var doc = await DBService(uid: user.uid, email: user.email).getUserData();
    var cfg = doc.data();
    if (cfg != null)
      settings.settingsFromJson(cfg);
    else
      print('_rightAfterSignIn: DB returned null record for ${user.uid}!!');

    if (!kIsWeb) {
      if (!filterVoices.contains(settings.getVoice()))
        settings.setVoice(
            filterVoices.length > 7 ? filterVoices[7] : filterVoices[0]);
    }

    settings.addExercisesNotPresent();

    // save all settings back to DB
    settings.saveSettings();

    if (!kIsWeb) {
      VolumeControl.setVolume(settings.getSpeechVolume());

      await NotificationService().show('', 'User ${user.email} has logged in');

      // calculate initial delay
      int targetHour = settings.getTargetHour();
      var now = DateTime.now();
      var nextTarget;

      if (now.hour >= targetHour + 12)
        nextTarget = DateTime(now.year, now.month, now.day, targetHour)
            .add(Duration(days: 1));
      else if (now.hour >= targetHour)
        nextTarget = DateTime(now.year, now.month, now.day, targetHour + 12);
      else
        nextTarget = DateTime(now.year, now.month, now.day, targetHour);
      Duration delay = nextTarget.difference(now);

      Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      Workmanager().registerPeriodicTask("1", "yogaReminderTask",
          inputData: {'uid': user.uid, 'email': user.email, 'name': userName},
          frequency: Duration(hours: 12),
          initialDelay: delay,
          existingWorkPolicy: ExistingWorkPolicy.replace);
      print('Scheduled yogaReminderTask, delay $delay ...');
    }

    settings.setLoadComplete(true);
  }
}
