import 'package:audioplayers/audioplayers.dart';

/// Oyun ses efektlerini yönetir.
///
/// [AudioPlayer] havuzu kullanarak tick seslerini örtüşmeli çalar;
/// win sesini ayrı bir player ile çalar (örtüşme gerekmez).
///
/// Player'lar ilk ses çalınana kadar oluşturulmaz. Bu hem açılışı hafifletir
/// hem de sesi devre dışı bırakan alt sınıfların (testler) platform
/// kanalına hiç dokunmamasını sağlar.
class SoundService {
  // Tick sesleri için 4 player'lı havuz — hızlı sıralamada ses kesilmez
  static const int _poolSize = 4;

  List<AudioPlayer>? _tickPool;
  AudioPlayer? _winPlayer;
  int _poolIndex = 0;

  List<AudioPlayer> get _ticks => _tickPool ??=
      List.generate(_poolSize, (_) => AudioPlayer()..setVolume(0.6));

  AudioPlayer get _win => _winPlayer ??= AudioPlayer()..setVolume(0.9);

  /// Seçim döngüsündeki her highlight geçişinde çalınır
  Future<void> playTick() async {
    final player = _ticks[_poolIndex % _poolSize];
    _poolIndex++;
    await player.play(AssetSource('sounds/tick.wav'));
  }

  /// Kazanan açıklandığında çalınır
  Future<void> playWin() async {
    await _win.play(AssetSource('sounds/win.wav'));
  }

  /// Kaynakları serbest bırakır — hiç ses çalınmadıysa yapacak iş yoktur
  Future<void> dispose() async {
    for (final p in _tickPool ?? const <AudioPlayer>[]) {
      await p.dispose();
    }
    await _winPlayer?.dispose();
    _tickPool = null;
    _winPlayer = null;
  }
}
