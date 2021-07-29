class UserActivity {
  late String uid;
  late String actName;
  late DateTime start;
  late int duration;

  UserActivity(String uid, String actName, DateTime start, int duration) {
    this.uid = uid;
    this.actName = actName;
    this.start = start;
    this.duration = duration;
  }

  UserActivity.fromJson(jval) {
    this.uid = jval['uid'];
    this.actName = jval['act_name'];
    this.start = jval['start'].toDate();
    this.duration = jval['duration'];
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': this.uid,
      'act_name': this.actName,
      'start': this.start,
      'duration': this.duration
    };
  }
}
