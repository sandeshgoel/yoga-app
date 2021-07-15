import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yoga/settings.dart';

class EditConfigPage extends StatefulWidget {
  final String cfg;

  const EditConfigPage({Key? key, required this.cfg}) : super(key: key);

  @override
  _EditConfigPageState createState() => _EditConfigPageState();
}

class _EditConfigPageState extends State<EditConfigPage> {
  final _formKey = new GlobalKey<FormBuilderState>();
  late Settings _settings;

  @override
  void didChangeDependencies() {
    _settings = Provider.of<Settings>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _settings.saveSettings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Config'),
      ),
      body: _editConfigPage(context, widget.cfg),
    );
  }

  Widget _editConfigPage(context, cfg) {
    var settings = Provider.of<Settings>(context, listen: false);
    print('**** _editConfigPage: ${settings.cps}');
    var pindex = settings.findParamIndex(cfg);
    ConfigParam cp = settings.getParam(pindex);

    return FormBuilder(
      key: _formKey,
      child: ListView(
        children: [
              Container(
                  padding: EdgeInsets.all(16),
                  child: FormBuilderTextField(
                    name: 'configName',
                    initialValue: cfg,
                    decoration: InputDecoration(
                      labelText: 'Config Name',
                    ),
                  )),
              Container(
                  padding: EdgeInsets.all(16),
                  child: FormBuilderSlider(
                      name: 'rounds',
                      initialValue: cp.rounds.toDouble(),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      decoration: InputDecoration(
                        labelText: 'Number of rounds',
                      ))),
            ] +
            _stageList(settings, cfg) +
            [
              Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () => _saveConfig(context, cfg),
                          child: Text('Save')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () => _deleteConfig(context, cfg),
                          child: Text('Delete')),
                    ],
                  )),
            ],
      ),
    );
  }

  void _saveConfig(context, cfg) {
    var settings = Provider.of<Settings>(context, listen: false);
    int pindex = settings.findParamIndex(cfg);

    _formKey.currentState!.save();
    var values = _formKey.currentState!.value;

    String newName = values['configName'];
    if (newName != settings.getParam(pindex).name) {
      if (settings.findParamIndex(newName) != -1) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
                'The config name \'$newName\' already exists, choose a different name!!'),
            title: Text('ERROR'),
          ),
        );
        return;
      }
    }

    ConfigParam cp = settings.getParam(pindex);
    cp.name = values['configName'];
    cp.rounds = values['rounds'].toInt();
    for (var i = 0; i < cp.stages.length; i++) {
      cp.stages[i].name = values['stagename' + i.toString()];
      cp.stages[i].count = int.parse(values['stagecount' + i.toString()]);
    }
    settings.setParam(pindex, cp);

    Navigator.pop(context);
  }

  void _deleteConfig(context, cfg) {
    var settings = Provider.of<Settings>(context, listen: false);
    print('**** _deleteConfig: ${settings.cps}');
    settings.removeParam(cfg);

    Navigator.pop(context);
  }

  void _addStage(context, cfg) {
    var settings = Provider.of<Settings>(context, listen: false);

    setState(() {
      var pindex = settings.findParamIndex(cfg);
      ConfigParam cp = settings.getParam(pindex);
      cp.stages.add(Stage('Stagename', 4));
      settings.setParam(pindex, cp);
    });
  }

  void _deleteStage(context, cfg, i) {
    var settings = Provider.of<Settings>(context, listen: false);
    setState(() {
      var pindex = settings.findParamIndex(cfg);
      ConfigParam cp = settings.getParam(pindex);
      cp.stages.removeAt(i);
      settings.setParam(pindex, cp);
    });
  }

  List<Container> _stageList(settings, cfg) {
    List<Container> list = [];
    var pindex = settings.findParamIndex(cfg);
    var stages = settings.getParam(pindex).stages;

    list.add(Container(
        padding: EdgeInsets.all(16),
        child: Center(
            child: Text(
          'Stages: ${stages.length}',
          style: TextStyle(fontSize: 20),
        ))));

    for (var i = 0; i < stages.length; i++) {
      list.add(Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(flex: 10, child: Container()),
            Expanded(
              flex: 45,
              child: FormBuilderTextField(
                name: 'stagename$i',
                initialValue: stages[i].name,
              ),
            ),
            Expanded(flex: 10, child: Container()),
            Expanded(
              flex: 10,
              child: FormBuilderTextField(
                name: 'stagecount$i',
                initialValue: stages[i].count.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(flex: 10, child: Container()),
            Expanded(
              flex: 5,
              child: stages.length == 1
                  ? Container()
                  : IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _deleteStage(context, cfg, i),
                    ),
            ),
            Expanded(flex: 10, child: Container()),
          ],
        ),
      ));
    }

    list.add(Container(
      padding: EdgeInsets.all(16),
      child: CircleAvatar(
        child: IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _addStage(context, cfg),
          tooltip: 'Add Stage',
        ),
      ),
    ));

    return list;
  }
}
