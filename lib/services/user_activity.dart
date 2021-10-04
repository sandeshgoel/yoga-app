import 'package:flutter/material.dart';

class UserActivity {
  late String uid;
  late String email;
  late String actName;
  late DateTime start;
  late int duration;
  late int rounds;
  late String routine;

  UserActivity(String uid, String email, String actName, DateTime start,
      int duration, int rounds, String routine) {
    this.uid = uid;
    this.email = email;
    this.actName = actName;
    this.start = start;
    this.duration = duration;
    this.rounds = rounds;
    this.routine = routine;
  }

  UserActivity.fromJson(jval) {
    this.uid = jval['uid'];
    this.email = jval['email'] ?? '';
    this.actName = jval['act_name'];
    this.start = jval['start'].toDate();
    this.duration = jval['duration'];
    this.rounds = jval['rounds'] ?? 0;
    this.routine = jval['routine'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': this.uid,
      'email': this.email,
      'act_name': this.actName,
      'start': this.start,
      'duration': this.duration,
      'rounds': this.rounds,
      'routine': this.routine
    };
  }
}

class ActData {
  final DateTime day;
  final double minutes;

  ActData(this.day, this.minutes);
}

class ExerciseData {
  final String exercise;
  final int minutes;
  Color color;
  late int percent;

  ExerciseData(this.exercise, this.minutes, {this.color = Colors.blue});

  @override
  String toString() {
    return '${this.exercise},${this.minutes}';
  }
}

class Friend {
  late String from;
  late String to;
  late String status;

  Friend(String from, String to, String status) {
    this.from = from;
    this.to = to;
    this.status = status;
  }

  Friend.fromJson(jval) {
    this.from = jval['from'];
    this.to = jval['to'];
    this.status = jval['status'];
  }

  Map<String, dynamic> toJson() {
    return {
      'from': this.from,
      'to': this.to,
      'status': this.status,
    };
  }
}
