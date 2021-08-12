//import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:yoga/services/database.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/services/user_activity.dart';
import 'package:yoga/shared/constants.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _totDays = 15;

  Future<List<UserActivity>> _activity() async {
    var settings = Provider.of<YogaSettings>(context);
    QuerySnapshot queryRef = await DBService(uid: settings.getUser().uid)
        .getUserActivityDays(_totDays);
    return queryRef.docs.map((doc) => UserActivity.fromJson(doc)).toList();
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

            Map<DateTime, int> totMap = {};
            for (UserActivity act in actList) {
              var date =
                  DateTime(act.start.year, act.start.month, act.start.day);
              totMap[date] = (totMap[date] ?? 0) + act.duration;
            }

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
                          child: Text('Raw Activity Log',
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
