import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings.dart';
import 'pages/home_page.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Settings(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context, listen: false);
    settings.loadSettings();

    return MaterialApp(
      title: 'Yoga Assist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Yoga Assist'),
      debugShowCheckedModeBanner: false,
    );
  }
}
