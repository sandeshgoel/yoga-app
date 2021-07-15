import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yoga/settings.dart';

class EditSettingsPage extends StatefulWidget {
  const EditSettingsPage({Key? key}) : super(key: key);

  @override
  _EditSettingsPageState createState() => _EditSettingsPageState();
}

class _EditSettingsPageState extends State<EditSettingsPage> {
  final _settingsFormKey = new GlobalKey<FormBuilderState>();

  late Settings _settings;

  @override
  void didChangeDependencies() {
    _settings = Provider.of<Settings>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _settings.saveSettings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: _editSettingsPage(),
    );
  }

  Widget _editSettingsPage() {
    var settings = Provider.of<Settings>(context, listen: false);

    return Column(children: <Widget>[
      FormBuilder(
        key: _settingsFormKey,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: FormBuilderSlider(
                name: 'duration',
                initialValue: settings.countDuration.toDouble() / 1000,
                min: 1,
                max: 3,
                divisions: 20,
                decoration: InputDecoration(
                  labelText: 'Count Duration (seconds)',
                ),
                onChanged: (value) {
                  settings.setCountDuration((value! * 1000).toInt());
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: FormBuilderSlider(
                name: 'speech_rate',
                initialValue: settings.speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                decoration: InputDecoration(
                  labelText: 'Speech Rate',
                ),
                onChanged: (value) {
                  settings.setSpeechRate(value!.toDouble());
                },
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
