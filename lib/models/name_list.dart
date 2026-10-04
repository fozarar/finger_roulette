/// Adı olan bir isim listesi: "ofis", "halı saha", "aile" gibi.
///
/// Ad isteğe bağlı. Boşsa arayüz sırasına göre "Liste 1" gibi bir ad
/// gösterir; o metin dile bağlı olduğu için burada saklanmaz.
class NameList {
  final String title;
  final List<String> names;

  const NameList({this.title = '', this.names = const []});

  NameList copyWith({String? title, List<String>? names}) => NameList(
        title: title ?? this.title,
        names: names ?? this.names,
      );

  Map<String, Object> toJson() => {'title': title, 'names': names};

  /// Bozuk ya da eksik alanları boş değerle karşılar; tek bir bozuk kayıt
  /// bütün listeleri okunmaz kılmasın.
  factory NameList.fromJson(Object? json) {
    if (json is! Map) return const NameList();
    final title = json['title'];
    final names = json['names'];
    return NameList(
      title: title is String ? title : '',
      names: names is List ? names.whereType<String>().toList() : const [],
    );
  }
}

/// Kullanıcının bütün listeleri ve en son hangisinin açık olduğu.
/// En az bir liste her zaman vardır.
class NameBook {
  final List<NameList> lists;
  final int active;

  const NameBook({this.lists = const [NameList()], this.active = 0});
}
