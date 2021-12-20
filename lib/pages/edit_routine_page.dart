import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/shared/constants.dart';

class EditRoutinePage extends StatefulWidget {
  final String cfg;

  const EditRoutinePage({Key? key, required this.cfg}) : super(key: key);

  @override
  _EditRoutinePageState createState() => _EditRoutinePageState();
}

class _EditRoutinePageState extends State<EditRoutinePage> {
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
        title: Text('Edit Routine'),
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
          _editRoutinePage(context, widget.cfg),
        ],
      ),
    );
  }

  Widget _editRoutinePage(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    Routine? rl = settings.getRoutineFromLib(cfg);
    int rindex = settings.findRoutineIndex(cfg);
    Routine r = settings.getRoutine(rindex);

    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: <Widget>[
                  // Routine name

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: FormBuilderTextField(
                      name: 'routineName',
                      initialValue: cfg,
                      decoration: InputDecoration(
                        labelText: 'Routine Name',
                      ),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Shared

                  rl == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Shared ', style: settingsTextStyle),
                            Expanded(child: Container()),
                            Switch(
                              value: r.shared,
                              onChanged: (val) {
                                setState(() {
                                  r.shared = val;
                                });
                              },
                            ),
                          ],
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          alignment: Alignment.centerLeft,
                          child: Text('Library Routine, can\'t be shared',
                              style: settingsTextStyle),
                        ),

                  // No gap

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No gap between exercises ',
                          style: settingsTextStyle),
                      Text(
                          (rl == null)
                              ? ''
                              : (rl.noGap != r.noGap)
                                  ? '*'
                                  : '',
                          style: starStyle),
                      Expanded(child: Container()),
                      Switch(
                        value: r.noGap,
                        onChanged: (val) {
                          setState(() {
                            r.noGap = val;
                          });
                        },
                      ),
                    ],
                  ),
                ] +

                // Exercise List

                _exerciseList(settings, cfg) +
                [
                  // Buttons

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () => _saveRoutine(context, cfg),
                            child: Text('Save')),
                        ElevatedButton(
                          onPressed: (rl == null)
                              ? null
                              : settings.routineDiffInLib(cfg) == false
                                  ? null
                                  : () => _loadDefault(cfg),
                          child: Text('Defaults', style: settingsTextStyle),
                        ),
                        ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.red),
                            onPressed: () => _deleteRoutine(context, cfg),
                            child: Text('Delete')),
                      ],
                    ),
                  ),
                ],
          ),
        ),
      ),
    );
  }

  void _loadDefault(String cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    Routine? rl = settings.getRoutineFromLib(cfg);

    if (rl == null) {
      showMsg(context, 'Routine \'$cfg\' does not exist in library!');
      return;
    }

    List<String> addedEx = [];
    for (int i = 0; i < rl.exercises.length; i++) {
      int index = settings.findParamIndex(rl.exercises[i].name);
      if (index == -1) {
        ConfigParam? ex = settings.getExerciseFromLib(rl.exercises[i].name);
        settings.cps.add(ex!);
        addedEx.add(ex.name);
      }
    }

    int pindex = settings.findRoutineIndex(cfg);

    settings.routines.removeAt(pindex);
    settings.routines.add(new Routine.fromJson(rl.toJson()));
    Navigator.pop(context);
    showMsg(
        context,
        'Routine \'$cfg\' reset to defaults from library.\n\n' +
            (addedEx.length > 0 ? 'Added exercises: $addedEx' : ''));
  }

  void _saveRoutine(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    int pindex = settings.findRoutineIndex(cfg);

    _formKey.currentState!.save();
    var values = _formKey.currentState!.value;

    String newName = values['routineName'];
    if (newName != settings.getRoutine(pindex).name) {
      if (settings.findRoutineIndex(newName) != -1) {
        showMsg(context,
            'The routine name \'$newName\' already exists, choose a different name!!');
        return;
      }
    }

    Routine r = settings.getRoutine(pindex);
    r.name = values['routineName'];
    Navigator.pop(context);
  }

  void _deleteRoutine(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    List<String> delEx = settings.removeRoutine(cfg);

    if (delEx.length > 0)
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(
              'Following exercises were only used in this routine:\n' +
                  delEx.map((e) => '  - $e').join('\n') +
                  '\n\nDo you want to delete these exercises too?'),
          title: Text('Message'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child:
                    Text('No, leave them in', style: TextStyle(fontSize: 10))),
            ElevatedButton(
                onPressed: () {
                  delEx.forEach((e) {
                    print('Removing $e');
                    settings.removeParam(e);
                  });
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Yes')),
          ],
        ),
        barrierDismissible: false,
      );
    else
      Navigator.pop(context);
  }

  void _addExercise(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    setState(() {
      var pindex = settings.findRoutineIndex(cfg);
      Routine cp = settings.getRoutine(pindex);
      cp.exercises
          .add(Exercise(settings.cps[0].name, settings.cps[0].rounds, true));
      settings.setRoutine(pindex, cp);
    });
  }

  void _deleteExercise(cfg, i) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    setState(() {
      int pindex = settings.findRoutineIndex(cfg);
      Routine r = settings.getRoutine(pindex);
      r.exercises.removeAt(i);
    });
  }

  List<Widget> _exerciseList(YogaSettings settings, String cfg) {
    List<Widget> list = [];
    int rindex = settings.findRoutineIndex(cfg);
    Routine r = settings.getRoutine(rindex);
    Routine? rl = settings.getRoutineFromLib(cfg);
    List<TextEditingController> _ctrlList = [];

    List<int> exTime = [];
    int totTime = 0;
    int totTimeInclGaps = 0;
    for (var i = 0; i < r.exercises.length; i++) {
      int exindex = settings.findParamIndex(r.exercises[i].name);
      ConfigParam ex = settings.getParam(exindex);
      int c = 0;
      for (int j = 0; j < ex.stages.length; j++) {
        c += ex.stages[j].count;
      }
      exTime
          .add(c * r.exercises[i].rounds * settings.getCountDuration() ~/ 1000);
      totTime += exTime[i];
      totTimeInclGaps += exTime[i] +
          ((!r.noGap & r.exercises[i].gapBefore)
              ? settings.getGapRoutine() + 6
              : 0) +
          3;
    }

    list.add(
      Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Exercises: ${r.exercises.length} ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
                (rl == null)
                    ? ''
                    : (rl.exercises.length != r.exercises.length)
                        ? '*'
                        : '',
                style: starStyle),
            Text(
              ' (${(totTime.toDouble() / 60).toStringAsFixed(1)} mins) ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
    list.add(Text(
      'Time including gaps: ${(totTimeInclGaps.toDouble() / 60).toStringAsFixed(1)} mins',
      style: TextStyle(fontSize: 12),
    ));
    list.add(SizedBox(height: 16));
    list.add(Text(
      'Long press and drag any row to reorder exercises',
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
    ));

    for (var i = 0; i < r.exercises.length; i++)
      _ctrlList
          .add(TextEditingController(text: r.exercises[i].rounds.toString()));

    List<Widget> elist = [];
    for (var i = 0; i < r.exercises.length; i++) {
      elist.add(
        Column(
          key: Key('$i'),
          children: [
            (i == 0) | r.noGap
                ? Container()
                : Card(
                    margin: EdgeInsets.fromLTRB(0, 8, kIsWeb ? 40 : 0, 0),
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: double.infinity,
                      //height: 25,
                      child: Row(
                        children: [
                          (r.exercises[i].gapBefore & !r.noGap)
                              ? Text(
                                  'Gap: ${settings.getGapRoutine()} seconds',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  'No Gap',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                          Expanded(child: Container()),
                          SizedBox(
                            child: GestureDetector(
                              onTap: () {
                                if (r.exercises[i].gapBefore == false) {
                                  setState(() {
                                    r.exercises[i].gapBefore = true;
                                  });
                                } else if (r.exercises[i].gapBefore == true) {
                                  setState(() {
                                    r.exercises[i].gapBefore = false;
                                  });
                                }
                              },
                              child: r.exercises[i].gapBefore
                                  ? Text(
                                      'Remove gap',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          decoration: TextDecoration.underline),
                                    )
                                  : Text(
                                      'Add gap',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButton<String>(
                          value: r.exercises[i].name,
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              if (newValue! != r.exercises[i].name) {
                                r.exercises[i].name = newValue;
                                ConfigParam ex = settings.getParam(
                                    settings.findParamIndex(newValue));
                                r.exercises[i].rounds = ex.rounds;
                                _ctrlList[i].text = ex.rounds.toString();
                              }
                            });
                          },
                          items: settings.cps
                              .map<DropdownMenuItem<String>>((ex) =>
                                  DropdownMenuItem<String>(
                                    value: ex.name,
                                    child:
                                        Text(ex.name, style: settingsTextStyle),
                                  ))
                              .toList()),
                      Text(
                        '${(exTime[i].toDouble() / 60).toStringAsFixed(1)} minutes',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                      (rl == null)
                          ? ''
                          : (rl.exercises.length <= i)
                              ? '+'
                              : (rl.exercises[i].name != r.exercises[i].name)
                                  ? '*'
                                  : '',
                      style: starStyle),
                ),
                Expanded(
                  flex: 10,
                  child: TextFormField(
                    controller: _ctrlList[i],
                    //initialValue: r.exercises[i].rounds.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9]+'))
                    ],
                    textAlign: TextAlign.center,
                    style: settingsTextStyle,
                    onChanged: (val) {
                      setState(() {
                        r.exercises[i].rounds = int.parse(val);
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                      (rl == null)
                          ? ''
                          : (rl.exercises.length <= i)
                              ? '+'
                              : (rl.exercises[i].rounds !=
                                      r.exercises[i].rounds)
                                  ? '*'
                                  : '',
                      style: starStyle),
                ),
                Expanded(
                  flex: 10,
                  child: r.exercises.length == 1
                      ? Container()
                      : IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _deleteExercise(cfg, i),
                        ),
                ),
                kIsWeb ? SizedBox(width: 40, child: Container()) : Container(),
              ],
            ),
          ],
        ),
      );
    }

    list.add(
      ReorderableListView(
        children: elist,
        shrinkWrap: true,
        onReorder: (int oldIndex, int newIndex) =>
            _reorder(oldIndex, newIndex, cfg),
      ),
    );

    list.add(
      Container(
        padding: EdgeInsets.all(16),
        child: CircleAvatar(
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addExercise(context, cfg),
            tooltip: 'Add Exercise',
          ),
        ),
      ),
    );

    return list;
  }

  void _reorder(int oldIndex, int newIndex, String cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    setState(() {
      var rindex = settings.findRoutineIndex(cfg);
      var routine = settings.getRoutine(rindex);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      var e = routine.exercises.removeAt(oldIndex);
      routine.exercises.insert(newIndex, e);
      //settings.setRoutine(pindex, routine);
    });
  }
}
