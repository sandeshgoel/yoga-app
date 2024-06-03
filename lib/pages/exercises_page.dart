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
  int countPlus = 0;
  int countStar = 0;

  @override
  Widget build(BuildContext context) {
    countPlus = 0;
    countStar = 0;

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
              targetShapeBorder: CircleBorder(),
              targetPadding: EdgeInsets.all(8),
              //contentPadding: EdgeInsets.all(20),
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

  Widget _exerciseTile(YogaSettings settings, ConfigParam ex) {
    int c = 0;
    for (int j = 0; j < ex.stages.length; j++) {
      c += ex.stages[j].count;
    }
    int totTime = c * ex.rounds * settings.getCountDuration() ~/ 1000;

    String annotation;
    if (settings.getExerciseFromLib(ex.name) == null) {
      annotation = '+ ';
      countPlus += 1;
    } else if (settings.exerciseDiffInLib(ex.name)) {
      annotation = '* ';
      countStar += 1;
    } else
      annotation = '';

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        children: [
          Expanded(
            flex: 82,
            child: InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
                _exerciseSelected(context, ex.name);
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
                          ex.name.length > 22
                              ? '${ex.name.substring(0, 20)}...'
                              : '${ex.name}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                        '${ex.stages.length} stages, ${ex.rounds} rounds, ' +
                            (totTime > 59
                                ? '${(totTime + 30) ~/ 60} minutes'
                                : '$totTime seconds'),
                        style: TextStyle(fontSize: 10)),
                  ],
                )),
              ),
            ),
          ),
          Expanded(flex: 4, child: Container()),
          Expanded(
            flex: 10,
            child: CircleAvatar(
              //radius: 25,
              child: IconButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  _editExercise(context, ex.name);
                },
                icon: Icon(Icons.edit, size: 20),
                tooltip: 'Edit exercise',
                padding: EdgeInsets.zero,
              ),
              //backgroundColor: Colors.white.withOpacity(0.9),
            ),
          ),
          Expanded(flex: 4, child: Container()),
        ],
      ),
    );
  }

  List<Widget> _getExerciseList(YogaSettings settings, ExCategory cat) {
    List<Widget> exlist = [];
    List<ConfigParam> catlist =
        settings.cps.where((e) => e.category == cat).toList();

    for (int i = 0; i < catlist.length; i++)
      exlist.add(_exerciseTile(settings, catlist[i]));

    return exlist;
  }

  // size should be same as number of categories
  List<bool> expanded = [true, true, true];

  Widget _buildPanel(YogaSettings settings, ExCategory cat, int index) {
    String catName = cat.name;
    catName = catName[0].toUpperCase() + catName.substring(1);
    List<Widget> exlist = _getExerciseList(settings, cat);
    if (exlist.length == 0) return Container();

    if (!settings.getBrief()) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
        child: Column(
            children: <Widget>[
                  Card(
                    margin: EdgeInsets.fromLTRB(0, 0, 20, 15),
                    //margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 3,
                              color: Colors.grey,
                              indent: 10,
                              endIndent: 10,
                            ),
                          ),
                          Text(
                            catName + ' Exercises',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 3,
                              color: Colors.grey,
                              indent: 10,
                              endIndent: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] +
                exlist),
      );
    } else {
      ExpansionPanel ep = ExpansionPanel(
        canTapOnHeader: true,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(catName + ' Exercises (${exlist.length})',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          );
        },
        body: Column(
          children: exlist,
        ),
        isExpanded: expanded[index],
        //backgroundColor: Colors.white.withOpacity(1),
      );

      return Card(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
          child: ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.all(0),
              elevation: 0,
              expansionCallback: (_, bool isExpanded) {
                setState(() {
                  expanded[index] = !isExpanded;
                });
              },
              children: [ep]),
        ),
      );
    }
  }

  Widget _listExercises(YogaSettings settings) {
    List<Widget> elist = [];

    elist.add(_buildPanel(settings, ExCategory.breathing, 0));
    elist.add(_buildPanel(settings, ExCategory.sitting, 1));
    elist.add(_buildPanel(settings, ExCategory.standing, 2));

    return SingleChildScrollView(
      child: Column(
        children: elist +
            [
              (countPlus + countStar) == 0
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
                                      Text('indicates a custom exercise',
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
                                      Text(
                                          'indicates exercise differs from lib',
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
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      _createExerciseTile('Custom ...'),
                      SizedBox(height: 10),
                      Column(
                          children: settings
                              .getExerciseLibNotAdded()
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
