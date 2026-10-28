import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/golden.dart';

void main() {
  setUpAll(useTolerantGoldens);

  /// SVGs are decoded off the test clock; let the loads finish, then repaint.
  Future<void> settleSvgs(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  Widget gallery() => SingleChildScrollView(
    child: Wrap(
      spacing: 8,
      runSpacing: 24,
      children: [
        for (final illustration in MuuvieIllustration.values)
          SizedBox(
            width: 300,
            child: MuuvieEmptyState(
              title: illustration.name,
              message: 'Nada por aqui ainda.',
              illustration: illustration,
            ),
          ),
      ],
    ),
  );

  for (final brightness in Brightness.values) {
    testWidgets('illustrations golden (${brightness.name})', (tester) async {
      tester.view.physicalSize = const Size(1600, 2000);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(goldenApp(gallery(), brightness: brightness));
      await settleSvgs(tester);

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/muuvie_empty_state_${brightness.name}.png'),
      );
    });
  }

  testWidgets('shows the default mascot above the copy', (tester) async {
    await tester.pumpWidget(
      goldenApp(
        const MuuvieEmptyState(title: 'Vazio', message: 'Nada aqui.'),
        brightness: Brightness.light,
      ),
    );

    expect(find.byType(MuuvieIllustrationView), findsOneWidget);
    expect(find.text('Vazio'), findsOneWidget);
  });

  testWidgets('renders copy only when illustration is null', (tester) async {
    await tester.pumpWidget(
      goldenApp(
        const MuuvieEmptyState(
          title: 'Vazio',
          message: 'Nada aqui.',
          illustration: null,
        ),
        brightness: Brightness.light,
      ),
    );

    expect(find.byType(MuuvieIllustrationView), findsNothing);
    expect(find.text('Nada aqui.'), findsOneWidget);
  });

  testWidgets('illustration is hidden from screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      goldenApp(
        const MuuvieIllustrationView(illustration: MuuvieIllustration.error),
        brightness: Brightness.dark,
      ),
    );

    expect(
      find.descendant(
        of: find.byType(MuuvieIllustrationView),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
