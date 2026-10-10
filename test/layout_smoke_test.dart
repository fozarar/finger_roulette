import 'package:finger_roulette/app/app.dart';
import 'package:finger_roulette/app/tablet_scale.dart';
import 'package:finger_roulette/models/name_list.dart';
import 'package:finger_roulette/services/names_service.dart';
import 'package:finger_roulette/services/review_service.dart';
import 'package:finger_roulette/services/sound_service.dart';
import 'package:finger_roulette/services/stats_service.dart';
import 'package:finger_roulette/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Platform kanalına dokunmayan ses servisi
class _SilentSound extends SoundService {
  @override
  Future<void> playTick() async {}
  @override
  Future<void> playWin() async {}
  @override
  Future<void> dispose() async {}
}

/// Diske gitmeyen, sekiz isimle dolu gelen isim deposu: dört takıma yetiyor
class _FakeNames extends NamesService {
  NameBook book = const NameBook(
    lists: [
      NameList(
        names: ['Alex', 'Sam', 'Mia', 'Leo', 'Zoe', 'Max', 'Ava', 'Eli'],
      ),
    ],
  );

  @override
  NameBook load() => book;

  @override
  Future<void> save(NameBook book) async => this.book = book;
}

/// Bir satır ya da sütun taşarsa Flutter hata fırlatır ve test düşer; burada
/// ayrıca bir şey beklemeye gerek yok. Amaç her ekranı, desteklenen en küçük
/// telefondan yatay duran en büyük iPad'e kadar bir kez çizdirmek.
const _screens = {
  'iPhone SE (1. nesil)': Size(320, 568),
  'iPhone SE': Size(375, 667),
  'iPhone 14': Size(390, 844),
  'iPad mini dikey': Size(744, 1133),
  'iPad mini yatay': Size(1133, 744),
  'iPad 13 inç dikey': Size(1032, 1376),
  'iPad 13 inç yatay': Size(1376, 1032),
};

void main() {
  for (final MapEntry(key: name, value: size) in _screens.entries) {
    testWidgets('$name: her ekran taşmadan çiziliyor', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pump(const Duration(milliseconds: 400));
      }

      /// Açıklama ve ardından gelen butonlar için zamanı kare kare ilerletir
      Future<void> playOut() async {
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      await tester.pumpWidget(
        FingerRouletteApp(
          // init() çağrılmadı: sayaç, puan isteme ve analitik devre dışı
          stats: StatsService(),
          review: ReviewService(),
          nameStore: _FakeNames(),
          sound: _SilentSound(),
        ),
      );
      await tester.pump();

      // On parmak yalnızca tablette sunulur
      final tablet = TabletScale.isTablet(size);
      expect(find.text('10'), tablet ? findsOneWidget : findsNothing);

      // Parmak turu, ekranın izin verdiği en kalabalık hâliyle
      final players = tablet ? 10 : 5;
      await tap(find.text('$players'));
      await tap(find.text('2').last);
      final fingers = [
        for (var i = 0; i < players; i++)
          await tester.startGesture(
            Offset(
              size.width * (i.isEven ? 0.3 : 0.7),
              size.height * (0.2 + 0.06 * i),
            ),
          ),
      ];
      await tester.pump(const Duration(seconds: 1));
      for (final finger in fingers) {
        await finger.up();
      }
      await playOut();
      expect(find.byType(ShareButton), findsOneWidget);
      await tap(find.byIcon(Icons.close));

      // İsim turu: sekiz isim dört takıma bölünüyor, sonuç 2×2 liste
      await tap(find.byIcon(Icons.format_list_bulleted_rounded));
      await tap(find.byIcon(Icons.groups_outlined));
      await tap(find.text('4'));
      await tap(find.byType(ElevatedButton));
      await playOut();
      expect(find.byType(ShareButton), findsOneWidget);

      // Zamanlayıcılar ve animasyonlar kapansın
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  }
}
