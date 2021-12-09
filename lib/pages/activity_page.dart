//import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fl_chart/fl_chart.dart';

import 'package:yoga/services/database.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/services/user_activity.dart';
import 'package:yoga/shared/constants.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 12,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              text.length < 24 ? text : text.substring(0, 20) + '...',
              style: TextStyle(
                  fontSize: this.size,
                  fontWeight: FontWeight.bold,
                  color: textColor),
            )
          ],
        ),
        SizedBox(height: 4)
      ],
    );
  }
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _totDays = 15;

  Future<List<UserActivity>> _activity() async {
    var settings = Provider.of<YogaSettings>(context);
    QuerySnapshot queryRef = await DBService(
            uid: settings.getUser().uid, email: settings.getUser().email)
        .getUserActivityDays(_totDays);
    return queryRef.docs
        .map((doc) => UserActivity.fromJson(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<YogaSettings>(context);

    return FutureBuilder<List<UserActivity>>(
        future: _activity(), // a previously-obtained Future<String> or null
        builder:
            (BuildContext context, AsyncSnapshot<List<UserActivity>> snapshot) {
          Widget ret;
          List<Widget> children = [];

          if (snapshot.hasData) {
            List<UserActivity> actList = snapshot.data!;

            DateTime now = DateTime.now();
            DateTime lastMidnight = DateTime(now.year, now.month, now.day);
            List<DateTime> days = [];
            for (int i = _totDays - 1; i >= 0; i--) {
              days.add(lastMidnight.subtract(Duration(days: i)));
            }

            Map<String, int> exMap = {};
            Map<DateTime, int> totMap = {};
            for (UserActivity act in actList) {
              var date =
                  DateTime(act.start.year, act.start.month, act.start.day);
              totMap[date] = (totMap[date] ?? 0) + act.duration;
              exMap[act.actName] = (exMap[act.actName] ?? 0) + act.duration;
            }

            int maxSlices = 7;
            List<Color> colorList = [
              Colors.green,
              Colors.blue,
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.amber,
              Colors.lime
            ];
            List<ExerciseData> exData = [];
            int totMins = 0;
            exMap.forEach((key, value) {
              int mins = (value + 30) ~/ 60;
              exData.add(ExerciseData(key, mins));
              totMins += mins;
            });
            exData.sort((a, b) => a.minutes.compareTo(b.minutes));
            exData = exData.reversed.toList();
            if (exData.length > maxSlices) {
              int otherMins = 0;
              for (int i = maxSlices - 1; i < exData.length; i++)
                otherMins += exData[i].minutes;
              exData = exData.sublist(0, maxSlices - 1);
              exData.add(ExerciseData('Others', otherMins));
            }
            // Now exData length is <= maxSlices
            for (int i = 0; i < exData.length; i++) {
              exData[i].color = colorList[i];
              exData[i].percent = exData[i].minutes * 100 ~/ totMins;
            }
            exData.forEach((element) {
              print(element);
            });

            List<ActData> data = [];
            List<double> timeList = [];
            for (DateTime day in days) {
              int minutes = totMap[day] ?? 0;
              minutes += 30;
              minutes ~/= 60;
              timeList.add(minutes.toDouble());
              data.add(ActData(day, minutes.toDouble()));
            }
            //print(data.map((d) => '${d.day}:${d.minutes}').toList());

            int totTime = totMap[lastMidnight] ?? 0;

            totTime += 30;
            totTime ~/= 60;
            int leftTime = settings.getDailyTarget() - totTime;
            var color;

            if (leftTime <= 0)
              color = Colors.green.withOpacity(0.8);
            else if (leftTime < totTime)
              color = Colors.amber.withOpacity(0.8);
            else
              color = Colors.red.withOpacity(0.8);

            int maxAct = 20;
            if (actList.length > maxAct) actList = actList.sublist(0, maxAct);

            actList.forEach((act) {
              children.add(Text(
                '${DateFormat("MMM-dd HH:mm").format(act.start)}: ${act.actName} for ${(act.duration / 60).toStringAsFixed(1)} mins',
                style: GoogleFonts.robotoMono(fontSize: 10),
              ));
            });

            ret = SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Today's minutes

                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                    decoration: boxDeco,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text('Today\'s minutes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              boxShadow: [
                                BoxShadow(
                                  color: color,
                                  blurRadius: 10.0,
                                  spreadRadius: 10.0,
                                ),
                              ]),
                          child: Center(
                            child: Text(
                              totTime.toString(),
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            (leftTime > 0)
                                ? '$leftTime minutes more to meet today\'s goal'
                                : 'Congrats, reached today\'s goal',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Weekly chart

                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                    decoration: boxDeco,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text('Last $_totDays days (minutes)',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          height: 150,
                          child: charts.TimeSeriesChart(
                            <charts.Series<ActData, DateTime>>[
                              charts.Series(
                                id: "Minutes",
                                data: data,
                                domainFn: (ActData s, _) => s.day,
                                measureFn: (ActData s, _) => s.minutes,
                                colorFn: (d, _) {
                                  if (d.minutes >= settings.getDailyTarget())
                                    return charts.Color(r: 0, b: 0, g: 0xff);
                                  else if (d.minutes >=
                                      settings.getDailyTarget() / 2)
                                    return charts.Color(r: 0xff, b: 0, g: 0xcc);
                                  else
                                    return charts.Color(r: 0xff, b: 0, g: 0);
                                },
                              ),
                            ],
                            animationDuration: Duration(seconds: 2),
                            animate: true,
                            defaultRenderer:
                                charts.BarRendererConfig<DateTime>(),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                              'Daily Target: ${settings.getDailyTarget()} minutes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  // Pie chart of exercises

                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                    decoration: boxDeco,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text('Last $_totDays days (exercises)',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: 160,
                                width: 160,
                                child: PieChart(
                                  PieChartData(
                                    sections: exData
                                        .map((e) => PieChartSectionData(
                                              value: e.minutes.toDouble(),
                                              title: e.percent.toString() + '%',
                                              radius: 40,
                                              color: e.color,
                                              titleStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ))
                                        .toList(),
                                    centerSpaceRadius: 20,
                                  ),
                                  swapAnimationDuration:
                                      Duration(seconds: 2), // Optional
                                  swapAnimationCurve: Curves.linear, // Optional
                                )),
                            SizedBox(width: 10),
                            Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: exData
                                    .map((e) => Indicator(
                                          text: e.exercise,
                                          color: e.color,
                                          isSquare: true,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Raw Activity Log

                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                    padding: EdgeInsets.all(20),
                    decoration: boxDeco,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text('Last $maxAct exercises',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: children,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            ret = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ]);
          } else {
            ret = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  )
                ]);
          }
          return ret;
        });
  }
}
