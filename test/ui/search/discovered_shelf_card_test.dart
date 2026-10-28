import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search/discover/discover_widgets.dart';
import 'package:shelves/shelves.dart';

Shelf _shelf({String? ownerName}) => Shelf(
  id: 9,
  ownerId: 'bia',
  name: 'Noir',
  visibility: ContentVisibility.public,
  sortMode: ShelfSort.manual,
  pinned: false,
  totalMovies: 4,
  totalWatched: 1,
  posterPaths: const [],
  isSelf: false,
  ownerName: ownerName,
);

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SizedBox(width: 260, height: 168, child: child)),
);

void main() {
  testWidgets('a popular shelf names its owner (F14.5)', (tester) async {
    await tester.pumpWidget(
      _wrap(DiscoveredShelfCard(shelf: _shelf(ownerName: 'Bia Lima'))),
    );

    expect(find.text('Noir'), findsOneWidget);
    expect(find.textContaining('de Bia Lima · '), findsOneWidget);
  });

  testWidgets('without the owner the card keeps the progress only', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(DiscoveredShelfCard(shelf: _shelf())));

    expect(find.textContaining('de Bia Lima'), findsNothing);
  });

  test(
    'the hub section is called Estantes mais populares in every language',
    () async {
      expect(
        (await AppLocalizations.delegate.load(
          const Locale('pt'),
        )).discoverShelves,
        'Estantes mais populares',
      );
      expect(
        (await AppLocalizations.delegate.load(
          const Locale('en'),
        )).discoverShelves,
        'Most popular shelves',
      );
      expect(
        (await AppLocalizations.delegate.load(
          const Locale('es'),
        )).discoverShelves,
        'Estantes más populares',
      );
    },
  );
}
