import 'package:audioplayers/audioplayers.dart';

/// Oyun ses efektlerini yönetir.
///
/// [AudioPlayer] havuzu kullanarak tick seslerini örtüşmeli çalar;
/// win sesini ayrı bir player ile çalar (örtüşme gerekmez).
class SoundService {
  // Tick sesleri için 4 player'lı havuz — hızlı sıralamada ses kesilmez
  static const int _poolSize = 4;
  final List<AudioPlayer> _tickPool =
      List.generate(_poolSize, (_) => AudioPlayer());
  int _poolIndex = 0;

  final AudioPlayer _winPlayer = AudioPlayer();

  SoundService() {
    // Tüm player'ların volume'unu ayarla
    for (final p in _tickPool) {
      p.setVolume(0.6);
    }
    _winPlayer.setVolume(0.9);
  }

  /// Seçim döngüsündeki her highlight geçişinde çalınır
  Future<void> playTick() async {
    final player = _tickPool[_poolIndex % _poolSize];
    _poolIndex++;
    await player.play(AssetSource('sounds/tick.wav'));
  }

  /// Kazanan açıklandığında çalınır
  Future<void> playWin() async {
    await _winPlayer.play(AssetSource('sounds/win.wav'));
  }

  /// Kaynakları serbest bırakır
  Future<void> dispose() async {
    for (final p in _tickPool) {
      await p.dispose();
    }
    await _winPlayer.dispose();
  }
}
