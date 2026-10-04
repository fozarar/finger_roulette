import 'dart:convert';

import 'package:finger_roulette/models/name_list.dart';
import 'package:finger_roulette/services/names_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<NamesService> serviceWith(Map<String, Object> stored) async {
    SharedPreferences.setMockInitialValues(stored);
    final service = NamesService();
    await service.init();
    return service;
  }

  test('hiç kayıt yoksa tek bir boş liste döner', () async {
    final book = (await serviceWith({})).load();

    expect(book.lists, hasLength(1));
    expect(book.lists.single.names, isEmpty);
    expect(book.active, 0);
  });

  test('init çağrılmadıysa da tek bir boş liste döner', () {
    final book = NamesService().load();

    expect(book.lists, hasLength(1));
    expect(book.active, 0);
  });

  test('eski sürümün tek listesi ilk liste olarak taşınır', () async {
    final service = await serviceWith({
      'names_list': ['Ali', 'Veli', 'Ayşe'],
    });

    final book = service.load();

    expect(book.lists, hasLength(1));
    expect(book.lists.single.names, ['Ali', 'Veli', 'Ayşe']);
    expect(book.lists.single.title, isEmpty);
  });

  test('yazılan listeler adları ve açık olanla birlikte geri okunur',
      () async {
    final service = await serviceWith({});
    await service.save(
      const NameBook(
        lists: [
          NameList(title: 'Ofis', names: ['Ali', 'Veli']),
          NameList(names: ['Can', 'Ece', 'Efe']),
        ],
        active: 1,
      ),
    );

    final reloaded = NamesService();
    await reloaded.init();
    final book = reloaded.load();

    expect(book.lists, hasLength(2));
    expect(book.lists[0].title, 'Ofis');
    expect(book.lists[0].names, ['Ali', 'Veli']);
    expect(book.lists[1].title, isEmpty);
    expect(book.lists[1].names, ['Can', 'Ece', 'Efe']);
    expect(book.active, 1);
  });

  test('yeni kayıt varken eski liste artık okunmaz', () async {
    final service = await serviceWith({
      'names_list': ['Eski'],
      'names_lists': jsonEncode([
        {'title': 'Yeni', 'names': ['Can']},
      ]),
    });

    final book = service.load();

    expect(book.lists.single.title, 'Yeni');
    expect(book.lists.single.names, ['Can']);
  });

  test('bozuk kayıt uygulamayı düşürmez, boş liste döner', () async {
    final service = await serviceWith({'names_lists': '{bozuk'});

    final book = service.load();

    expect(book.lists, hasLength(1));
    expect(book.lists.single.names, isEmpty);
  });

  test('eksik alanlı bir liste boş değerlerle okunur', () async {
    final service = await serviceWith({
      'names_lists': jsonEncode([
        {'names': ['Can', 7, null]},
        'liste değil',
      ]),
    });

    final book = service.load();

    expect(book.lists, hasLength(2));
    expect(book.lists[0].title, isEmpty);
    expect(book.lists[0].names, ['Can']);
    expect(book.lists[1].names, isEmpty);
  });

  test('sınırın dışında kalmış açık liste sırası düzeltilir', () async {
    final service = await serviceWith({
      'names_lists': jsonEncode([
        {'title': 'Tek', 'names': <String>[]},
      ]),
      'names_active_list': 6,
    });

    expect(service.load().active, 0);
  });
}
