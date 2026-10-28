import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_ui/tabs/shelves/shelf_detail/shelf_detail_bloc.dart';
import 'package:profile_ui/tabs/shelves/shelf_detail/shelf_detail_screen.dart';
import 'package:shelves/shelves.dart';

Shelf _shelf({bool isSelf = false, bool isSaved = false}) => Shelf(
  id: 9,
  ownerId: isSelf ? 'me' : 'bia',
  name: 'Noir',
  visibility: ContentVisibility.public,
  sortMode: ShelfSort.manual,
  pinned: false,
  totalMovies: 0,
  totalWatched: 0,
  posterPaths: const [],
  isSelf: isSelf,
  ownerName: isSelf ? null : 'Bia Lima',
  isSaved: isSaved,
  saves: isSaved ? 1 : 0,
);

class _FakeRepository implements ShelvesRepository {
  Shelf shelf;
  Result<void> saveResult = const Success(null);
  final saveCalls = <bool>[];

  _FakeRepository(this.shelf);

  @override
  Future<Result<Shelf>> getShelf(int shelfId) async => Success(shelf);

  @override
  Future<Result<Paged<ShelfMovie>>> getShelfMovies({
    required int shelfId,
    required ShelfMovieFilter filter,
    required int page,
  }) async => const Success(
    Paged(items: [], page: 1, totalPages: 1, totalResults: 0, hasNext: false),
  );

  @override
  Future<Result<void>> setShelfSaved({
    required int shelfId,
    required bool saved,
  }) async {
    saveCalls.add(saved);
    return saveResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

ShelfDetailCubit _cubit(_FakeRepository repository) => ShelfDetailCubit(
  shelfId: 9,
  getShelf: GetShelf(repository),
  getShelfMovies: GetShelfMovies(repository),
  sortShelf: SortShelf(repository),
  reorderShelfMovies: ReorderShelfMovies(repository),
  removeMovieFromShelf: RemoveMovieFromShelf(repository),
  transferShelfMovies: TransferShelfMovies(repository),
  addMoviesToShelf: AddMoviesToShelf(repository),
  setShelfSaved: SetShelfSaved(repository),
);

Widget _wrap(ShelfDetailCubit cubit, {ValueChanged<Shelf>? onOpenOwner}) =>
    MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ShelfDetailScreen(
        cubit: cubit,
        genres: Future.value(const Success(<GenreOption>[])),
        onMovieTap: (_) {},
        onAddMovies: () async => false,
        onPickTargetShelf: () async => null,
        onLogSession: (_) {},
        onImport: () {},
        onOpenOwner: onOpenOwner ?? (_) {},
      ),
    );

void main() {
  testWidgets(
    'a shelf of someone else shows the owner, who opens the profile (F14.6)',
    (tester) async {
      final cubit = _cubit(_FakeRepository(_shelf()));
      addTearDown(cubit.close);
      Shelf? opened;

      await tester.pumpWidget(
        _wrap(cubit, onOpenOwner: (shelf) => opened = shelf),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('de Bia Lima'));

      expect(opened?.ownerId, 'bia');
      expect(find.bySemanticsLabel('de Bia Lima'), findsOneWidget);
    },
  );

  testWidgets('saving flips the button to Salva (F14.5)', (tester) async {
    final repository = _FakeRepository(_shelf());
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repository.saveCalls, [true]);
    expect(find.text('Salva'), findsOneWidget);
    expect(find.text('Salvar'), findsNothing);
  });

  testWidgets('a failed save flips back and explains', (tester) async {
    final repository = _FakeRepository(_shelf(isSaved: true))
      ..saveResult = const Failure(AppError.unknown);
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(repository.saveCalls, [false]);
    expect(find.text('Salva'), findsOneWidget);
    expect(
      find.text(
        'Não foi possível atualizar as estantes salvas. Tente de novo.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('my own shelf has no owner line and no save button', (
    tester,
  ) async {
    final cubit = _cubit(_FakeRepository(_shelf(isSelf: true)));
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Salvar'), findsNothing);
    expect(find.textContaining('de '), findsNothing);
  });
}
