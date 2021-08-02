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
