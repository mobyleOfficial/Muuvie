class Person {
  final int id;
  final int? tmdbPersonId;
  final String name;
  final String? profilePath;

  const Person({
    required this.id,
    this.tmdbPersonId,
    required this.name,
    this.profilePath,
  });
}
