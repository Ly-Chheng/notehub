import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playTimerSound(String fileName) async {
    await _player.stop();
    await _player.play(AssetSource('sounds/$fileName'));
  }

  static Future<void> stopSound() async {
    await _player.stop();
  }
}
