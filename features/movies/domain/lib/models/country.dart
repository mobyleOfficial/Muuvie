class Country {
  final String iso;
  final String englishName;

  /// Localized by the catalog (pt-BR), English when it has no translation.
  final String name;

  const Country({required this.iso, required this.englishName, String? name})
    : name = name ?? englishName;
}
