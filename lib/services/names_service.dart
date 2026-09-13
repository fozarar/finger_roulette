import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcının yazdığı isim listesini cihazda saklar.
///
/// Amaç tekrar eden gruplar: aynı kadro her hafta yeniden yazılmasın.
/// Liste cihazdan hiç çıkmaz ve uygulama silinince o da gider.
///
/// [StatsService] gibi, depolama açılamazsa sessizce devre dışı kalır —
/// isimler o oturum boyunca yaşar, çark yine çevrilir.
class NamesService {
  static const String _kNames = 'names_list';

  /// Çarkın okunabilir kaldığı üst sınır
  static const int maxNames = 20;

  SharedPreferences? _prefs;

  /// Uygulama açılışında bir kez çağrılır
  Future<void> init() async {
    try {
      // Timeout: depolama takılırsa splash'te sonsuza dek asılı kalmayalım
      _prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('NamesService: depolama açılamadı, isimler saklanmıyor ($e)');
    }
  }

  /// Saklanan isimler; hiç yazılmadıysa boş liste
  List<String> load() => _prefs?.getStringList(_kNames) ?? const [];

  /// Listeyi diske yazar. Hata olursa sessizce geçer — isim kaydedilememesi
  /// oyunu durdurmamalı.
  Future<void> save(List<String> names) async {
    try {
      await _prefs?.setStringList(_kNames, names);
    } catch (e) {
      debugPrint('NamesService: isimler yazılamadı ($e)');
    }
  }
}
