import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelves/shelves.dart';

Shelf _shelf(int id, {SystemShelfType? systemType}) => Shelf(
  id: id,
  ownerId: 'ana',
  name: 'Shelf $id',
  visibility: ContentVisibility.public,
  systemType: systemType,
  sortMode: ShelfSort.manual,
  pinned: false,
  totalMovies: 0,
  totalWatched: 0,
  posterPaths: const [],
  isSelf: true,
);

/// Only the calls the use cases under test make; anything else fails the test.
class _FakeRepository implements ShelvesRepository {
  final calls = <String>[];
  ShelfDraft? savedDraft;
  final failingMovieIds = <int>{};

  @override
  Future<Result<Shelf>> createShelf(ShelfDraft draft) async {
    calls.add('create');
    savedDraft = draft;
    return Success(_shelf(1));
  }

  @override
  Future<Result<Shelf>> updateShelf(int shelfId, ShelfDraft draft) async {
    calls.add('update $shelfId');
    savedDraft = draft;
    return Success(_shelf(shelfId));
  }

  @override
  Future<Result<void>> deleteShelf(int shelfId) async {
    calls.add('delete $shelfId');
    return const Success(null);
  }

  @override
  Future<Result<void>> addMovieToShelf({
    required int shelfId,
    required int movieId,
  }) async {
    calls.add('add $movieId');
    return failingMovieIds.contains(movieId)
        ? const Failure(AppError.server)
        : const Success(null);
  }

  @override
  Future<Result<void>> transferShelfMovies({
    required int shelfId,
    required int targetShelfId,
    required ShelfTransferMode mode,
    required List<int> movieIds,
  }) async {
    calls.add('transfer');
    return const Success(null);
  }

  @override
  Future<Result<MovieShelves>> addMovieToShelves({
    required int movieId,
    required List<int> shelfIds,
  }) async {
    calls.add('addToShelves $shelfIds');
    return Success(MovieShelves(movieId: movieId, shelfIds: shelfIds.toSet()));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  group('SaveShelf', () {
    test(
      'creates with trimmed values and drops an empty description',
      () async {
        final result = await SaveShelf(repository)(
          const SaveShelfParams(
            draft: ShelfDraft(name: '  Cult  ', description: '   '),
          ),
        );

        expect(result, isA<Success<Shelf>>());
        expect(repository.calls, ['create']);
        expect(repository.savedDraft?.name, 'Cult');
        expect(repository.savedDraft?.description, isNull);
      },
    );

    test('edits when a shelf id is given', () async {
      await SaveShelf(repository)(
        const SaveShelfParams(shelfId: 4, draft: ShelfDraft(name: 'Cult')),
      );

      expect(repository.calls, ['update 4']);
    });

    test(
      'rejects a blank or too long name and a long description without calling the API',
      () async {
        final blank = await SaveShelf(repository)(
          const SaveShelfParams(draft: ShelfDraft(name: ' ')),
        );
        final longName = await SaveShelf(repository)(
          SaveShelfParams(draft: ShelfDraft(name: 'x' * 151)),
        );
        final longDescription = await SaveShelf(repository)(
          SaveShelfParams(
            draft: ShelfDraft(name: 'ok', description: 'd' * 151),
          ),
        );

        for (final result in [blank, longName, longDescription]) {
          expect((result as Failure<Shelf>).error, AppError.badRequest);
        }
        expect(repository.calls, isEmpty);
      },
    );
  });

  test('system shelves are never deleted', () async {
    final system = await DeleteShelf(repository)(
      _shelf(1, systemType: SystemShelfType.watchlist),
    );
    final regular = await DeleteShelf(repository)(_shelf(2));

    expect((system as Failure<void>).error, AppError.forbidden);
    expect(regular, isA<Success<void>>());
    expect(repository.calls, ['delete 2']);
  });

  test('a transfer needs another shelf', () async {
    final same = await TransferShelfMovies(repository)(
      const TransferShelfMoviesParams(
        shelfId: 1,
        targetShelfId: 1,
        mode: ShelfTransferMode.move,
      ),
    );

    expect((same as Failure<void>).error, AppError.badRequest);
    expect(repository.calls, isEmpty);
  });

  test(
    'adding to shelves needs at least one shelf and sends each once',
    () async {
      final empty = await AddMovieToShelves(repository)(
        const AddMovieToShelvesParams(movieId: 10, shelfIds: []),
      );
      await AddMovieToShelves(repository)(
        const AddMovieToShelvesParams(movieId: 10, shelfIds: [3, 3, 4]),
      );

      expect(empty, isA<Failure<MovieShelves>>());
      expect(repository.calls, ['addToShelves [3, 4]']);
    },
  );

  test('adding movies to a shelf stops at the first failure', () async {
    repository.failingMovieIds.add(2);

    final result = await AddMoviesToShelf(repository)(
      const AddMoviesToShelfParams(shelfId: 1, movieIds: [1, 2, 3]),
    );

    expect(result, isA<Failure<void>>());
    expect(repository.calls, ['add 1', 'add 2']);
  });
}
