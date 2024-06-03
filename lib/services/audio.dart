import 'package:audioplayers/audioplayers.dart';

class AudioMusic {
  AudioCache player = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();
  bool audioInitialized = false;

  void initMusic() async {
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource("audio/yoga.mp3"));
    audioInitialized = true;
    //audioPlayer.setUrl("assets/audio/yoga.mp3");
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
