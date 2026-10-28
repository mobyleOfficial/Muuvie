import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locadoras_ui/locadoras_ui.dart';
import 'package:shelves/shelves.dart';

Locadora _locadora(
  int id,
  String name, {
  bool isSelf = true,
  bool pinned = false,
}) => Locadora(
  id: id,
  ownerId: 'ana',
  ownerUsername: 'ana',
  name: name,
  visibility: ContentVisibility.public,
  hideShelvesInProfile: false,
  hideShelvesInFilters: false,
  pinned: pinned,
  totalShelves: 2,
  totalMovies: 4,
  totalWatched: 1,
  posterPaths: const [],
  isSelf: isSelf,
);

LocadoraShelf _shelf(int id, String name, List<String> titles) => LocadoraShelf(
  shelf: Shelf(
    id: id,
    ownerId: 'ana',
    name: name,
    visibility: ContentVisibility.public,
    sortMode: ShelfSort.manual,
    pinned: false,
    totalMovies: titles.length,
    totalWatched: 0,
    posterPaths: const [],
    isSelf: true,
  ),
  movies: [
    for (final (index, title) in titles.indexed)
      ShelfMovie(movieId: id * 10 + index, title: title, watched: false),
  ],
);

class _FakeRepository implements LocadorasRepository {
  List<Locadora> locadoras;
  List<LocadoraShelf> shelves;
  String? requestedUserId;
  List<int>? reorderedShelfIds;

  _FakeRepository(this.locadoras, {this.shelves = const []});

  @override
  Future<Result<Paged<Locadora>>> getUserLocadoras({
    required String userId,
    required int page,
  }) async {
    requestedUserId = userId;
    return Success(
      Paged(
        items: locadoras,
        page: 1,
        totalPages: 1,
        totalResults: locadoras.length,
        hasNext: false,
      ),
    );
  }

  @override
  Future<Result<Locadora>> getLocadora(int locadoraId) async =>
      Success(locadoras.firstWhere((l) => l.id == locadoraId));

  @override
  Future<Result<Paged<LocadoraShelf>>> getLocadoraShelves({
    required int locadoraId,
    required int page,
  }) async => Success(
    Paged(
      items: shelves,
      page: 1,
      totalPages: 1,
      totalResults: shelves.length,
      hasNext: false,
    ),
  );

