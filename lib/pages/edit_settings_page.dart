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
  String dropdownValue = '';

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
    dropdownValue = settings.getVoice();

    return SingleChildScrollView(
      child: Column(children: <Widget>[
        FormBuilder(
          key: _settingsFormKey,
          child: Column(
            children: [
              // Email and user name

              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Text(
                  settings.getEmail() + ' ' + settings.getVerified().toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                child: TextFormField(
                  initialValue: settings.getName(),
                  validator: (val) => val!.isNotEmpty ? null : 'Enter a name',
                  onChanged: (val) {
                    if (val != '')
                      settings.setName(val);
                    else
                      settings.setName(settings.getEmail().split('@')[0]);
                  },
                  decoration: textInputDeco.copyWith(hintText: 'Name'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              // Voice

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Voice:    ', style: TextStyle(fontSize: 14)),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,

                    //style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                        settings.setVoice(newValue);
                      });
                    },
                    items: settings
                        .getVoices()
                        .asMap()
                        .entries
                        .map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.value,
                        child: Text('${entry.key}: ${entry.value}'),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Mute Counting

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Mute Counting       '),
                  Switch(
                    value: settings.getMuteCounting(),
                    onChanged: (val) {
                      setState(() {
                        settings.setMuteCounting(val);
                      });
                    },
                  ),
                ],
              ),

              // Count Duration

              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
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

              // Speech Rate

              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
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

              // Daily Target

              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
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

              // Gap routine

              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                child: FormBuilderSlider(
                  name: 'gap_routine',
                  initialValue: settings.getGapRoutine().toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  decoration: InputDecoration(
                    labelText: 'Gap between exercises (seconds)',
                  ),
                  onChanged: (value) {
                    settings.setGapRoutine(value!.toInt());
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
