import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:yoga/pages/activity_page.dart';
import 'package:yoga/pages/exercises_page.dart';
import 'package:yoga/pages/routines_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: ShowCaseWidget(
          builder: Builder(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    icon: Icon(Icons.help_rounded),
                    onPressed: () {
                      setState(() {
                        ShowCaseWidget.of(context)!
                            .startShowCase([_skey0, _skey1, _skey2, _skey3]);
                      });
                    },
                  ),
                ],
                title: Text('Welcome: ${settings.getUser().name}',
                    style: TextStyle(fontSize: 18)),
                leading: Showcase(
                  key: _skey3,
                  description:
                      'Click here to access the settings menu, or logout from the application',
                  //overlayPadding: EdgeInsets.all(2),
                  contentPadding: EdgeInsets.all(20),
                  shapeBorder: CircleBorder(),
                  child: _popupMenu(settings),
                ),
                bottom: TabBar(
                  tabs: [
                    Showcase(
                      key: _skey0,
                      description:
                          'First tab lists exercises.\n\nYou can add new exercises using the add button at the bottom. Choose from a library of predefined exercises, or create your own custom exercise',
                      overlayPadding: EdgeInsets.symmetric(horizontal: 15),
                      contentPadding: EdgeInsets.all(20),
                      child: Tab(text: 'Exercises'),
                    ),
                    Showcase(
                      key: _skey1,
                      description:
                          'Second tab lists routines, a routine is a sequence of exercises.\n\nYou can add new routines using the add button at the bottom. Choose from a library of predefined routines, or create your own custom routine',
                      overlayPadding: EdgeInsets.symmetric(horizontal: 15),
                      contentPadding: EdgeInsets.all(20),
                      child: Tab(text: 'Routines'),
                    ),
                    Showcase(
                      key: _skey2,
                      description:
                          'The last tab shows your activity and your progress relative to the target you have set',
                      overlayPadding: EdgeInsets.symmetric(horizontal: 15),
                      contentPadding: EdgeInsets.all(20),
                      child: Tab(text: 'Activity'),
                    ),
                  ],
                ),
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
                  TabBarView(
                    children: [
                      ExercisesPage(),
                      RoutinesPage(),
                      ActivityPage(),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      );
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
                ? AssetImage("assets/icon/yoga.png") as ImageProvider
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
      ],
      onSelected: (item) async {
        switch (item) {
          case 0:
            _editSettings(context);
            break;
          case 1:
            await _auth.signOut();
            await _google.googleSignOut();
            break;
          default:
            print('invalid item $item');
        }
      },
    );
  }

  void _editSettings(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditSettingsPage();
      }),
    ).then((value) {
      setState(() {});
    });
  }
}
