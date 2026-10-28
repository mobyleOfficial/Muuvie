import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';

void main() {
  Map<String, dynamic> detail({String? matchStatus}) => {
    'id': 42,
    'title': 'Filme Raro',
    'overview': '',
    'genres': <String>[],
    'matchStatus': ?matchStatus,
  };

  test('an imported movie TMDB did not match is flagged as unmatched', () {
    final movie = RemoteMovieDetail.fromJson(
      detail(matchStatus: 'unmatched'),
    ).toDomain();

    expect(movie.info?.isUnmatched, isTrue);
  });

  test('matched, pending or absent statuses are not flagged', () {
    for (final status in ['matched', 'pending', null]) {
      final movie = RemoteMovieDetail.fromJson(
        detail(matchStatus: status),
      ).toDomain();

      expect(movie.info?.isUnmatched, isFalse, reason: 'status $status');
    }
  });
}
