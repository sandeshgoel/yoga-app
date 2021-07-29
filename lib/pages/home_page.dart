import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yoga/services/auth.dart';
import 'package:yoga/services/database.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/services/user_activity.dart';
import 'counter_page.dart';
import 'edit_settings_page.dart';
import 'edit_config_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<YogaSettings>(context);
    var _photo = settings.getPhoto();
    GoogleSignInProvider _google =
        Provider.of<GoogleSignInProvider>(context, listen: false);

    return DefaultTabController(
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
        floatingActionButton: FloatingActionButton(
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
        await DBService(uid: settings.uid).getUserActivity();
    return queryRef.docs.map((doc) => UserActivity.fromJson(doc)).toList();
  }

  Widget _activityPage() {
    return FutureBuilder<List<UserActivity>>(
        future: _activity(), // a previously-obtained Future<String> or null
        builder:
            (BuildContext context, AsyncSnapshot<List<UserActivity>> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            List<UserActivity> actList =
                snapshot.data ?? [UserActivity('', '', DateTime.now(), 0)];
            actList.forEach((act) {
              children.add(Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16),
                  child: Text(
                      '${act.start}: ${act.actName} for ${act.duration} seconds')));
            });
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
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
