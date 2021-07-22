import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoga/services/auth.dart';

import 'package:yoga/services/settings.dart';
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
    var settings = Provider.of<Settings>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _editSettings(context),
          icon: Icon(Icons.settings),
          tooltip: 'Settings',
        ),
        title: Text('Welcome: ${settings.getName()}',
            style: TextStyle(fontSize: 18)),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: Text(
              'logout',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
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
          _listConfigsPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addConfig(context),
        tooltip: 'Add Config',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _listConfigsPage() {
    return Consumer<Settings>(
      builder: (context, settings, _) => ListView.separated(
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
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white.withOpacity(0.6),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Center(
                        child: Text(
                      '${settings.getParam(index).name}',
                      style: TextStyle(fontSize: 20),
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
                  backgroundColor: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (BuildContext context, int index) => Container(
          height: 20,
        ),
      ),
    );
  }

  void _addConfig(context) {
    var settings = Provider.of<Settings>(context, listen: false);
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
