import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoga/pages/counter_page.dart';
import 'package:yoga/pages/edit_routine_page.dart';

import 'package:yoga/services/settings.dart';
import 'package:yoga/shared/constants.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({Key? key}) : super(key: key);

  @override
  _RoutinesPageState createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  int countPlus = 0;
  int countStar = 0;

  @override
  Widget build(BuildContext context) {
    countPlus = 0;
    countStar = 0;

    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return Stack(children: [
        _listRoutines(settings),
        Positioned(
          child: FloatingActionButton(
            onPressed: () {
              _showRoutinePicker();
            },
            child: Icon(Icons.add),
          ),
          bottom: 15,
          right: 15,
        )
      ]);
    });
  }

  Widget _routineTile(YogaSettings settings, int index) {
    Routine r = settings.getRoutine(index);
    int totTime = 0;
    for (int i = 0; i < r.exercises.length; i++) {
      int c = 0;
      ConfigParam ex =
          settings.getParam(settings.findParamIndex(r.exercises[i].name));
      for (int j = 0; j < ex.stages.length; j++) {
        c += ex.stages[j].count;
      }
      totTime +=
          c * r.exercises[i].rounds * settings.getCountDuration() ~/ 1000;
    }

    String annotation;
    if (settings.getRoutineFromLib(r.name) == null) {
      annotation = '+ ';
      countPlus += 1;
    } else if (settings.routineDiffInLib(r.name)) {
      annotation = '* ';
      countStar += 1;
    } else
      annotation = '';

    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Row(
          children: [
            Expanded(
              flex: 85,
              child: InkWell(
                onTap: () {
                  _routineSelected(context, r.name);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  decoration: boxDeco,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(annotation, style: starStyle),
                          Text(
                            r.name.length > 22
                                ? '${r.name.substring(0, 20)}...'
                                : '${r.name}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${r.exercises.length} exercises, ${totTime ~/ 60} minutes',
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  )),
                ),
              ),
            ),
            Expanded(flex: 3, child: Container()),
            Expanded(
              flex: 12,
              child: CircleAvatar(
                //radius: 25,
                child: IconButton(
                  onPressed: () {
                    _editRoutine(context, r.name);
                  },
                  icon: Icon(Icons.edit, size: 20),
                  tooltip: 'Edit config',
                ),
                backgroundColor: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ));
  }

  Widget _listRoutines(YogaSettings settings) {
    List<Widget> rlist = [];

    for (int i = 0; i < settings.routines.length; i++)
      rlist.add(_routineTile(settings, i));

    return SingleChildScrollView(
      child: Column(
        children: rlist +
            [
              (countStar + countPlus) == 0
                  ? Container()
                  : Card(
                      margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            countPlus == 0
                                ? Container()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('+ ', style: starStyle),
                                      Text('indicates a custom routine',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                            countStar == 0
                                ? Container()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('* ', style: starStyle),
                                      Text('indicates routine differs from lib',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
              SizedBox(height: 100)
            ],
      ),
    );
/*
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: settings.lengthRoutines(),
      itemBuilder: (BuildContext context, int index) =>
          _routineTile(settings, index),
      separatorBuilder: (BuildContext context, int index) =>
          Container(height: 20),
    );
    */
  }

  void _routineSelected(context, String routine) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return CounterPage(
          exercise: '',
          routine: routine,
        );
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
                          .getRoutineLibNotAdded()
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
                      'The routine \'$cfgName\' includes some new exercises:\n\n- ' +
                          npExercises.join('\n- ') +
                          '\n\nAdding these to your exercise list!!'),
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
