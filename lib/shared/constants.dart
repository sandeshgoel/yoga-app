import 'package:flutter/material.dart';

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
