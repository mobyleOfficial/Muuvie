import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/golden.dart';

void main() {
  setUpAll(useTolerantGoldens);

  Widget gallery() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DefaultTabController(
          length: 2,
          child: MuuvieTabbedHeader(
            title: 'Maratona do Terror',
            subtitle: '1 a 31 de outubro',
            accentColor: Color(0xFFE53935),
            tabs: ['Desafios', 'Ranking'],
          ),
        ),
        const SizedBox(height: 16),
        const MuuvieMovieProgressCard(
          title: 'O Iluminado',
          subtitle: '1980 · Stanley Kubrick',
          minutesWatched: 54,
          runtimeMinutes: 144,
        ),
        const MuuvieMovieProgressCard(
          title: 'Suspiria',
          subtitle: '1977 · Dario Argento',
          completed: true,
          rating: Rating.loved,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final rating in Rating.values)
              MuuvieRatingBadge(rating: rating),
            for (final visibility in ContentVisibility.values)
              MuuvieVisibilityChip(visibility: visibility),
          ],
        ),
        const SizedBox(height: 16),
        MuuvieVisibilitySelector(
          value: ContentVisibility.mutual,
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        MuuvieColorPicker(
          selected: MuuvieColorPicker.presets[5],
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        MuuvieEmotionPicker(
          selected: const {Emotion.tension, Emotion.fear},
          recent: const [Emotion.fear, Emotion.joy],
          onChanged: (_) {},
        ),
      ],
    ),
  );

  for (final brightness in Brightness.values) {
    testWidgets('components golden (${brightness.name})', (tester) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(goldenApp(gallery(), brightness: brightness));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/maratona_components_${brightness.name}.png'),
      );
    });
  }

  group('MuuvieEmotionPicker', () {
    Future<Set<Emotion>> tapChip(
      WidgetTester tester, {
      required Set<Emotion> selected,
      required String label,
    }) async {
      var result = selected;
      await tester.pumpWidget(
        goldenApp(
          SingleChildScrollView(
            child: MuuvieEmotionPicker(
              selected: selected,
              onChanged: (next) => result = next,
            ),
          ),
          brightness: Brightness.light,
        ),
      );
      await tester.tap(find.text(label));
      return result;
    }

    testWidgets('adds and removes an emotion', (tester) async {
      expect(await tapChip(tester, selected: {}, label: 'Medo'), {
        Emotion.fear,
      });
      expect(
        await tapChip(tester, selected: {Emotion.fear}, label: 'Medo'),
        isEmpty,
      );
    });

    testWidgets('never goes past six emotions', (tester) async {
      final six = Emotion.values.take(6).toSet();
      await tester.pumpWidget(
        goldenApp(
          SingleChildScrollView(
            child: MuuvieEmotionPicker(selected: six, onChanged: (_) {}),
          ),
          brightness: Brightness.light,
        ),
      );

      final seventh = tester.widget<FilterChip>(
        find.ancestor(of: find.text('Medo'), matching: find.byType(FilterChip)),
      );
      expect(seventh.onSelected, isNull);
      expect(find.text('6 de 6 emoções'), findsOneWidget);
    });
  });

  testWidgets('color swatches are labeled and expose selection', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      goldenApp(
        MuuvieColorPicker(
          selected: MuuvieColorPicker.presets.first,
          onChanged: (_) {},
        ),
        brightness: Brightness.light,
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Cor 1 de 12')),
      isSemantics(
        label: 'Cor 1 de 12',
        isSelected: true,
        isButton: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('progress card reads title and progress to screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      goldenApp(
        const MuuvieMovieProgressCard(
          title: 'O Iluminado',
          minutesWatched: 54,
          runtimeMinutes: 144,
        ),
        brightness: Brightness.light,
      ),
    );

    expect(find.bySemanticsLabel('O Iluminado, 54 de 144 min'), findsOneWidget);
    semantics.dispose();
  });
}
