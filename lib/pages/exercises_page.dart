import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:yoga/pages/counter_page.dart';
import 'package:yoga/pages/edit_exercise_page.dart';

import 'package:yoga/services/settings.dart';
import 'package:yoga/shared/constants.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({Key? key}) : super(key: key);

  @override
  _ExercisesPageState createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final _skey1 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return Stack(
        children: [
          _listExercises(settings),
          Positioned(
            child: Showcase(
              key: _skey1,
              description:
                  'Add exercise from a list of pre-defined exercises, ' +
                      'or define a custom exercise',
              shapeBorder: CircleBorder(),
              overlayPadding: EdgeInsets.all(8),
              contentPadding: EdgeInsets.all(20),
              child: FloatingActionButton(
                onPressed: () {
                  _showExercisePicker();
                },
                child: Icon(Icons.add),
              ),
            ),
            bottom: 15,
            right: 15,
          )
        ],
      );
    });
  }

  // -----------------------------------------------------

  Widget _listExercises(settings) {
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
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _exerciseSelected(context, cp.name);
                },
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
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    _editExercise(context, cp.name);
                  },
                  icon: Icon(Icons.edit),
                  tooltip: 'Edit exercise',
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
  }

  Widget _createExerciseTile(String name) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _addExercise(context, name);
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

  void _addExercise(context, String cfgName) {
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
      settings.addParam(new ConfigParam(
          cfgName, ExCategory.breathing, 10, [Stage('Stagename', 4)]));
    } else {
      settings.addParam(settings.getExerciseFromLib(cfgName)!);
    }

    _editExercise(context, cfgName);
  }

  void _exerciseSelected(context, String cfg) {
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

  void _editExercise(context, String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditConfigPage(cfg: cfg);
      }),
    ).then((value) {
      setState(() {});
    });
  }
}
