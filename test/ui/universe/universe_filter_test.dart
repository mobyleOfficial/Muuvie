import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/filter/universe_filter.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';

Movie _movie(int id, {String releaseDate = '', WatchStatus? status}) => Movie(
  id: id,
  title: 'Movie $id',
  posterPath: '',
  info: MovieInfo(overview: '', backdropPath: '', releaseDate: releaseDate),
  me: status == null ? null : MovieListState(status: status),
);

SimilarMovie _similar(Movie movie, {List<String> genres = const []}) =>
    SimilarMovie(movie: movie, score: 0.5, genres: genres);

void main() {
  test('no filter keeps every planet', () {
    expect(UniverseFilter.none.isActive, isFalse);
    expect(UniverseFilter.none.matches(_similar(_movie(1))), isTrue);
  });

  test('the decade comes from the release year', () {
    const filter = UniverseFilter(decade: 1980);
    expect(
      filter.matches(_similar(_movie(1, releaseDate: '1987-04-01'))),
      isTrue,
    );
    expect(
      filter.matches(_similar(_movie(2, releaseDate: '1990-01-01'))),
      isFalse,
    );
    // No year: nothing shows it belongs to the decade.
    expect(filter.matches(_similar(_movie(3))), isFalse);
  });

  test('a genre filter leaves out movies whose genres are unknown', () {
    const filter = UniverseFilter(genre: 'Terror');
    expect(
      filter.matches(_similar(_movie(1), genres: ['Drama', 'Terror'])),
      isTrue,
    );
    expect(filter.matches(_similar(_movie(2), genres: ['Drama'])), isFalse);
    expect(filter.matches(_similar(_movie(3))), isFalse);
  });

  test('only unwatched keeps Quero ver and unknown movies', () {
    const filter = UniverseFilter(onlyUnwatched: true);
    expect(
      filter.matches(_similar(_movie(1, status: WatchStatus.watched))),
      isFalse,
    );
    expect(
      filter.matches(_similar(_movie(2, status: WatchStatus.wantToWatch))),
      isTrue,
    );
    expect(filter.matches(_similar(_movie(3))), isTrue);
  });

  test('the options are the genres and decades in the universe', () {
    final graph = UniverseGraph.origin(_movie(1, releaseDate: '1977-01-01'), [
      _similar(_movie(2, releaseDate: '1985-05-05'), genres: ['Terror']),
      _similar(
        _movie(3, releaseDate: '2001-01-01'),
        genres: ['Drama', 'Terror'],
      ),
      _similar(_movie(4)),
    ]);

    final options = UniverseFilterOptions.of(graph);

    expect(options.genres, ['Drama', 'Terror']);
    // The star is not a planet: its decade is not offered.
    expect(options.decades, [2000, 1980]);
  });

  test('a new state reaches the planet and the star of the same movie', () {
    final graph = UniverseGraph.origin(_movie(1), [_similar(_movie(2))]);
    const watched = MovieListState(status: WatchStatus.watched);

    final updated = graph.withMovieState(2, watched).withMovieState(1, watched);

    expect(updated.planetOf(2)!.movie.me?.status, WatchStatus.watched);
    expect(updated.origin.star.me?.status, WatchStatus.watched);
    expect(
      graph.planetOf(2)!.movie.me,
      isNull,
      reason: 'the graph is immutable',
    );
    expect(updated.withMovieState(99, watched), same(updated));
  });
}
