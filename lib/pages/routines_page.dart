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
  @override
  Widget build(BuildContext context) {
    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: settings.lengthRoutines(),
        itemBuilder: (BuildContext context, int index) {
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

          return Row(
            children: [
              Expanded(
                flex: 85,
                child: InkWell(
                  onTap: () {
                    _routineSelected(context, r.name);
                  },
                  child: Container(
                    height: 50,
                    decoration: boxDeco,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${r.name}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                            '${r.exercises.length} exercises, ${totTime ~/ 60} minutes')
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
                      _editRoutine(context, r.name);
                    },
                    icon: Icon(Icons.edit),
                    tooltip: 'Edit config',
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
    });
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
