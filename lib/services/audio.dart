import 'package:audioplayers/audioplayers.dart';

class AudioMusic {
  AudioCache player = AudioCache();
  var audioPlayer;
  bool audioInitialized = false;

  void initMusic() async {
    audioPlayer = await player.loop("audio/yoga.mp3");
    audioInitialized = true;
    //audioPlayer.setUrl("assets/audio/yoga.mp3");
    //audioPlayer.setReleaseMode(ReleaseMode.LOOP);
  }

  void startMusic() {
    if (!audioInitialized)
      initMusic();
    else
      audioPlayer.resume();
    print('Starting music');
  }

  void pauseMusic() {
    if (!audioInitialized) return;
    audioPlayer.pause();
    print('Pausing music');
  }
}
