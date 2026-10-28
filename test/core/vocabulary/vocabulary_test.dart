import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rating', () {
    test('keeps the picker order of the backend', () {
      expect(Rating.values.map((rating) => rating.wireValue), [
        'favorite',
        'loved',
        'liked',
        'neutral',
        'not_for_me',
        'abandoned',
        'on_hold',
      ]);
    });

    test('only verdicts offer the 100% session', () {
      expect(Rating.values.where((rating) => !rating.isVerdict), [
        Rating.abandoned,
        Rating.onHold,
      ]);
    });
  });

  group('wire values', () {
    test('round-trip for every enum', () {
      for (final value in ContentVisibility.values) {
        expect(ContentVisibility.fromWireValue(value.wireValue), value);
      }
      for (final value in WatchMode.values) {
        expect(WatchMode.fromWireValue(value.wireValue), value);
      }
      for (final value in WatchVenue.values) {
        expect(WatchVenue.fromWireValue(value.wireValue), value);
      }
      for (final value in WatchStatus.values) {
        expect(WatchStatus.fromWireValue(value.wireValue), value);
      }
      for (final value in SystemShelfType.values) {
        expect(SystemShelfType.fromWireValue(value.wireValue), value);
      }
      for (final value in Rating.values) {
        expect(Rating.fromWireValue(value.wireValue), value);
      }
      for (final value in ShelfSort.values) {
        expect(ShelfSort.fromWireValue(value.wireValue), value);
      }
      for (final value in Emotion.values) {
        expect(Emotion.fromWireValue(value.wireValue), value);
        expect(Emotion.fromId(value.id), value);
      }
    });

    test('match the backend contract', () {
      expect(ContentVisibility.mutual.wireValue, 'mutual');
      expect(Rating.onHold.wireValue, 'on_hold');
      expect(WatchStatus.wantToWatch.wireValue, 'want_to_watch');
      expect(Rating.notForMe.wireValue, 'not_for_me');
      expect(WatchVenue.physicalMedia.wireValue, 'physical_media');
      expect(ShelfSort.releaseYear.wireValue, 'release_year');
      expect(Emotion.freakOut.wireValue, 'freak_out');
    });

    test('unknown values return null', () {
      expect(ContentVisibility.fromWireValue('private'), isNull);
      expect(Emotion.fromId(44), isNull);
    });
  });

  test('emotion ids are stable and sequential', () {
    expect(Emotion.values.length, 44);
    expect(
      Emotion.values.map((emotion) => emotion.id),
      List.generate(44, (i) => i),
    );
    expect(Emotion.fromId(0), Emotion.curiosity);
    expect(Emotion.fromId(43), Emotion.apathy);
  });

  group('labels', () {
    for (final locale in AppLocalizations.supportedLocales) {
      test(
        'every value has a non-empty label in ${locale.languageCode}',
        () async {
          final l10n = await AppLocalizations.delegate.load(locale);
          final labels = [
            ...ContentVisibility.values.map(l10n.contentVisibility),
            ...WatchMode.values.map(l10n.watchMode),
            ...WatchVenue.values.map(l10n.watchVenue),
            ...WatchStatus.values.map(l10n.watchStatus),
            ...SystemShelfType.values.map(l10n.systemShelf),
            ...Rating.values.map(l10n.rating),
            ...ShelfSort.values.map(l10n.shelfSort),
            ...Emotion.values.map(l10n.emotion),
          ];
          expect(labels.where((label) => label.trim().isEmpty), isEmpty);
          expect(Emotion.values.map(l10n.emotion).toSet().length, 44);
        },
      );
    }

    test('portuguese uses the product names', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('pt'));
      expect(l10n.systemShelf(SystemShelfType.watched), 'Já assisti');
      expect(l10n.systemShelf(SystemShelfType.watchlist), 'Quero ver');
      expect(l10n.rating(Rating.onHold), 'Na geladeira');
      expect(l10n.rating(Rating.favorite), 'Favoritado');
      expect(l10n.rating(Rating.notForMe), 'Não foi pra mim');
    });
  });
}
