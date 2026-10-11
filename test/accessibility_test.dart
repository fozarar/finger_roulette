import 'package:finger_roulette/app/app.dart';
import 'package:finger_roulette/l10n/app_localizations.dart';
import 'package:finger_roulette/models/name_list.dart';
import 'package:finger_roulette/services/names_service.dart';
import 'package:finger_roulette/services/review_service.dart';
import 'package:finger_roulette/services/sound_service.dart';
import 'package:finger_roulette/services/stats_service.dart';
import 'package:finger_roulette/widgets/name_list_editor.dart';
import 'package:finger_roulette/widgets/particle_overlay.dart';
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

/// Diske gitmeyen, üç isimle dolu gelen isim deposu
class _FakeNames extends NamesService {
  NameBook book = const NameBook(
    lists: [
      NameList(names: ['Alex', 'Sam', 'Mia']),
    ],
  );

  @override
  NameBook load() => book;

  @override
  Future<void> save(NameBook book) async => this.book = book;
}

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Zamanlayıcılar ve animasyonlar kapansın
  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  }

  /// Parmak ekranını iki oyuncuyla açar
  Future<void> openFingerScreen(WidgetTester tester) =>
      tap(tester, find.text('2'));

  /// Çark ekranını üç isim ve tek kazananla açar
  Future<void> openWheelScreen(WidgetTester tester) async {
    await tap(tester, find.byIcon(Icons.format_list_bulleted_rounded));
    await tap(tester, find.text('1'));
  }

  testWidgets('kapat butonları ekran okuyucuya ne yaptığını söyler',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);
    final closeButton = find.byIcon(Icons.close);

    await openFingerScreen(tester);
    expect(
      tester.getSemantics(closeButton),
      isSemantics(label: 'Change Settings', isButton: true),
    );
    await tap(tester, closeButton);

    await openWheelScreen(tester);
    expect(
      tester.getSemantics(closeButton),
      isSemantics(label: 'Change Settings', isButton: true),
    );

    await closeApp(tester);
    semantics.dispose();
  });

  group('isim silme çarpısı', () {
    late List<String> names;

    Future<void> pumpEditor(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
    }) async {
      names = ['Alex', 'Sam'];
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: NameListEditor(
              names: names,
              onChanged: (changed) => names = changed,
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('adıyla okunur, 44 noktadan küçük değildir ve ismi siler',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpEditor(tester);

      final remove = find.bySemanticsLabel('Remove Alex');
      expect(remove, findsOneWidget);
      expect(tester.getSemantics(remove), isSemantics(isButton: true));

      final size = tester.getSize(remove);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));

      await tester.tap(remove);
      expect(names, ['Sam']);

      semantics.dispose();
    });

    testWidgets('dokunma alanları birbirinin üstüne binmez', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpEditor(tester);

      final alex = tester.getRect(find.bySemanticsLabel('Remove Alex'));
      final sam = tester.getRect(find.bySemanticsLabel('Remove Sam'));
      expect(alex.overlaps(sam), isFalse);

      semantics.dispose();
    });

    for (final (locale, label) in [('en', 'Remove Alex'), ('ar', 'حذف Alex')]) {
      testWidgets('$locale: dokunma alanı çizilen çarpıyı kaplar',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpEditor(tester, locale: Locale(locale));

        // Sağdan sola dilde çarpı çipin solunda; alan da onunla gitmeli
        final target = tester.getRect(find.bySemanticsLabel(label));
        final cross = tester.getRect(find.byIcon(Icons.close_rounded).first);
        expect(target.expandToInclude(cross), target);

        semantics.dispose();
      });
    }
  });

  group('Hareketi Azalt', () {
    // Flaş, ekranı kaplayan tek renkli Container; uygulamada başka yok
    final flash = find.byWidgetPredicate(
      (widget) => widget is Container && widget.color != null,
    );
    final confetti = find.byType(ParticleOverlay);

    /// İki parmakla oynar ve açıklamadan 100 ms sonra durur
    Future<void> revealWithFingers(WidgetTester tester) async {
      await openFingerScreen(tester);
      final fingers = [
        await tester.startGesture(const Offset(120, 400)),
        await tester.startGesture(const Offset(270, 520)),
      ];
      // 0,8 saniyede kilit, ardından 2 saniye dönüş
      await tester.pump(const Duration(seconds: 1));
      for (final finger in fingers) {
        await finger.up();
      }
      await tester.pump(const Duration(milliseconds: 1900));
      await tester.pump(const Duration(milliseconds: 100));
    }

    /// Çarkı çevirir ve açıklamadan 100 ms sonra durur
    Future<void> revealWithWheel(WidgetTester tester) async {
      await openWheelScreen(tester);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    final rounds = {
      'parmak': revealWithFingers,
      'çark': revealWithWheel,
    };

    for (final MapEntry(key: name, value: reveal) in rounds.entries) {
      testWidgets('$name: ayar kapalıyken flaş ve konfeti var', (tester) async {
        await pumpApp(tester);
        await reveal(tester);

        expect(tester.widget<Container>(flash).color!.a, greaterThan(0));
        expect(confetti, findsOneWidget);

        await closeApp(tester);
      });

      testWidgets('$name: ayar açıkken ikisi de çizilmez', (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(reduceMotion: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await pumpApp(tester);
        await reveal(tester);

        expect(flash, findsNothing);
        expect(confetti, findsNothing);

        // Tur yine sonuna kadar oynandı: butonlar geliyor
        await tester.pump(const Duration(milliseconds: 2500));
        expect(find.byType(ShareButton), findsOneWidget);

        await closeApp(tester);
      });
    }
  });
}
