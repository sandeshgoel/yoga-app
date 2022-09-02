import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:yoga/pages/activity_page.dart';
import 'package:yoga/pages/exercises_page.dart';
import 'package:yoga/pages/routines_page.dart';
import 'package:yoga/pages/social_page.dart';

import 'package:yoga/services/auth.dart';
import 'package:yoga/services/settings.dart';

import 'edit_settings_page.dart';
import 'activity_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _auth = AuthService();
  final _skey0 = GlobalKey();
  final _skey1 = GlobalKey();
  final _skey2 = GlobalKey();
  final _skey3 = GlobalKey();
  final _skey4 = GlobalKey();

  Future<bool> _shared() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    while (!settings.getLoadComplete())
      await Future.delayed(Duration(seconds: 1));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _shared(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          Widget ret = Container();

          if (snapshot.hasData) {
            ret = Consumer<YogaSettings>(builder: (context, settings, _) {
              return DefaultTabController(
                initialIndex: 0,
                length: 4,
                child: ShowCaseWidget(
                  builder: Builder(builder: (context) {
                    return Scaffold(
                      appBar: AppBar(
                        actions: [
                          IconButton(
                            icon: Icon(Icons.help_rounded),
                            onPressed: () {
                              setState(() {
                                ShowCaseWidget.of(context).startShowCase(
                                    [_skey0, _skey1, _skey2, _skey3, _skey4]);
                              });
                            },
                          ),
                        ],
                        title: Text('Welcome: ${settings.getUser().name}',
                            style: TextStyle(fontSize: 18)),
                        leading: Showcase(
                          key: _skey4,
                          description:
                              'Click here to access the settings menu, or logout from the application',
                          overlayPadding: EdgeInsets.fromLTRB(-5, 0, 5, 0),
                          contentPadding: EdgeInsets.all(20),
                          shapeBorder: CircleBorder(),
                          child: _popupMenu(settings),
                        ),
                        bottom: TabBar(
                          tabs: [
                            Showcase(
                              key: _skey0,
                              description:
                                  'First tab lists routines, a routine is a sequence of exercises.\n\nYou can add new routines using the add button at the bottom. Choose from a library of predefined routines, or create your own custom routine',
                              overlayPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              contentPadding: EdgeInsets.all(20),
                              child: Tab(
                                child: Text(
                                  'Routines',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            Showcase(
                              key: _skey1,
                              description:
                                  'Second tab lists exercises.\n\nYou can add new exercises using the add button at the bottom. Choose from a library of predefined exercises, or create your own custom exercise',
                              overlayPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              contentPadding: EdgeInsets.all(50),
                              child: Tab(
                                child: Text(
                                  'Exercises',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            Showcase(
                              key: _skey2,
                              description:
                                  'Third tab shows your activity and your progress relative to the target you have set',
                              overlayPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              contentPadding: EdgeInsets.all(20),
                              child: Tab(
                                child: Text(
                                  'Activity',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            Showcase(
                              key: _skey3,
                              description:
                                  'The last tab shows shared routines by other users',
                              overlayPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              contentPadding: EdgeInsets.all(20),
                              child: Tab(
                                child: Text(
                                  'Social',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage("assets/images/background.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          TabBarView(
                            children: [
                              RoutinesPage(),
                              ExercisesPage(),
                              ActivityPage(),
                              SocialPage(),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            });
          } else if (snapshot.hasError) {
            ret = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ]);
          } else {
            ret = Scaffold(
                appBar: AppBar(title: Text('Loading ...')),
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 60),
                      Container(
                        child: CircularProgressIndicator(),
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Loading settings ...'),
                        alignment: Alignment.center,
                      )
                    ]));
          }

          return ret;
        });
  }

  Widget _popupMenu(settings) {
    GoogleSignInProvider _google =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    var _photo = settings.getUser().photo;

    return PopupMenuButton(
      icon: Container(
        margin: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: Colors.yellow),
          image: DecorationImage(
            fit: BoxFit.contain,
            image: (_photo == '')
                ? AssetImage("assets/icon/yoga_icon_circular.png")
                    as ImageProvider
                : NetworkImage(_photo),
          ),
        ),
      ),
      color: Colors.white,
      offset: Offset(0, 50),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: [
              Icon(
                Icons.settings,
                color: Colors.black,
              ),
              Text(
                "  Settings",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.black,
              ),
              Text(
                "  Log out",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.black,
              ),
              Text(
                "  About",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
      onSelected: (item) async {
        switch (item) {
          case 0:
            _editSettings();
            break;
          case 1:
            await _auth.signOut();
            await _google.googleSignOut();
            break;
          case 2:
            await _about();
            break;
          default:
            print('invalid item $item');
        }
      },
    );
  }

  Future _about() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    showAboutDialog(
      context: context,
      applicationVersion: 'Ver $version +$buildNumber',
      applicationIcon: Image.asset(
        "assets/icon/yoga_icon_circular.png",
        height: 40,
        width: 40,
      ),
      children: [
        RichText(
          text: TextSpan(
            text: 'https://sites.google.com/view/yogabuddy',
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final url = 'https://sites.google.com/view/yogabuddy';
                if (await canLaunchUrlString(url)) {
                  await launchUrlString(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
          ),
        ),
      ],
    );
  }

  void _editSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditSettingsPage();
      }),
    ).then((value) {
      setState(() {});
    });
  }
}
