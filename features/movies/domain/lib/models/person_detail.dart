import 'package:movies_domain/models/person.dart';

/// What a person did in a movie the catalog knows.
class PersonCredit {
  /// Database id of the movie (opens the movie detail).
  final int movieId;
  final int? tmdbId;
  final String title;
  final String? posterPath;
  final String? releaseDate;

  /// `cast` or `director`, as stored by the TMDB enrichment.
  final String role;
  final String? character;

  const PersonCredit({
    required this.movieId,
    this.tmdbId,
    required this.title,
    this.posterPath,
    this.releaseDate,
    required this.role,
    this.character,
  });

  bool get isDirector => role == 'director';

  int? get year => releaseDate != null && releaseDate!.length >= 4
      ? int.tryParse(releaseDate!.substring(0, 4))
      : null;
}

/// An actor or director with the movies of the catalog they are in (F5.7).
class PersonDetail {
  final Person person;
  final List<PersonCredit> credits;

  const PersonDetail({required this.person, required this.credits});

  List<PersonCredit> get directed =>
      credits.where((c) => c.isDirector).toList();

  List<PersonCredit> get acted => credits.where((c) => !c.isDirector).toList();
}
