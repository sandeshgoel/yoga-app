import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:yoga/services/auth.dart';
import 'package:yoga/services/database.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/services/user_activity.dart';
import 'counter_page.dart';
import 'edit_settings_page.dart';
import 'edit_config_page.dart';

class ActData {
  final DateTime day;
  final double minutes;

  ActData(this.day, this.minutes);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _auth = AuthService();
  int indexTab = 0;

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<YogaSettings>(context);
    var _photo = settings.getPhoto();
    GoogleSignInProvider _google =
        Provider.of<GoogleSignInProvider>(context, listen: false);

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Container(
              margin: EdgeInsets.only(right: 15),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: Colors.yellow),
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: (_photo == '')
                      ? AssetImage("assets/icon/yoga.png") as ImageProvider
                      : NetworkImage(_photo),
                ),
              ),
            ),
          ],
          title: Text('Welcome: ${settings.getName()}',
              style: TextStyle(fontSize: 18)),
          leading: PopupMenuButton(
            icon: Icon(Icons.menu), //don't specify icon if you want 3 dot menu
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
              print(item);
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
          ),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                indexTab = index;
              });
            },
            tabs: [
              Tab(text: 'Exercises'),
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
                _listConfigsPage(),
                Icon(Icons.directions_transit),
                _activityPage(),
              ],
            ),
          ],
        ),
        floatingActionButton: indexTab > 0
            ? null
            : FloatingActionButton(
                onPressed: () => _addConfig(context),
                tooltip: 'Add Config',
                child: Icon(Icons.add),
              ),
      ),
    );
  }

  Future<List<UserActivity>> _activity() async {
    var settings = Provider.of<YogaSettings>(context);
    QuerySnapshot queryRef =
        await DBService(uid: settings.getUid()).getUserActivityWeek();
    return queryRef.docs.map((doc) => UserActivity.fromJson(doc)).toList();
  }

  Widget _activityPage() {
    var settings = Provider.of<YogaSettings>(context);

    return FutureBuilder<List<UserActivity>>(
        future: _activity(), // a previously-obtained Future<String> or null
        builder:
            (BuildContext context, AsyncSnapshot<List<UserActivity>> snapshot) {
          Widget ret;
          List<Widget> children = [];

          if (snapshot.hasData) {
            List<UserActivity> actList = snapshot.data!;

            DateTime now = DateTime.now();
            DateTime lastMidnight = DateTime(now.year, now.month, now.day);
            List<DateTime> days = [];
            for (int i = 6; i >= 0; i--) {
              days.add(lastMidnight.subtract(Duration(days: i)));
            }

            Map<DateTime, int> totMap = {};
            for (UserActivity act in actList) {
              var date =
                  DateTime(act.start.year, act.start.month, act.start.day);
              totMap[date] = (totMap[date] ?? 0) + act.duration;
            }

            List<ActData> data = [];
            List<double> timeList = [];
            for (DateTime day in days) {
              int minutes = totMap[day] ?? 0;
              minutes += 30;
              minutes ~/= 60;
              timeList.add(minutes.toDouble());
              data.add(ActData(day, minutes.toDouble()));
            }
            print(data.map((d) => '${d.day}:${d.minutes}').toList());

            int totTime = totMap[lastMidnight] ?? 0;

            totTime += 30;
            totTime ~/= 60;
            int leftTime = settings.getDailyTarget() - totTime;

            actList.forEach((act) {
              children.add(Text(
                '${DateFormat("MMM-dd HH:mm").format(act.start)}: ${act.actName} for ${act.duration} seconds',
                style: TextStyle(
                    fontSize: 12, fontFeatures: [FontFeature.tabularFigures()]),
              ));
            });

            ret = SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Today's minutes

                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white.withOpacity(0.6),
                      border: Border.all(color: Colors.lightBlue, width: 1),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text('Today\'s minutes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.withOpacity(0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.8),
                                  blurRadius: 10.0,
                                  spreadRadius: 10.0,
                                ),
                              ]),
                          child: Center(
                            child: Text(
                              totTime.toString(),
                              style: TextStyle(
                                  fontSize: 60, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            (leftTime > 0)
                                ? '$leftTime minutes more to meet today\'s goal'
                                : 'Congrats, reached today\'s goal',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Weekly chart

                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white.withOpacity(0.6),
                      border: Border.all(color: Colors.lightBlue, width: 1),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text('Last Week',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          height: 150,
                          child: charts.TimeSeriesChart(
                            <charts.Series<ActData, DateTime>>[
                              charts.Series(
                                id: "Minutes",
                                data: data,
                                domainFn: (ActData s, _) => s.day,
                                measureFn: (ActData s, _) => s.minutes,
                              ),
                            ],
                            animate: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Raw Activity Log

                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white.withOpacity(0.6),
                      border: Border.all(color: Colors.lightBlue, width: 1),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: Text('Raw Activity Log',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: children,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
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
            ret = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  )
                ]);
          }
          return ret;
        });
  }

  Widget _listConfigsPage() {
    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: settings.lengthParams(),
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: [
              Expanded(
                flex: 85,
                child: InkWell(
                  onTap: () =>
                      _configSelected(context, settings.getParam(index).name),
                  child: Container(
                    height: 50,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.white.withOpacity(0.4),
                      border: Border.all(color: Colors.lightBlue, width: 1),
                    ),
                    child: Center(
                        child: Text(
                      '${settings.getParam(index).name}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    onPressed: () =>
                        _editConfig(context, settings.getParam(index).name),
                    icon: Icon(Icons.edit),
                    tooltip: 'Edit config',
                  ),
                  backgroundColor: Colors.white.withOpacity(0.4),
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

  void _addConfig(context) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    String cfgName;

    do {
      cfgName = 'Config ' + settings.r.nextInt(1000).toString();
    } while (settings.findParamIndex(cfgName) != -1);

    settings.addParam(new ConfigParam(cfgName, 10, [Stage('Stagename', 4)]));
    _editConfig(context, cfgName);
  }

  void _configSelected(context, String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return CounterPage(cfg: cfg);
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
}
