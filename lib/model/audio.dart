import 'package:just_audio/just_audio.dart';

class Audio {
  static final AudioPlayer audioPlayer = AudioPlayer();

  /// Initialization.  We pre-load all sounds.
  static final items = [
    AudioSource.uri(Uri.parse("asset:///assets/audio/swap.wav")),
    AudioSource.uri(Uri.parse("asset:///assets/audio/move_down.wav")),
    AudioSource.uri(Uri.parse("asset:///assets/audio/bomb.wav")),
    AudioSource.uri(Uri.parse("asset:///assets/audio/game_start.wav")),
    AudioSource.uri(Uri.parse("asset:///assets/audio/win.wav")),
    AudioSource.uri(Uri.parse("asset:///assets/audio/lost.wav")),
  ];

  static playAsset(AudioType audioType) async {
    try {
      switch (audioType) {
        case AudioType.swap:
          await audioPlayer.setAudioSource(items[0]);
          audioPlayer.play();
          break;
        case AudioType.moveDown:
          await audioPlayer.setAudioSource(items[1]);
          audioPlayer.play();
          break;
        case AudioType.bomb:
          await audioPlayer.setAudioSource(items[2]);
          audioPlayer.play();
          break;
        case AudioType.gameStart:
          await audioPlayer.setAudioSource(items[3]);
          audioPlayer.play();
          break;
        case AudioType.win:
          await audioPlayer.setAudioSource(items[4]);
          audioPlayer.play();
          break;
        case AudioType.lost:
          await audioPlayer.setAudioSource(items[5]);
          audioPlayer.play();
          break;
      }
    } catch (e, stack) {
      // Gestione silenziosa o log dell'errore
      // debugPrint('Audio error: $e');
    }
  }
}

enum AudioType {
  swap,
  moveDown,
  bomb,
  gameStart,
  win,
  lost,
}
