import 'package:flutter/foundation.dart';
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
              gradient: LinearGradient(
                colors: [Colors.lime, Colors.white],
                end: Alignment.topLeft,
                begin: Alignment.bottomRight,
              ), /*
              image: DecorationImage(
                image: AssetImage("assets/images/bg-blue.jpeg"),
                fit: BoxFit.cover,
              ),*/
            ),
          ),
          _editConfigPage(context, widget.cfg),
        ],
      ),
    );
  }

  Widget _editConfigPage(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    //print('**** _editConfigPage: ${settings.cps}');
    var pindex = settings.findParamIndex(cfg);
    ConfigParam cp = settings.getParam(pindex);
    ConfigParam? exl = settings.getExerciseFromLib(cfg);

    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
                  // Exercise name

                  FormBuilderTextField(
                    name: 'configName',
                    initialValue: cfg,
                    decoration: InputDecoration(
                      labelText: 'Exercise Name',
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Description

                  FormBuilderTextField(
                    name: 'desc',
                    initialValue: cp.desc,
                    decoration: InputDecoration(
                      labelText: 'Exercise Description',
                    ),
                    //style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Category

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Category ', style: settingsTextStyle),
                      Text(
                          (exl == null)
                              ? ''
                              : (exl.category != cp.category)
                                  ? '*'
                                  : '',
                          style: starStyle),
                      Expanded(child: Container()),
                      DropdownButton<String>(
                        value: describeEnum(cp.category),
                        onChanged: (String? newValue) {
                          setState(() {
                            cp.category = ConfigParam.strToCategory(newValue!);
                          });
                        },
                        items: ExCategory.values
                            .map((e) => describeEnum(e))
                            .toList()
                            .asMap()
                            .entries
                            .map<DropdownMenuItem<String>>((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.value,
                            child: Row(
                              children: [
/*                                FaIcon(
                                  FontAwesomeIcons.balanceScale,
//                                  color: Colors.orange,
                                  size: 15,
                                ),
                                SizedBox(width: 10),*/
                                Text(
                                  '${entry.value}',
                                  style: settingsTextStyle,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // Number of rounds

                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 75,
                        child: Text('Total Rounds', style: settingsTextStyle),
                      ),
                      Expanded(
                        flex: 25,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 30,
                              child: ElevatedButton(
                                onPressed: (cp.rounds <= 1)
                                    ? null
                                    : () {
                                        setState(() {
                                          cp.rounds -= 1;
                                        });
                                      },
                                child: FittedBox(child: Icon(Icons.remove)),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(2),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 40,
                              child: Text(
                                cp.rounds.toString(),
                                style: settingsTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 30,
                              child: ElevatedButton(
                                onPressed: (cp.rounds > 98)
                                    ? null
                                    : () {
                                        setState(() {
                                          cp.rounds += 1;
                                        });
                                      },
                                child: FittedBox(child: Icon(Icons.add)),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Alternate Left Right

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Alternate Left/Right ', style: settingsTextStyle),
                      Text(
                          (exl == null)
                              ? ''
                              : (exl.altLeftRight != cp.altLeftRight)
                                  ? '*'
                                  : '',
                          style: starStyle),
                      Expanded(child: Container()),
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
                  SizedBox(height: 10)
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
                        onPressed: (exl == null)
                            ? null
                            : settings.exerciseDiffInLib(cfg) == false
                                ? null
                                : () => _loadDefault(cfg),
                        child: Text('Defaults', style: settingsTextStyle),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () => _deleteConfig(context, cfg),
                          child: Text('Delete', style: settingsTextStyle)),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _createCopy(cfg),
                    child: Text('Create a Copy', style: settingsTextStyle),
                  ),
                ],
          ),
        ),
      ),
    );
  }

  void _createCopy(String cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    String newCfg = settings.createCopy(cfg);
    Navigator.pop(context);
    showMsg(context, 'Exercise \'$newCfg\' created');
  }

  void _loadDefault(String cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    ConfigParam? exl = settings.getExerciseFromLib(cfg);

    if (exl == null) {
      showMsg(context, 'Exercise \'$cfg\' does not exist in library!');
      return;
    }

    int pindex = settings.findParamIndex(cfg);

    settings.cps.removeAt(pindex);
    settings.cps.add(new ConfigParam.fromJson(exl.toJson()));
    Navigator.pop(context);
    showMsg(context, 'Exercise \'$cfg\' reset to defaults from library');
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
    cp.desc = values['desc'];
    //for (var i = 0; i < cp.stages.length; i++) {
    //  cp.stages[i].name = values['stagename' + i.toString()];
    //}
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
      cp.stages.add(Stage('Stagename', cp.sameCount ? cp.stages[0].count : 4));
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
    int pindex = settings.findParamIndex(cfg);
    ConfigParam cp = settings.getParam(pindex);
    ConfigParam? exl = settings.getExerciseFromLib(cfg);
    List<TextEditingController> _ctrlList = [];

    list.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Stages: ${cp.stages.length} ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
              (exl == null)
                  ? ''
                  : (exl.stages.length != cp.stages.length)
                      ? '*'
                      : '',
              style: starStyle),
        ],
      ),
    );

    list.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Same count in all stages ', style: settingsTextStyle),
          Text(
              (exl == null)
                  ? ''
                  : (exl.sameCount != cp.sameCount)
                      ? '*'
                      : '',
              style: starStyle),
          Expanded(child: Container()),
          Switch(
            value: cp.sameCount,
            onChanged: (val) {
              setState(() {
                cp.sameCount = val;
                if (cp.sameCount)
                  for (var i = 0; i < cp.stages.length; i++)
                    cp.stages[i].count = cp.stages[0].count;
              });
            },
          ),
        ],
      ),
    );

    list.add(SizedBox(height: 10));
    list.add(Text(
      'Long press and drag any row to reorder stages',
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
    ));
    list.add(SizedBox(height: 10));

    for (var i = 0; i < cp.stages.length; i++)
      _ctrlList.add(TextEditingController(text: cp.stages[i].name));

    List<Widget> elist = [];
    for (var i = 0; i < cp.stages.length; i++) {
      bool disableCount = (cp.sameCount & (i > 0));
      elist.add(Row(
        key: Key('$i'),
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 55,
            child: TextField(
              controller: _ctrlList[i],
              style: settingsTextStyle,
              onChanged: (value) {
                cp.stages[i].name = value;
              },
            ), /*
            child: FormBuilderTextField(
              name: 'stagename$i',
              initialValue: cp.stages[i].name,
              style: settingsTextStyle,
            ),*/
          ),
          Expanded(
            flex: 5,
            child: Text(
                (exl == null)
                    ? ''
                    : (exl.stages.length <= i)
                        ? '+'
                        : (exl.stages[i].name != cp.stages[i].name)
                            ? '*'
                            : '',
                style: starStyle),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 30,
                  child: ElevatedButton(
                    onPressed: (cp.stages[i].count <= 1) | disableCount
                        ? null
                        : () {
                            setState(() {
                              cp.stages[i].count -= 1;
                              if (cp.sameCount & (i == 0))
                                for (int j = 1; j < cp.stages.length; j++)
                                  cp.stages[j].count = cp.stages[i].count;
                            });
                          },
                    child: FittedBox(child: Icon(Icons.remove)),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(2),
                    ),
                  ),
                ),
                Expanded(
                  flex: 40,
                  child: Text(
                    cp.stages[i].count.toString(),
                    style: settingsTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 30,
                  child: ElevatedButton(
                    onPressed: (cp.stages[i].count > 98) | disableCount
                        ? null
                        : () {
                            setState(() {
                              cp.stages[i].count += 1;
                              if (cp.sameCount & (i == 0))
                                for (int j = 1; j < cp.stages.length; j++)
                                  cp.stages[j].count = cp.stages[i].count;
                            });
                          },
                    child: FittedBox(child: Icon(Icons.add)),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*
          Expanded(
            flex: 10,
            child: TextFormField(
              controller: _ctrlList[i],
              //..text = cp.stages[i].count.toString(),
              //initialValue: disableCount ? '-' : cp.stages[i].count.toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[1-9][0-9]*'))
              ],
              textAlign: TextAlign.center,
              style: disableCount ? settingsTextStyleGrey : settingsTextStyle,
              readOnly: disableCount ? true : false,

              onChanged: (val) {
                if (cp.sameCount & (i == 0)) {
                  for (int j = 1; j < cp.stages.length; j++) {
                    cp.stages[j].count = int.tryParse(val) ?? 1;
                    _ctrlList[j].text = val;
                  }
                }
                cp.stages[i].count = int.tryParse(val) ?? 1;
              },
            ),
          ),*/
          Expanded(
            flex: 5,
            child: Text(
                (exl == null)
                    ? ''
                    : (exl.stages.length <= i)
                        ? '+'
                        : (exl.stages[i].count != cp.stages[i].count)
                            ? '*'
                            : '',
                style: starStyle),
          ),
          Expanded(
            flex: 10,
            child: cp.stages.length == 1
                ? Container()
                : IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _deleteStage(context, cfg, i),
                  ),
          ),
          Expanded(flex: 5, child: Container()),
          kIsWeb ? SizedBox(width: 40, child: Container()) : Container(),
        ],
      ));
    }

    list.add(
      ReorderableListView(
        children: elist,
        shrinkWrap: true,
        onReorder: (int oldIndex, int newIndex) =>
            _reorder(oldIndex, newIndex, cfg),
      ),
    );

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

  void _reorder(int oldIndex, int newIndex, String cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    setState(() {
      int index = settings.findParamIndex(cfg);
      ConfigParam ex = settings.getParam(index);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      Stage e = ex.stages.removeAt(oldIndex);
      ex.stages.insert(newIndex, e);
    });
  }
}
