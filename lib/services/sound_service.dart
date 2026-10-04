import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Oyun ses efektlerini yönetir.
///
/// [AudioPlayer] havuzu kullanarak tick seslerini örtüşmeli çalar;
/// win sesini ayrı bir player ile çalar (örtüşme gerekmez).
///
/// Player'lar ilk ses çalınana kadar oluşturulmaz. Bu hem açılışı hafifletir
/// hem de sesi devre dışı bırakan alt sınıfların (testler) platform
/// kanalına hiç dokunmamasını sağlar.
class SoundService {
  static const String _kEnabled = 'sound_enabled';

  SharedPreferences? _prefs;

  /// Depolama açılamadıysa tercih en azından bu oturum boyunca tutulsun
  bool? _enabledThisSession;

  /// Kayıtlı tercihi okur; uygulama açılışında bir kez çağrılır. Çağrılmazsa
  /// ya da depolama açılamazsa ses açık kalır.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('SoundService: depolama açılamadı, ses tercihi saklanmaz ($e)');
    }
  }

  /// Ses efektleri çalınsın mı. Varsayılan açık; kullanıcı ayarlardan
  /// kapatabilir. Titreşim buna bağlı değil — onu controller tetikliyor.
  bool get enabled =>
      _enabledThisSession ?? _prefs?.getBool(_kEnabled) ?? true;

  Future<void> setEnabled(bool value) async {
    _enabledThisSession = value;
    await _prefs?.setBool(_kEnabled, value);
  }

  // Tick sesleri için 4 player'lı havuz — hızlı sıralamada ses kesilmez
  static const int _poolSize = 4;

  List<AudioPlayer>? _tickPool;
  AudioPlayer? _winPlayer;
  int _poolIndex = 0;
  Future<void>? _contextReady;

  /// Efektler arka planda çalan müziğe karışır ve iOS'ta sessiz anahtarına
  /// uyar. Paketin varsayılanı iOS'ta `playback` kategorisi ve Android'de
  /// ses odağı almak — ilk tik sesi kullanıcının müziğini durduruyordu.
  static final AudioContext _context = AudioContext(
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  /// Ses oturumunu ilk çalmadan önce bir kez ayarlar
  Future<void> _ensureContext() =>
      _contextReady ??= AudioPlayer.global.setAudioContext(_context);

  List<AudioPlayer> get _ticks => _tickPool ??=
      List.generate(_poolSize, (_) => AudioPlayer()..setVolume(0.6));

  AudioPlayer get _win => _winPlayer ??= AudioPlayer()..setVolume(0.9);

  /// Seçim döngüsündeki her highlight geçişinde çalınır
  Future<void> playTick() async {
    if (!enabled) return;
    await _ensureContext();
    final player = _ticks[_poolIndex % _poolSize];
    _poolIndex++;
    await player.play(AssetSource('sounds/tick.wav'));
  }

  /// Kazanan açıklandığında çalınır
  Future<void> playWin() async {
    if (!enabled) return;
    await _ensureContext();
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
