import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:yoga/pages/activity_page.dart';
import 'package:yoga/pages/routines_page.dart';

import 'package:yoga/services/auth.dart';
import 'package:yoga/services/settings.dart';

import 'package:yoga/shared/constants.dart';
import 'counter_page.dart';
import 'edit_settings_page.dart';
import 'edit_exercise_page.dart';
import 'activity_page.dart';
import 'edit_routine_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _auth = AuthService();
  final _skey0 = GlobalKey();
  final _skey1 = GlobalKey();
  int indexTab = 0;

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
                            .startShowCase([_skey0, _skey1]);
                      });
                    },
                  ),
                ],
                title: Text('Welcome: ${settings.getUser().name}',
                    style: TextStyle(fontSize: 18)),
                leading: _popupMenu(settings),
                bottom: TabBar(
                  onTap: (index) {
                    setState(() {
                      indexTab = index;
                    });
                  },
                  tabs: [
                    Showcase(
                      key: _skey0,
                      description:
                          'First tab lists exercises, second lists routine, and third shows your activity',
                      overlayPadding: EdgeInsets.symmetric(horizontal: 15),
                      contentPadding: EdgeInsets.all(20),
                      child: Tab(text: 'Exercises'),
                    ),
                    Tab(text: 'Routines'),
                    Tab(text: 'Activity'),
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
                      _listExercisePage(),
                      RoutinesPage(),
                      ActivityPage(),
                    ],
                  ),
                ],
              ),
              floatingActionButton: _floatingButton(),
            );
          }),
        ),
      );
    });
  }

  Widget? _floatingButton() {
    switch (indexTab) {
      case 0:
        return Showcase(
          key: _skey1,
          description:
              'Add exercise from a list of pre-defined exercises, or define a custom exercise',
          shapeBorder: CircleBorder(),
          overlayPadding: EdgeInsets.all(8),
          contentPadding: EdgeInsets.all(20),
          child: FloatingActionButton(
            onPressed: () {
              _showExercisePicker();
            },
            child: Icon(Icons.add),
          ),
        );

      case 1:
        return FloatingActionButton(
          onPressed: () {
            _showRoutinePicker();
          },
          child: Icon(Icons.add),
        );

      case 2:
      default:
        return null;
    }
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
// -----------------------------------------------------

  Widget _listExercisePage() {
    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: settings.lengthParams(),
        itemBuilder: (BuildContext context, int index) {
          ConfigParam cp = settings.getParam(index);
          return Row(
            children: [
              Expanded(
                flex: 85,
                child: InkWell(
                  onTap: () => _configSelected(context, cp.name),
                  child: Container(
                    height: 50,
                    decoration: boxDeco,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cp.name.length > 22
                              ? '${cp.name.substring(0, 20)}...'
                              : '${cp.name}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('${cp.stages.length} stages, ${cp.rounds} rounds')
                      ],
                    )),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(),
              ),
              Expanded(
                flex: 12,
                child: CircleAvatar(
                  radius: 25,
                  child: IconButton(
                    onPressed: () => _editConfig(context, cp.name),
                    icon: Icon(Icons.edit),
                    tooltip: 'Edit config',
                  ),
                  backgroundColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (BuildContext context, int index) => Container(
          height: 20,
        ),
      );
    });
  }

  Widget _createExerciseTile(String name) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _addConfig(context, name);
      },
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: boxDeco,
          child: Text(name, style: TextStyle(fontSize: 12))),
    );
  }

  void _showExercisePicker() {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Scrollbar(
                isAlwaysShown: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      _createExerciseTile('Custom ...'),
                      SizedBox(height: 10),
                      Column(
                          children: settings
                              .getExerciseLib()
                              .map((e) => _createExerciseTile(e.name))
                              .toList()),
                    ],
                  ),
                ),
              ),
              title: Text('Add exercise'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'))
              ],
            ),
        barrierDismissible: false);
  }

  void _addConfig(context, String cfgName) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    int index = settings.findParamIndex(cfgName);

    if (index != -1) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Already present'),
                content: Text(
                    'The exercise $cfgName is already present. Delete it first to add it again.'),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'))
                ],
              ),
          barrierDismissible: false);
      return;
    } else if (cfgName == 'Custom ...') {
      int i = 1;
      do {
        cfgName = 'Custom exercise ' + i.toString();
        i++;
      } while (settings.findParamIndex(cfgName) != -1);
      settings.addParam(new ConfigParam(cfgName, 10, [Stage('Stagename', 4)]));
    } else {
      settings.addParam(settings.getExerciseFromLib(cfgName)!);
    }

    _editConfig(context, cfgName);
  }

  void _configSelected(context, String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return CounterPage(
          exercise: cfg,
          routine: '',
        );
      }),
    ).then((value) {
      setState(() {});
    });
  }

  void _editConfig(context, String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditConfigPage(cfg: cfg);
      }),
    ).then((value) {
      setState(() {});
    });
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

// ----------------------------------------------------

  Widget _createRoutineTile(String name) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _addRoutine(context, name);
      },
      child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: boxDeco,
          child: Text(name, style: TextStyle(fontSize: 12))),
    );
  }

  void _showRoutinePicker() {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Column(
                  children: [
                        _createRoutineTile('Custom ...'),
                        SizedBox(height: 10)
                      ] +
                      settings
                          .getRoutineLib()
                          .map((e) => _createRoutineTile(e.name))
                          .toList()),
              title: Text('Add routine'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'))
              ],
            ),
        barrierDismissible: false);
  }

  void _addRoutine(context, String cfgName) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    int index = settings.findRoutineIndex(cfgName);

    if (index != -1) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Already present'),
                content: Text(
                    'The routine $cfgName is already present. Delete it first to add it again.'),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'))
                ],
              ),
          barrierDismissible: false);
      return;
    } else if (cfgName == 'Custom ...') {
      int i = 1;
      do {
        cfgName = 'Custom routine ' + i.toString();
        i++;
      } while (settings.findRoutineIndex(cfgName) != -1);

      settings.addRoutine(Routine(cfgName, [Exercise(exAnulomVilom, 10)]));
    } else {
      Routine r = settings.getRoutineFromLib(cfgName)!;
      print('_addRoutine: Adding routine $cfgName');

      List<String> npExercises = settings.exercisesNotPresent(r);
      if (npExercises.length > 0) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Adding exercises'),
                  content: Text(
                      'The routine $cfgName includes some new exercises $npExercises.\n\nAdding these to your exercise list!!'),
                ));
        npExercises.forEach((ex) {
          settings.addParam(settings.getExerciseFromLib(ex)!);
        });
      }

      settings.addRoutine(r);
    }

    _editRoutine(context, cfgName);
  }

  void _editRoutine(context, String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditRoutinePage(cfg: cfg);
      }),
    ).then((value) {
      setState(() {});
    });
  }
}
