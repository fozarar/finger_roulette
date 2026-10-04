import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/name_list.dart';

/// Kullanıcının yazdığı isim listelerini cihazda saklar.
///
/// Amaç tekrar eden gruplar: aynı kadro her hafta yeniden yazılmasın.
/// Listeler cihazdan hiç çıkmaz ve uygulama silinince onlar da gider.
///
/// [StatsService] gibi, depolama açılamazsa sessizce devre dışı kalır —
/// isimler o oturum boyunca yaşar, çark yine çevrilir.
class NamesService {
  /// 1.2 ve öncesinin tek listesi; yalnızca ilk açılışta taşımak için okunur
  static const String _kLegacyNames = 'names_list';

  static const String _kLists = 'names_lists';
  static const String _kActive = 'names_active_list';

  /// Çarkın okunabilir kaldığı üst sınır
  static const int maxNames = 20;

  /// Liste sekmelerinin taranabilir kaldığı üst sınır
  static const int maxLists = 8;

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

  /// Saklanan listeler; hiç yazılmadıysa tek bir boş liste.
  ///
  /// Eski sürümden gelen tek liste kaybolmaz: yeni kayıt yoksa o liste ilk
  /// liste olarak döner ve ilk [save] ile yeni biçime geçer.
  NameBook load() {
    final prefs = _prefs;
    if (prefs == null) return const NameBook();

    final raw = prefs.getString(_kLists);
    if (raw == null) {
      final legacy = prefs.getStringList(_kLegacyNames);
      if (legacy == null || legacy.isEmpty) return const NameBook();
      return NameBook(lists: [NameList(names: legacy)]);
    }

    try {
      final decoded = jsonDecode(raw);
      final lists = decoded is List
          ? decoded.map(NameList.fromJson).take(maxLists).toList()
          : <NameList>[];
      if (lists.isEmpty) return const NameBook();
      final active = prefs.getInt(_kActive) ?? 0;
      return NameBook(
        lists: lists,
        active: active.clamp(0, lists.length - 1).toInt(),
      );
    } catch (e) {
      debugPrint('NamesService: listeler okunamadı, boş başlanıyor ($e)');
      return const NameBook();
    }
  }

  /// Listeleri diske yazar. Hata olursa sessizce geçer — isim kaydedilememesi
  /// oyunu durdurmamalı.
  Future<void> save(NameBook book) async {
    try {
      await _prefs?.setString(
        _kLists,
        jsonEncode([for (final list in book.lists) list.toJson()]),
      );
      await _prefs?.setInt(_kActive, book.active);
    } catch (e) {
      debugPrint('NamesService: isimler yazılamadı ($e)');
    }
  }
}
