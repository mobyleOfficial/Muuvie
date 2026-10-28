class Language {
  final String iso;
  final String englishName;

  /// The language's own name ("Français"); TMDB does not translate them.
  final String name;

  const Language({required this.iso, required this.englishName, String? name})
    : name = name ?? englishName;
}
