import 'package:finger_roulette/l10n/app_localizations.dart';
import 'package:finger_roulette/models/name_list.dart';
import 'package:finger_roulette/services/names_service.dart';
import 'package:finger_roulette/widgets/name_list_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> calls;

  Future<void> pumpTabs(
    WidgetTester tester, {
    required List<NameList> lists,
    int active = 0,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: NameListTabs(
              lists: lists,
              activeIndex: active,
              onSelect: (i) => calls.add('select $i'),
              onAdd: () => calls.add('add'),
              onRename: (title) => calls.add('rename $title'),
              onDelete: () => calls.add('delete'),
            ),
          ),
        ),
      );

  setUp(() => calls = []);

  testWidgets('adsız liste sırasına göre, adlı liste adıyla görünür',
      (tester) async {
    await pumpTabs(
      tester,
      lists: const [NameList(), NameList(title: 'Ofis'), NameList()],
    );

    expect(find.text('List 1'), findsOneWidget);
    expect(find.text('Ofis'), findsOneWidget);
    expect(find.text('List 3'), findsOneWidget);
  });

  testWidgets('başka sekmeye dokunmak o listeye geçer', (tester) async {
    await pumpTabs(
      tester,
      lists: const [NameList(), NameList(title: 'Ofis')],
    );

    await tester.tap(find.text('Ofis'));

    expect(calls, ['select 1']);
  });

  testWidgets('artı yeni liste ister; üst sınırda görünmez', (tester) async {
    await pumpTabs(tester, lists: const [NameList()]);
    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(calls, ['add']);

    await pumpTabs(
      tester,
      lists: List.filled(NamesService.maxLists, const NameList()),
    );
    expect(find.byIcon(Icons.add_rounded), findsNothing);
  });

  testWidgets('açık sekme adını değiştirme sayfasını açar', (tester) async {
    await pumpTabs(tester, lists: const [NameList(title: 'Ofis')]);

    await tester.tap(find.text('Ofis'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty, reason: 'açık sekmeye dokunmak listeyi değiştirmez');

    await tester.enterText(find.byType(TextField), 'Halı saha');
    expect(calls, ['rename Halı saha']);
  });

  testWidgets('silme iki dokunuş ister', (tester) async {
    await pumpTabs(tester, lists: const [NameList(title: 'Ofis')]);
    await tester.tap(find.text('Ofis'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete list'));
    await tester.pump();
    expect(calls, isEmpty);
    expect(find.text('Tap again to delete'), findsOneWidget);

    await tester.tap(find.text('Tap again to delete'));
    await tester.pumpAndSettle();
    expect(calls, ['delete']);
    expect(find.byType(TextField), findsNothing, reason: 'sayfa kapanır');
  });
}
