import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_ui/tabs/shelves/shelf_form_bottom_sheet.dart';
import 'package:profile_ui/tabs/shelves/shelves_bloc.dart';
import 'package:profile_ui/tabs/shelves/shelves_screen.dart';
import 'package:shelves/shelves.dart';

Shelf _shelf(
  int id,
  String name, {
  SystemShelfType? systemType,
  bool pinned = false,
}) => Shelf(
  id: id,
  ownerId: 'ana',
  name: name,
  visibility: ContentVisibility.public,
  systemType: systemType,
  sortMode: ShelfSort.manual,
  pinned: pinned,
  totalMovies: 3,
  totalWatched: 1,
  posterPaths: const [],
  isSelf: true,
);

class _FakeRepository implements ShelvesRepository {
  List<Shelf> shelves;
  ({List<int> shelfIds, List<int>? pinnedIds})? reordered;

  _FakeRepository(this.shelves);

  @override
  Future<Result<Paged<Shelf>>> getUserShelves({
    required String userId,
    required int page,
    bool profile = false,
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
  Future<Result<void>> reorderShelves({
    required List<int> shelfIds,
    List<int>? pinnedIds,
  }) async {
    reordered = (shelfIds: shelfIds, pinnedIds: pinnedIds);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late _FakeRepository repository;
  late ShelvesCubit cubit;

  setUp(() {
    repository = _FakeRepository([
      _shelf(1, 'Já assisti', systemType: SystemShelfType.watched),
      _shelf(2, 'Quero ver', systemType: SystemShelfType.watchlist),
      _shelf(3, 'Cult', pinned: true),
    ]);
    cubit = ShelvesCubit(
      getUserShelves: GetUserShelves(repository),
      saveShelf: SaveShelf(repository),
      deleteShelf: DeleteShelf(repository),
      reorderShelves: ReorderShelves(repository),
      addMoviesToShelf: AddMoviesToShelf(repository),
    );
  });

  tearDown(() => cubit.close());

  Widget wrap(Widget child, {Locale locale = const Locale('pt')}) =>
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  Widget screen() =>
      ShelvesScreen(cubit: cubit, onOpenShelf: (_) {}, onAddMovies: (_) {});

  testWidgets(
    'system shelves show their localized name and cannot be deleted',
    (tester) async {
      await tester.pumpWidget(wrap(screen(), locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Watched'), findsOneWidget);
      expect(find.text('Want to watch'), findsOneWidget);
      expect(find.text('1/3 watched'), findsNWidgets(3));

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete shelf'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      expect(find.text('Delete shelf'), findsOneWidget);
      expect(find.text('Unpin'), findsOneWidget);
    },
  );

  testWidgets('the form of a system shelf locks the name and explains why', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ShelfFormBottomSheet(
          shelf: repository.shelves.first,
          onSave: (_) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar estante'), findsOneWidget);
    expect(
      find.text('Estante padrão: não pode ser renomeada nem excluída'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget); // only the description
  });

  testWidgets('pinning keeps the order and sends the new pinned set', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(screen()));
    await tester.pumpAndSettle();

    await cubit.togglePin(repository.shelves[1]);

    expect(repository.reordered?.shelfIds, [1, 2, 3]);
    expect(repository.reordered?.pinnedIds?.toSet(), {2, 3});
  });
}