  @override
  Future<Result<void>> reorderLocadoraShelves({
    required int locadoraId,
    required List<int> shelfIds,
  }) async {
    reorderedShelfIds = shelfIds;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

LocadorasListCubit _listCubit(
  _FakeRepository repository, {
  String userId = 'me',
}) => LocadorasListCubit(
  userId: userId,
  getUserLocadoras: GetUserLocadoras(repository),
  saveLocadora: SaveLocadora(repository),
  deleteLocadora: DeleteLocadora(repository),
  reorderLocadoras: ReorderLocadoras(repository),
);

LocadoraDetailCubit _detailCubit(_FakeRepository repository) =>
    LocadoraDetailCubit(
      locadoraId: 1,
      getLocadora: GetLocadora(repository),
      getLocadoraShelves: GetLocadoraShelves(repository),
      saveLocadora: SaveLocadora(repository),
      deleteLocadora: DeleteLocadora(repository),
      setLocadoraShelves: SetLocadoraShelves(repository),
      reorderLocadoraShelves: ReorderLocadoraShelves(repository),
    );

Widget _detail(LocadoraDetailCubit cubit) => LocadoraDetailScreen(
  cubit: cubit,
  onMovieTap: (_) {},
  onEdit: (_) {},
  onDelete: (_) {},
  onChooseShelves: () {},
  onReorderSaved: (_) {},
);

void main() {
  testWidgets('my locadoras show counters and can be created and managed', (
    tester,
  ) async {
    final cubit = _listCubit(
      _FakeRepository([
        _locadora(1, 'Locadora do Terror', pinned: true),
        _locadora(2, 'Noir'),
      ]),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrap(
        LocadorasListScreen(
          cubit: cubit,
          onOpenLocadora: (_) {},
          onCreated: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Locadora do Terror'), findsOneWidget);
    expect(find.text('2 estantes'), findsNWidgets(2));
    expect(find.text('1/4 assistidos'), findsNWidgets(2));
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Reordenar locadoras'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsNWidgets(2));
  });

  testWidgets('someone else sees the locadoras read-only', (tester) async {
    final repository = _FakeRepository([
      _locadora(1, 'Locadora do Terror', isSelf: false),
    ]);
    final cubit = _listCubit(repository, userId: 'bia');
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrap(
        LocadorasListScreen(
          cubit: cubit,
          onOpenLocadora: (_) {},
          onCreated: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.requestedUserId, 'bia');
    expect(find.text('Locadora do Terror'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('an empty list explains what a locadora is', (tester) async {
    final cubit = _listCubit(_FakeRepository([]));
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrap(
        LocadorasListScreen(
          cubit: cubit,
          onOpenLocadora: (_) {},
          onCreated: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma locadora ainda'), findsOneWidget);
    expect(
      find.text('Agrupe suas estantes como os corredores de uma locadora.'),
      findsOneWidget,
    );
  });

  testWidgets('the detail shows owner, progress and one corridor per shelf', (
    tester,
  ) async {
    final cubit = _detailCubit(
      _FakeRepository(
        [_locadora(1, 'Locadora do Terror')],
        shelves: [
          _shelf(7, 'Slashers 80s', ['Halloween', 'Sexta-Feira 13']),
          _shelf(8, 'Folk horror', []),
        ],
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(_detail(cubit)));
    await tester.pumpAndSettle();

    expect(find.text('de @ana'), findsOneWidget);
    expect(find.text('1 de 4 filmes assistidos'), findsOneWidget);
    expect(find.text('Slashers 80s'), findsOneWidget);
    expect(find.bySemanticsLabel('Halloween'), findsOneWidget);
    expect(find.text('Estante vazia'), findsOneWidget);
    expect(find.text('Escolher estantes'), findsOneWidget);
  });

  testWidgets('the owner reorders the shelves of the locadora', (tester) async {
    final repository = _FakeRepository(
      [_locadora(1, 'Loc')],
      shelves: [_shelf(7, 'A', []), _shelf(8, 'B', [])],
    );
    final cubit = _detailCubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(_detail(cubit)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reordenar estantes'));
    await tester.pumpAndSettle();
    cubit.moveShelf(1, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();

    expect(repository.reorderedShelfIds, [8, 7]);
  });

  testWidgets('owner actions are hidden from others', (tester) async {
    final cubit = _detailCubit(
      _FakeRepository(
        [_locadora(1, 'Loc', isSelf: false)],
        shelves: [
          _shelf(7, 'A', ['X']),
        ],
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(_detail(cubit)));
    await tester.pumpAndSettle();

    expect(find.text('Escolher estantes'), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets(
    'the owner line of a locadora of someone else opens the profile (F14.6)',
    (tester) async {
      final cubit = _detailCubit(
        _FakeRepository(
          [_locadora(1, 'Loc', isSelf: false)],
          shelves: [
            _shelf(7, 'A', ['X']),
          ],
        ),
      );
      addTearDown(cubit.close);
      Locadora? opened;

      await tester.pumpWidget(
        _wrap(
          LocadoraDetailScreen(
            cubit: cubit,
            onMovieTap: (_) {},
            onOpenOwner: (locadora) => opened = locadora,
            onEdit: (_) {},
            onDelete: (_) {},
            onChooseShelves: () {},
            onReorderSaved: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('de @ana'));

      expect(opened?.ownerId, 'ana');
    },
  );

  testWidgets('my own locadora keeps the owner line static', (tester) async {
    final cubit = _detailCubit(_FakeRepository([_locadora(1, 'Loc')]));
    addTearDown(cubit.close);
    Locadora? opened;

    await tester.pumpWidget(
      _wrap(
        LocadoraDetailScreen(
          cubit: cubit,
          onMovieTap: (_) {},
          onOpenOwner: (locadora) => opened = locadora,
          onEdit: (_) {},
          onDelete: (_) {},
          onChooseShelves: () {},
          onReorderSaved: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('de @ana'));

    expect(opened, isNull);
    expect(
      find.ancestor(of: find.text('de @ana'), matching: find.byType(InkWell)),
      findsNothing,
    );
  });
}
