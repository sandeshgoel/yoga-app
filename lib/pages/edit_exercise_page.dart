import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/shared/constants.dart';

class EditConfigPage extends StatefulWidget {
  final String cfg;

  const EditConfigPage({Key? key, required this.cfg}) : super(key: key);

  @override
  _EditConfigPageState createState() => _EditConfigPageState();
}

class _EditConfigPageState extends State<EditConfigPage> {
  final _formKey = new GlobalKey<FormBuilderState>();
  late YogaSettings _settings;

  @override
  void didChangeDependencies() {
    _settings = Provider.of<YogaSettings>(context, listen: false);
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
        title: Text('Edit Exercise Config'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg-blue.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _editConfigPage(context, widget.cfg),
        ],
      ),
    );
  }

  Widget _editConfigPage(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    print('**** _editConfigPage: ${settings.cps}');
    var pindex = settings.findParamIndex(cfg);
    ConfigParam cp = settings.getParam(pindex);

    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
                  FormBuilderTextField(
                    name: 'configName',
                    initialValue: cfg,
                    decoration: InputDecoration(
                      labelText: 'Exercise Name',
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Number of rounds

                  FormBuilderSlider(
                    name: 'rounds',
                    initialValue: cp.rounds.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    decoration: InputDecoration(
                        labelText: 'Number of rounds',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Alternate Left Right

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Alternate Left/Right', style: settingsTextStyle),
                      Expanded(
                        child: Container(),
                      ),
                      Switch(
                        value: cp.altLeftRight,
                        onChanged: (val) {
                          setState(() {
                            cp.altLeftRight = val;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20)
                ] +
                _stageList(settings, cfg) +
                [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () => _saveConfig(context, cfg),
                          child: Text('Save', style: settingsTextStyle)),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () => _deleteConfig(context, cfg),
                          child: Text('Delete', style: settingsTextStyle)),
                    ],
                  ),
                ],
          ),
        ),
      ),
    );
  }

  void _saveConfig(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    int pindex = settings.findParamIndex(cfg);

    _formKey.currentState!.save();
    var values = _formKey.currentState!.value;

    String newName = values['configName'];
    String oldName = settings.getParam(pindex).name;
    if (newName != oldName) {
      // check to avoid duplicate name
      if (settings.findParamIndex(newName) != -1) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
                'The exercise name \'$newName\' already exists, choose a different name!!'),
            title: Text('ERROR'),
          ),
        );
        return;
      }

      // update the name in all saved routines too
      for (var i = 0; i < settings.routines.length; i++) {
        for (var j = 0; j < settings.routines[i].exercises.length; j++) {
          if (settings.routines[i].exercises[j].name == oldName)
            settings.routines[i].exercises[j].name = newName;
        }
      }
    }

    //print('_saveConfig: Before $pindex ${settings.cps}');
    ConfigParam cp = settings.getParam(pindex);
    cp.name = values['configName'];
    cp.rounds = values['rounds'].toInt();
    for (var i = 0; i < cp.stages.length; i++) {
      cp.stages[i].name = values['stagename' + i.toString()];
      cp.stages[i].count = int.parse(values['stagecount' + i.toString()]);
    }
    settings.setParam(pindex, cp);
    //print('_saveConfig: $pindex $cp');

    Navigator.pop(context);
  }

  void _deleteConfig(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    if (settings.cps.length == 1) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content:
              Text('Can\'t delete this, you must have at least one exercise!!'),
          title: Text('ERROR'),
        ),
      );
      return;
    }

    List<String> affectedRoutines = settings.routinesWhichInclude(cfg);
    if (affectedRoutines.length > 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(
              'The exercise \'$cfg\' is part of routines $affectedRoutines!!\nRemove it from those routines before deleting from here.'),
          title: Text('ERROR'),
        ),
      );
      return;
    }
    settings.removeParam(cfg);
    Navigator.pop(context);
  }

  void _addStage(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    setState(() {
      var pindex = settings.findParamIndex(cfg);
      ConfigParam cp = settings.getParam(pindex);
      cp.stages.add(Stage('Stagename', 4));
      settings.setParam(pindex, cp);
    });
  }

  void _deleteStage(context, cfg, i) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    setState(() {
      var pindex = settings.findParamIndex(cfg);
      ConfigParam cp = settings.getParam(pindex);
      cp.stages.removeAt(i);
      settings.setParam(pindex, cp);
    });
  }

  List<Widget> _stageList(settings, cfg) {
    List<Widget> list = [];
    var pindex = settings.findParamIndex(cfg);
    var stages = settings.getParam(pindex).stages;

    list.add(Center(
        child: Text(
      'Stages: ${stages.length}',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    )));

    for (var i = 0; i < stages.length; i++) {
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(flex: 10, child: Container()),
          Expanded(
            flex: 45,
            child: FormBuilderTextField(
              name: 'stagename$i',
              initialValue: stages[i].name,
              style: settingsTextStyle,
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
              style: settingsTextStyle,
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
      ));
    }

    list.add(SizedBox(height: 20));
    list.add(CircleAvatar(
      child: IconButton(
        icon: Icon(Icons.add),
        onPressed: () => _addStage(context, cfg),
        tooltip: 'Add Stage',
      ),
    ));

    return list;
  }
}
