import 'package:flutter/material.dart';

var boxDeco = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(20)),
  color: Colors.white.withOpacity(0.6),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.8),
      offset: const Offset(3.0, 3.0),
      blurRadius: 5,
    ),
    BoxShadow(
      color: Colors.white,
      offset: const Offset(0.0, 0.0),
    ), //BoxSh
  ],
);

var textInputDeco2 = InputDecoration(
  fillColor: Colors.white.withOpacity(0.6),
  filled: true,
  enabledBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
  focusedBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
);

var textInputDeco = InputDecoration(
  fillColor: Colors.white.withOpacity(0.6),
  filled: true,
  focusedBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
);

var starStyle =
    TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold);

var settingsTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
var settingsTextStyleGrey =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey);

void showMsg(context, String msg) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: Text(msg),
      title: Text('Message'),
    ),
  );
}

String obfuscate(String s) {
  String r = '';

  for (int i = 0; i < s.length; i++)
    if (i % 2 == 1)
      r += '*';
    else
      r += s[i];

  return r;
}
