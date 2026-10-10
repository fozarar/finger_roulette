import 'package:finger_roulette/app/tablet_scale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ölçek', () {
    test('telefonda ve dar pencerede 1', () {
      expect(TabletScale.scaleFor(const Size(390, 844)), 1.0);
      expect(TabletScale.scaleFor(const Size(440, 956)), 1.0);
      // iPad'de yana alınmış dar pencere
      expect(TabletScale.scaleFor(const Size(375, 1024)), 1.0);
    });

    test('tablette kısa kenar 540 noktaya iner, en fazla 1.5 kat', () {
      expect(
        TabletScale.scaleFor(const Size(744, 1133)),
        closeTo(744 / 540, 1e-9),
      );
      expect(TabletScale.scaleFor(const Size(1032, 1376)), 1.5);
      expect(TabletScale.scaleFor(const Size(1376, 1032)), 1.5);
    });
  });

  group('tablette', () {
    Future<void> pumpOnTablet(WidgetTester tester, Widget child) async {
      tester.view.physicalSize = const Size(1032, 1376);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromView(tester.view),
          child: TabletScale(child: child),
        ),
      );
    }

    testWidgets('altındaki widget mantıksal ekranı görür', (tester) async {
      late Size logical;
      late Size real;
      await pumpOnTablet(
        tester,
        Builder(
          builder: (context) {
            logical = MediaQuery.sizeOf(context);
            real = TabletScale.realSizeOf(context);
            return const SizedBox.expand();
          },
        ),
      );

      expect(logical.width, closeTo(688, 0.01));
      expect(logical.height, closeTo(1376 / 1.5, 0.01));
      expect(real, const Size(1032, 1376));
    });

    testWidgets('dokunuş mantıksal konuma çevrilir', (tester) async {
      Offset? seen;
      await pumpOnTablet(
        tester,
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => seen = event.localPosition,
          child: const SizedBox.expand(),
        ),
      );

      await tester.tapAt(const Offset(516, 688));
      expect(seen!.dx, closeTo(344, 0.01));
      expect(seen!.dy, closeTo(688 / 1.5, 0.01));
    });
  });
}
