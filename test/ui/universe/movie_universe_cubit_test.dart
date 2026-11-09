import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';
import 'package:shelves/shelves.dart';
import 'package:universe_ui/movie_universe/filter/universe_filter.dart';
import 'package:universe_ui/universe_ui.dart';

/// Answers the similar movies set for each id (empty otherwise), or
/// [failure] for the ids in [failingIds], and records every id asked for.
class _FakeMoviesRepository implements MoviesRepository {
  final Map<int, List<Movie>> similarById;
  final Set<int> failingIds;
  final Map<int, List<String>> genresById;
  final askedIds = <int>[];

  _FakeMoviesRepository(
    this.similarById, {
    this.failingIds = const {},
    this.genresById = const {},
  });

  @override
  Future<Result<List<SimilarMovie>>> getSimilarMovies({
    required int movieId,
  }) async {
    askedIds.add(movieId);
    if (failingIds.contains(movieId)) return const Failure(AppError.network);
    final movies = similarById[movieId] ?? const <Movie>[];
    return Success([
      for (var rank = 0; rank < movies.length; rank++)
        SimilarMovie(
          movie: movies[rank],
          score: SimilarMovie.neutralScore(rank, movies.length),
          genres: genresById[movies[rank].id] ?? const [],
        ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// "Quero ver" found as shelf 2; [fail] makes adding to it fail.
class _FakeShelvesRepository implements ShelvesRepository {
  bool fail = false;
  final addedMovieIds = <int>[];

  @override
  Future<Result<Paged<Shelf>>> getUserShelves({
    required String userId,
    required int page,
    bool profile = false,
  }) async => const Success(
    Paged(
      items: [
        Shelf(
          id: 2,
          ownerId: 'me',
          name: 'Quero ver',
          visibility: ContentVisibility.public,
          systemType: SystemShelfType.watchlist,
          sortMode: ShelfSort.manual,
          pinned: false,
          totalMovies: 0,
          totalWatched: 0,
          posterPaths: [],
          isSelf: true,
        ),
      ],
      page: 1,
      totalPages: 1,
      totalResults: 1,
      hasNext: false,
    ),
  );

  @override
  Future<Result<MovieShelves>> addMovieToShelves({
    required int movieId,
    required List<int> shelfIds,
  }) async {
    if (fail) return const Failure(AppError.network);
    addedMovieIds.add(movieId);
    return Success(MovieShelves(movieId: movieId, shelfIds: shelfIds.toSet()));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

const _suspiria = Movie(id: 7, title: 'Suspiria', posterPath: '/s.jpg');
const _inferno = Movie(id: 8, title: 'Inferno', posterPath: '/i.jpg');
const _tenebre = Movie(
  id: 9,
  title: 'Tenebre',
  posterPath: '/t.jpg',
  me: MovieListState(status: WatchStatus.watched),
);
const _phenomena = Movie(id: 10, title: 'Phenomena', posterPath: '/p.jpg');
const _opera = Movie(id: 11, title: 'Opera', posterPath: '/o.jpg');

final _universe = {
  7: [_inferno, _tenebre],
  8: [_suspiria, _phenomena, _tenebre],
  10: [_opera],
};

/// Without prefetching unless [prefetchedPlanets] is given, so the calls
/// each test expects are only the ones it makes.
MovieUniverseCubit _cubit(
  _FakeMoviesRepository repository, {
  int prefetchedPlanets = 0,
  _FakeShelvesRepository? shelves,
}) => MovieUniverseCubit(
  getSimilarMovies: GetSimilarMovies(repository),
  addMovieToWatchlist: AddMovieToWatchlist(shelves ?? _FakeShelvesRepository()),
  origin: _suspiria,
  prefetchedPlanets: prefetchedPlanets,
);

Iterable<int> _planetIds(MovieUniverseExploring state) =>
    state.currentSystem.planets.map((planet) => planet.movie.id);

void main() {
  blocTest<MovieUniverseCubit, MovieUniverseState>(
    'puts the similar movies of the origin in orbit',
    build: () => _cubit(_FakeMoviesRepository(_universe)),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<MovieUniverseLoading>(),
      isA<MovieUniverseExploring>()
          .having((state) => state.currentStarId, 'current', 7)
          .having(_planetIds, 'planets', [8, 9])
          .having((state) => state.showAsList, 'showAsList', false)
          .having((state) => state.selected, 'selected', isNull),
    ],
  );

  blocTest<MovieUniverseCubit, MovieUniverseState>(
    'a screen reader user starts on the list',
    build: () => _cubit(_FakeMoviesRepository(_universe)),
    act: (cubit) => cubit.load(startAsList: true),
    skip: 1,
    expect: () => [
      isA<MovieUniverseExploring>().having(
        (state) => state.showAsList,
        'showAsList',
        true,
      ),
    ],
  );

  blocTest<MovieUniverseCubit, MovieUniverseState>(
    'a movie without similar movies is a star alone',
    build: () => _cubit(_FakeMoviesRepository(const {})),
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => [isA<MovieUniverseEmpty>()],
  );

  blocTest<MovieUniverseCubit, MovieUniverseState>(
    'a failed load shows the error',
    build: () => _cubit(_FakeMoviesRepository(const {}, failingIds: {7})),
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => [isA<MovieUniverseFailure>()],
  );

  blocTest<MovieUniverseCubit, MovieUniverseState>(
    'tapping a planet opens its card, tapping it again closes it',
    build: () => _cubit(_FakeMoviesRepository(_universe)),
    act: (cubit) async {
      await cubit.load();
      cubit
        ..select(_tenebre)
        ..select(_tenebre);
    },
    skip: 2,
    expect: () => [
      isA<MovieUniverseExploring>().having(
        (state) => state.selected,
        'selected',
        _tenebre,
      ),
      isA<MovieUniverseExploring>().having(
        (state) => state.selected,
        'selected',
        isNull,
      ),
    ],
  );

  blocTest<MovieUniverseCubit, MovieUniverseState>(
    'traveling to a planet makes it a system one jump away, without repeats',
    build: () => _cubit(_FakeMoviesRepository(_universe)),
    act: (cubit) async {
      await cubit.load();
      cubit.select(_inferno);
      await cubit.travelTo(_inferno);
    },
    skip: 3,
    expect: () => [
      isA<MovieUniverseExploring>().having(
        (state) => state.travelingTo,
        'travelingTo',
        _inferno,
      ),
      isA<MovieUniverseExploring>()
          .having((state) => state.currentStarId, 'current', 8)
          .having((state) => state.currentSystem.hops, 'hops', 1)
          // Suspiria is the origin and Tenebre already orbits it.
          .having(_planetIds, 'planets', [10])
          .having((state) => state.selected, 'selected', isNull)
          .having((state) => state.travelingTo, 'travelingTo', isNull)
          .having(
            (state) => state.graph.origin.planets.map((p) => p.movie.id),
            'origin planets',
            [9],
          ),
    ],
  );

  test('a system already visited is focused again without loading', () async {
    final repository = _FakeMoviesRepository(_universe);
    final cubit = _cubit(repository);
    await cubit.load();
    await cubit.travelTo(_inferno);
    await cubit.travelTo(_phenomena);
    cubit.backToOrigin();

    await cubit.travelTo(_inferno);

    final state = cubit.state as MovieUniverseExploring;
    expect(state.currentStarId, 8);
    expect(repository.askedIds, [7, 8, 10]);
    expect(state.graph.systemOf(10)!.hops, 2);
    await cubit.close();
  });

  blocTest<MovieUniverseCubit, MovieUniverseState>(
    'a failed jump stays where it was and reports the planet once',
    build: () => _cubit(_FakeMoviesRepository(_universe, failingIds: {9})),
    act: (cubit) async {
      await cubit.load();
      await cubit.travelTo(_tenebre);
      cubit.select(_inferno);
    },
    skip: 3,
    expect: () => [
      isA<MovieUniverseExploring>()
          .having((state) => state.currentStarId, 'current', 7)
          .having((state) => state.failedTravel, 'failedTravel', _tenebre)
          .having((state) => state.travelingTo, 'travelingTo', isNull),
      isA<MovieUniverseExploring>().having(
        (state) => state.failedTravel,
        'failedTravel',
        isNull,
      ),
    ],
  );

  blocTest<MovieUniverseCubit, MovieUniverseState>(
    'back to the origin focuses the first system and closes the card',
    build: () => _cubit(_FakeMoviesRepository(_universe)),
    act: (cubit) async {
      await cubit.load();
      await cubit.travelTo(_inferno);
      cubit
        ..select(_phenomena)
        ..backToOrigin();
    },
    skip: 5,
    expect: () => [
      isA<MovieUniverseExploring>()
          .having((state) => state.currentStarId, 'current', 7)
          .having((state) => state.selected, 'selected', isNull),
    ],
  );

  blocTest<MovieUniverseCubit, MovieUniverseState>(
    'switching to the list closes the open card and a reload keeps the list',
    build: () => _cubit(_FakeMoviesRepository(_universe)),
    act: (cubit) async {
      await cubit.load();
      cubit
        ..select(_inferno)
        ..toggleView();
      await cubit.load();
    },
    skip: 3,
    expect: () => [
      isA<MovieUniverseExploring>()
          .having((state) => state.showAsList, 'showAsList', true)
          .having((state) => state.selected, 'selected', isNull),
      isA<MovieUniverseLoading>(),
      isA<MovieUniverseExploring>().having(
        (state) => state.showAsList,
        'showAsList',
        true,
      ),
    ],
  );

  group('prefetch', () {
    test('the closest planets of the origin load ahead', () async {
      final repository = _FakeMoviesRepository(_universe);
      final cubit = _cubit(repository, prefetchedPlanets: 1);

      await cubit.load();
      await pumpEventQueue();

      expect(repository.askedIds, [7, 8]);
      await cubit.close();
    });

    test('a jump to a planet loaded ahead does not ask again', () async {
      final repository = _FakeMoviesRepository(_universe);
      final cubit = _cubit(repository, prefetchedPlanets: 3);
      await cubit.load();
      await pumpEventQueue();

      await cubit.travelTo(_inferno);

      final state = cubit.state as MovieUniverseExploring;
      expect(state.currentStarId, 8);
      expect(repository.askedIds.where((id) => id == 8), hasLength(1));
      // Inferno is in focus now: its closest planet, Phenomena, loads ahead.
      await pumpEventQueue();
      expect(repository.askedIds.last, 10);
      await cubit.close();
    });

    test('opening the card of a planet loads it ahead', () async {
      final repository = _FakeMoviesRepository(_universe);
      final cubit = _cubit(repository, prefetchedPlanets: 1);
      await cubit.load();

      cubit.select(_tenebre);
      await pumpEventQueue();

      expect(repository.askedIds, containsAll([7, 8, 9]));
      await cubit.close();
    });

    test('a failed load ahead is asked again on the jump', () async {
      final repository = _FakeMoviesRepository(_universe, failingIds: {8});
      final cubit = _cubit(repository, prefetchedPlanets: 1);
      await cubit.load();
      await pumpEventQueue();

      await cubit.travelTo(_inferno);

      expect(repository.askedIds.where((id) => id == 8), hasLength(2));
      expect((cubit.state as MovieUniverseExploring).failedTravel, _inferno);
      await cubit.close();
    });
  });

  group('phase 4', () {
    WatchStatus? statusOf(MovieUniverseCubit cubit, int movieId) =>
        (cubit.state as MovieUniverseExploring).graph
            .planetOf(movieId)
            ?.movie
            .me
            ?.status;

    test('"Quero ver" marks the planet at once and keeps it', () async {
      final shelves = _FakeShelvesRepository();
      final cubit = _cubit(_FakeMoviesRepository(_universe), shelves: shelves);
      await cubit.load();

      final pending = cubit.addToWatchlist(_inferno);
      expect(statusOf(cubit, 8), WatchStatus.wantToWatch);

      expect(await pending, isTrue);
      expect(statusOf(cubit, 8), WatchStatus.wantToWatch);
      expect(shelves.addedMovieIds, [8]);
      await cubit.close();
    });

    test('a failed "Quero ver" puts the planet back as it was', () async {
      final shelves = _FakeShelvesRepository()..fail = true;
      final cubit = _cubit(_FakeMoviesRepository(_universe), shelves: shelves);
      await cubit.load();

      expect(await cubit.addToWatchlist(_inferno), isFalse);
      expect(statusOf(cubit, 8), isNull);
      await cubit.close();
    });

    test(
      'the filter keeps the matching planets and the reload keeps it',
      () async {
        final repository = _FakeMoviesRepository(
          _universe,
          genresById: {
            8: ['Terror'],
            9: ['Terror', 'Mistério'],
          },
        );
        final cubit = _cubit(repository);
        await cubit.load();

        cubit.setFilter(const UniverseFilter(genre: 'Mistério'));
        var state = cubit.state as MovieUniverseExploring;
        expect(state.matchingPlanets.map((planet) => planet.movie.id), [9]);

        cubit.setFilter(const UniverseFilter(onlyUnwatched: true));
        state = cubit.state as MovieUniverseExploring;
        expect(state.matchingPlanets.map((planet) => planet.movie.id), [8]);

        await cubit.load();
        state = cubit.state as MovieUniverseExploring;
        expect(state.filter, const UniverseFilter(onlyUnwatched: true));
        await cubit.close();
      },
    );

    test('the card of a planet the filter leaves out closes', () async {
      final cubit = _cubit(_FakeMoviesRepository(_universe));
      await cubit.load();
      cubit.select(_tenebre);
      cubit.setFilter(const UniverseFilter(onlyUnwatched: true));
      expect((cubit.state as MovieUniverseExploring).selected, isNull);

      cubit.select(_inferno);
      cubit.setFilter(const UniverseFilter(onlyUnwatched: true, decade: null));
      expect((cubit.state as MovieUniverseExploring).selected, _inferno);
      await cubit.close();
    });
  });
}
