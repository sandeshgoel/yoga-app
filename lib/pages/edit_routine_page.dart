import 'package:flutter/material.dart';
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
              image: DecorationImage(
                image: AssetImage("assets/images/bg-blue.jpeg"),
                fit: BoxFit.cover,
              ),
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

    return FormBuilder(
      key: _formKey,
      child: ListView(
        children: <Widget>[
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: FormBuilderTextField(
                    name: 'routineName',
                    initialValue: cfg,
                    decoration: InputDecoration(
                      labelText: 'Routine Name',
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ] +
            _exerciseList(settings, cfg) +
            [
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
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () => _deleteRoutine(context, cfg),
                          child: Text('Delete')),
                    ],
                  )),
            ],
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

    int pindex = settings.findRoutineIndex(cfg);

    settings.routines.removeAt(pindex);
    settings.routines.add(new Routine.fromJson(rl.toJson()));
    Navigator.pop(context);
    showMsg(context, 'Routine \'$cfg\' reset to defaults from library');
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

    Routine cp = settings.getRoutine(pindex);
    cp.name = values['routineName'];
    for (var i = 0; i < cp.exercises.length; i++) {
      String exName = values['name' + i.toString()];
      int exIndex = settings.findParamIndex(exName);
      if (exIndex == -1) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
                'The exercise \'$exName\' doesn\'t exist, you can choose from existing exercises only!!'),
            title: Text('ERROR'),
          ),
        );
        return;
      }
      cp.exercises[i].name = exName;
      cp.exercises[i].rounds = int.parse(values['rounds' + i.toString()]);
    }
    settings.setRoutine(pindex, cp);

    Navigator.pop(context);
  }

  void _deleteRoutine(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    settings.removeRoutine(cfg);
    Navigator.pop(context);
  }

  void _addExercise(context, cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    setState(() {
      var pindex = settings.findRoutineIndex(cfg);
      Routine cp = settings.getRoutine(pindex);
      cp.exercises.add(Exercise(settings.cps[0].name, 10));
      settings.setRoutine(pindex, cp);
    });
  }

  Exercise _deleteExercise(cfg, i) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    var e;

    setState(() {
      var pindex = settings.findRoutineIndex(cfg);
      Routine cp = settings.getRoutine(pindex);
      e = cp.exercises.removeAt(i);
      settings.setRoutine(pindex, cp);
    });
    return e;
  }

  List<Widget> _exerciseList(YogaSettings settings, String cfg) {
    List<Widget> list = [];
    int pindex = settings.findRoutineIndex(cfg);
    Routine r = settings.getRoutine(pindex);
    Routine? rl = settings.getRoutineFromLib(cfg);

    list.add(Container(
        padding: EdgeInsets.all(16),
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
          ],
        )));

    List<Widget> elist = [];
    for (var i = 0; i < r.exercises.length; i++) {
      elist.add(
        Row(
          key: Key('$i'),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(flex: 5, child: Container()),
/*            Expanded(
              flex: 10,
              child: IconButton(
                icon: Icon(Icons.drag_handle),
                onPressed: () => {},
              ),
            ),*/
            Expanded(flex: 5, child: Container()),
            Expanded(
              flex: 50,
              child: FormBuilderDropdown(
                name: 'name$i',
                initialValue: r.exercises[i].name,
                items: settings.cps
                    .map<DropdownMenuItem<String>>((ex) =>
                        DropdownMenuItem<String>(
                          value: ex.name,
                          child: Text(ex.name,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ))
                    .toList(),
              ),
            ),
            Expanded(
              flex: 10,
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
              child: FormBuilderTextField(
                name: 'rounds$i',
                initialValue: r.exercises[i].rounds.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                  (rl == null)
                      ? ''
                      : (rl.exercises.length <= i)
                          ? '+'
                          : (rl.exercises[i].rounds != r.exercises[i].rounds)
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
            Expanded(flex: 5, child: Container()),
          ],
        ),
      );
    }

    list.add(ReorderableListView.builder(
        itemBuilder: (_, i) {
          return elist[i];
        },
        itemCount: elist.length,
        //children: elist,
        shrinkWrap: true,
        onReorder: (int oldIndex, int newIndex) => {}
//          _reorder(oldIndex, newIndex, cfg),
        ));

    list.add(Container(
      padding: EdgeInsets.all(16),
      child: CircleAvatar(
        child: IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _addExercise(context, cfg),
          tooltip: 'Add Exercise',
        ),
      ),
    ));

    return list;
  }
/*
  void _reorder(int oldIndex, int newIndex, String cfg) {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    setState(() {
      var pindex = settings.findRoutineIndex(cfg);
      var routine = settings.getRoutine(pindex);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      var e = routine.exercises.removeAt(oldIndex);
      routine.exercises.insert(newIndex, e);
      settings.setRoutine(pindex, routine);
    });
  }*/
}
