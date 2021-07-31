import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/shared/constants.dart';

class EditSettingsPage extends StatefulWidget {
  const EditSettingsPage({Key? key}) : super(key: key);

  @override
  _EditSettingsPageState createState() => _EditSettingsPageState();
}

class _EditSettingsPageState extends State<EditSettingsPage> {
  final _settingsFormKey = new GlobalKey<FormBuilderState>();

  late YogaSettings _settings;

  @override
  void didChangeDependencies() {
    _settings = Provider.of<YogaSettings>(context, listen: false);
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg-blue.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _editSettingsPage(),
        ],
      ),
    );
  }

  Widget _editSettingsPage() {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    return SingleChildScrollView(
      child: Column(children: <Widget>[
        FormBuilder(
          key: _settingsFormKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Text(
                  settings.email,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: TextFormField(
                  initialValue: settings.getName(),
                  validator: (val) => val!.isNotEmpty ? null : 'Enter a name',
                  onChanged: (val) {
                    if (val != '')
                      settings.setName(val);
                    else
                      settings.setName(settings.email.split('@')[0]);
                  },
                  decoration: textInputDeco.copyWith(hintText: 'Name'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: FormBuilderSlider(
                  name: 'duration',
                  initialValue: settings.getCountDuration().toDouble() / 1000,
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
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: FormBuilderSlider(
                  name: 'speech_rate',
                  initialValue: settings.getSpeechRate(),
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
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: FormBuilderSlider(
                  name: 'daily_target',
                  initialValue: settings.getDailyTarget().toDouble(),
                  min: 1,
                  max: 60,
                  divisions: 59,
                  decoration: InputDecoration(
                    labelText: 'Daily Target (minutes)',
                  ),
                  onChanged: (value) {
                    settings.setDailyTarget(value!.toInt());
                  },
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
