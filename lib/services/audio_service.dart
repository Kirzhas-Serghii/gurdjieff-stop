import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static AudioPlayer? _player;

  static const Map<String, String> soundFiles = {
    'bell': 'sounds/bell.wav',
    'tibetan_bowl': 'sounds/tibetan_bowl.wav',
    'soft_chime': 'sounds/soft_chime.wav',
    'gong': 'sounds/gong.wav',
    'wind_bell': 'sounds/wind_bell.wav',
  };

  static Future<void> play() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString('notificationMode') ?? 'both';

      if (mode == 'vibration') return;

      final selectedSound = prefs.getString('selectedSound') ?? 'bell';
      final volume = prefs.getDouble('volume') ?? 0.7;
      final fadeIn = prefs.getBool('fadeIn') ?? false;

      _player?.dispose();
      _player = AudioPlayer();

      final soundFile = soundFiles[selectedSound] ?? soundFiles['bell']!;

      await _player!.setVolume(fadeIn ? 0.0 : volume);
      await _player!.play(AssetSource(soundFile));

      if (fadeIn) {
        // Поступове збільшення гучності за 3 секунди
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 300));
          await _player!.setVolume(volume * i / 10);
        }
      }
    } catch (e) {
      // ignore audio errors
    }
  }

  static Future<void> stop() async {
    await _player?.stop();
    _player?.dispose();
    _player = null;
  }

  static Future<void> preview(String soundKey, double volume) async {
    try {
      _player?.dispose();
      _player = AudioPlayer();
      final soundFile = soundFiles[soundKey] ?? soundFiles['bell']!;
      await _player!.setVolume(volume);
      await _player!.play(AssetSource(soundFile));
    } catch (e) {
      // ignore
    }
  }
}
