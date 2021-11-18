import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:volume_control/volume_control.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/services/tts.dart';
import 'package:yoga/shared/constants.dart';

class EditSettingsPage extends StatefulWidget {
  const EditSettingsPage({Key? key}) : super(key: key);

  @override
  _EditSettingsPageState createState() => _EditSettingsPageState();
}

class _EditSettingsPageState extends State<EditSettingsPage> {
  final _settingsFormKey = new GlobalKey<FormBuilderState>();
  late YogaSettings _settings;
  late String dropdownValue;

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
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    dropdownValue = settings.getVoice();

    return SingleChildScrollView(
      child: Column(children: <Widget>[
        FormBuilder(
          key: _settingsFormKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Email and user name

                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    settings.getUser().email +
                        ', Verified: ' +
                        settings.getUser().verified.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: TextFormField(
                    initialValue: settings.getUser().name,
                    validator: (val) => val!.isNotEmpty ? null : 'Enter a name',
                    onChanged: (val) {
                      if (val != '')
                        settings.setUserName(val);
                      else
                        settings.setUserName(
                            settings.getUser().email.split('@')[0]);
                    },
                    decoration: textInputDeco.copyWith(hintText: 'Name'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                // Daily Target

                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Daily Target', style: settingsTextStyle),
                    _infoIcon(topicDailyTarget),
                    Expanded(child: Container()),
                    Text('${settings.getDailyTarget()} minutes'),
                  ],
                ),
                Slider(
                  value: settings.getDailyTarget().toDouble(),
                  min: 1,
                  max: 60,
                  divisions: 59,
                  onChanged: (val) {
                    setState(() {
                      settings.setDailyTarget(val.toInt());
                    });
                  },
                ),

                // Voice

                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Voice:', style: settingsTextStyle),
                      _infoIcon(topicVoice),
                      IconButton(
                        icon: Icon(Icons.volume_down_sharp, size: 15),
                        onPressed: () => _playVoiceSample(settings),
                      ),
                      Expanded(child: Container()),
                      DropdownButton<String>(
                        value: dropdownValue,
                        //isExpanded: true,
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
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: TextStyle(fontSize: 10),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Speech Rate

                Row(
                  children: [
                    Text(
                      settings.getSpeechRate() == settings.defSpeechRate
                          ? ''
                          : '* ',
                      style: starStyle,
                    ),
                    Text('Speech Rate', style: settingsTextStyle),
                    _infoIcon(topicSpeechRate),
                    Expanded(child: Container()),
                    Text('${settings.getSpeechRate()}'),
                  ],
                ),
                Slider(
                  value: settings.getSpeechRate(),
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: (val) {
                    setState(() {
                      settings.setSpeechRate(val);
                    });
                  },
                ),

                // Speech Volume

                Row(
                  children: [
                    Text(
                      settings.getSpeechVolume() == settings.defSpeechVolume
                          ? ''
                          : '* ',
                      style: starStyle,
                    ),
                    Text('Speech Volume', style: settingsTextStyle),
                    _infoIcon(topicSpeechVolume),
                    Expanded(child: Container()),
                    Text('${settings.getSpeechVolume()}'),
                  ],
                ),
                Slider(
                  value: settings.getSpeechVolume(),
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: (val) {
                    setState(() {
                      settings.setSpeechVolume(val);
                      VolumeControl.setVolume(settings.getSpeechVolume());
                    });
                  },
                ),

                // Music On

                Row(
                  children: [
                    Text(
                      settings.getMusic() == settings.defMusic ? '' : '* ',
                      style: starStyle,
                    ),
                    Text('Music On', style: settingsTextStyle),
                    _infoIcon(topicMusic),
                    Expanded(
                      child: Container(),
                    ),
                    Switch(
                      value: settings.getMusic(),
                      onChanged: (val) {
                        setState(() {
                          settings.setMusic(val);
                        });
                      },
                    ),
                  ],
                ),

                // Mute Counting

                Row(
                  children: [
                    Text(
                      settings.getMuteCounting() == settings.defMuteCounting
                          ? ''
                          : '* ',
                      style: starStyle,
                    ),
                    Text('Mute Counting', style: settingsTextStyle),
                    _infoIcon(topicMuteCounting),
                    Expanded(
                      child: Container(),
                    ),
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

                // Count Duration Slider

                Row(
                  children: [
                    Text(
                      settings.getCountDuration() == settings.defCountDuration
                          ? ''
                          : '* ',
                      style: starStyle,
                    ),
                    Text('Count Duration', style: settingsTextStyle),
                    _infoIcon(topicCountDur),
                    Expanded(child: Container()),
                    Text('${settings.getCountDuration() / 1000} seconds'),
                  ],
                ),
                Slider(
                  value: settings.getCountDuration().toDouble() / 1000,
                  min: 1,
                  max: 3,
                  divisions: 20,
                  onChanged: (val) {
                    setState(() {
                      settings.setCountDuration((val * 1000).toInt());
                    });
                  },
                ),

                // Gap routine

                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      settings.getGapRoutine() == settings.defGapRoutine
                          ? ''
                          : '* ',
                      style: starStyle,
                    ),
                    Text('Gap between exercises', style: settingsTextStyle),
                    _infoIcon(topicGapRoutine),
                    Expanded(child: Container()),
                    Text('${settings.getGapRoutine()} seconds'),
                  ],
                ),
                Slider(
                  value: settings.getGapRoutine().toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  onChanged: (val) {
                    setState(() {
                      settings.setGapRoutine(val.toInt());
                    });
                  },
                ),

                // Notify

                Row(
                  children: [
                    Text(
                      settings.getNotify() == settings.defNotify ? '' : '* ',
                      style: starStyle,
                    ),
                    Text('Daily Notifications', style: settingsTextStyle),
                    _infoIcon(topicNotify),
                    Expanded(
                      child: Container(),
                    ),
                    Switch(
                      value: settings.getNotify(),
                      onChanged: (val) {
                        setState(() {
                          settings.setNotify(val);
                        });
                      },
                    ),
                  ],
                ),

                // Reset to defaults

                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: settings.allDefaults()
                        ? null
                        : () {
                            settings.setSpeechRate(settings.defSpeechRate);
                            settings.setSpeechVolume(settings.defSpeechVolume);
                            settings.setMuteCounting(settings.defMuteCounting);
                            settings
                                .setCountDuration(settings.defCountDuration);
                            settings.setGapRoutine(settings.defGapRoutine);
                            settings.setNotify(settings.defNotify);
                            settings.setMusic(settings.defMusic);
                            Navigator.pop(context);
                          },
                    child: Text('Defaults')),
                SizedBox(height: 20),
              ],
            ),
          ),
        )
      ]),
    );
  }

  void _playVoiceSample(settings) async {
    Tts _tts = Tts();
    _tts.setSpeechRate(settings.getSpeechRate());
    _tts.setSpeechVoice(settings.getVoice());

    String msg = 'Voice Test. Inhale and exhale';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: Duration(milliseconds: 2000),
    ));

    await _tts.speak(context, msg);
  }

  static const String topicVoice = 'voice';
  static const String topicMuteCounting = 'mute_counting';
  static const String topicCountDur = 'count_duration';
  static const String topicSpeechRate = 'speech_rate';
  static const String topicSpeechVolume = 'speech_volume';
  static const String topicDailyTarget = 'daily_target';
  static const String topicGapRoutine = 'gap_routine';
  static const String topicNotify = 'notify';
  static const String topicMusic = 'music';

  Widget _infoIcon(String topic) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    String msg = '';
    switch (topic) {
      case topicVoice:
        msg = 'This selects the voice which you hear during the exercises';
        break;
      case topicMuteCounting:
        msg =
            'Disable or enable the announcement of round number and count within the round';
        break;
      case topicCountDur:
        msg =
            'Count duration is the gap between each count during an exercise.\n\nDefault value is ${settings.defCountDuration / 1000} seconds';
        break;
      case topicSpeechRate:
        msg =
            'Speech rate determines how fast or slow the speaker is talking.\n\nDefault value is ${settings.defSpeechRate}';
        break;
      case topicSpeechVolume:
        msg =
            'Speech volume is the default volume level when the app is started.\n\nDefault value is ${settings.defSpeechVolume}';
        break;
      case topicDailyTarget:
        msg =
            'Daily target is the number of minutes you aim to spend exercising each day';
        break;
      case topicGapRoutine:
        msg =
            'This is the gap between exercises during a routine consisting of multiple exercises.\n\nDefault value is ${settings.defGapRoutine}';
        break;
      case topicNotify:
        msg = 'Enable or disable daily notifications';
        break;
      case topicMusic:
        msg = 'Turn background music on or off';
        break;
      default:
    }
    return IconButton(
      icon: Icon(Icons.help_outline, size: 15),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(msg),
            title: Text('Information'),
          ),
        );
      },
    );
  }
}
