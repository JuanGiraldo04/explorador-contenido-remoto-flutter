class Episode {
  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.code,
    required this.characterCount,
  });

  final int id;
  final String name;
  final String airDate;
  final String code;
  final int characterCount;
}
