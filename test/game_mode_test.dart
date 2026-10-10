import 'package:finger_roulette/models/game_mode.dart';
import 'package:finger_roulette/screens/selection_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('oyuncu sayıları', () {
    test('telefonda beşe kadar; takım modu üçten başlar', () {
      expect(GameMode.pick.playerCounts(), [2, 3, 4, 5]);
      expect(GameMode.order.playerCounts(), [2, 3, 4, 5]);
      expect(GameMode.teams.playerCounts(), [3, 4, 5]);
    });

    test('tablette ona kadar', () {
      const max = GameMode.tabletMaxPlayers;
      expect(GameMode.pick.playerCounts(maxPlayers: max).last, 10);
      expect(GameMode.teams.playerCounts(maxPlayers: max).first, 3);
      expect(GameMode.teams.playerCounts(maxPlayers: max).last, 10);
    });
  });

  group('ekrana göre üst sınır', () {
    test('telefon beşte kalır', () {
      expect(SelectionScreen.maxPlayersFor(const Size(390, 844)), 5);
      // En büyük telefon da yatayda da olsa telefon
      expect(SelectionScreen.maxPlayersFor(const Size(956, 440)), 5);
    });

    test('iPad her iki yönde on parmak sunar', () {
      expect(SelectionScreen.maxPlayersFor(const Size(744, 1133)), 10);
      expect(SelectionScreen.maxPlayersFor(const Size(1366, 1024)), 10);
    });

    test('iPad\'de daraltılmış pencere telefon gibi davranır', () {
      expect(SelectionScreen.maxPlayersFor(const Size(375, 1024)), 5);
    });
  });
}
