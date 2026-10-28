import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/widgets/gamification_labels.dart';

import '../../helpers/golden.dart';

const _pets = [
  Pet(slug: 'pipoca-doce', rarity: PetRarity.starter, unlocked: true),
  Pet(slug: 'pipoca-salgada', rarity: PetRarity.starter, unlocked: true),
  Pet(slug: 'pipoca-caramelo', rarity: PetRarity.starter, unlocked: true),
  Pet(slug: 'claquete', unlocked: true, pinned: true),
  Pet(slug: 'ingresso', unlocked: true),
  Pet(slug: 'rolo-de-filme', unlocked: true),
  Pet(slug: 'lanterninha', unlocked: true),
  Pet(slug: 'fantasminha', rarity: PetRarity.rare, unlocked: true),
  Pet(slug: 'robozinho', rarity: PetRarity.rare, unlocked: true),
  Pet(slug: 'dinossauro', rarity: PetRarity.rare, unlocked: true),
  Pet(slug: 'coruja', rarity: PetRarity.rare),
  Pet(slug: 'trofeu', rarity: PetRarity.legendary, unlocked: true),
  Pet(slug: 'projetor', rarity: PetRarity.legendary, unlocked: true),
  Pet(slug: 'estatueta', rarity: PetRarity.legendary),
];

void main() {
  setUpAll(useTolerantGoldens);

  /// SVGs are decoded off the test clock; let the loads finish, then repaint.
  Future<void> settleSvgs(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    testWidgets('every vaquinha has its art (${brightness.name})', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 640);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        goldenApp(
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final pet in _pets) PetAvatar(pet: pet, size: 72),
              const PetAvatar(pet: Pet(slug: 'coruja'), size: 24),
            ],
          ),
          brightness: brightness,
        ),
      );
      await settleSvgs(tester);

      expect(find.byType(MuuvieMascotArt), findsNWidgets(_pets.length + 1));
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/pet_avatars_${brightness.name}.png'),
      );
    });
  }

  testWidgets('a locked vaquinha shows a lock and keeps its name', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      goldenApp(
        const PetAvatar(pet: Pet(slug: 'coruja', rarity: PetRarity.rare)),
        brightness: Brightness.light,
      ),
    );

    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.bySemanticsLabel('Coruja'), findsOneWidget);
    handle.dispose();
  });

  test('an unknown slug falls back to a starter', () {
    expect(PetArt.asset('novidade'), 'assets/pets/pipoca-doce.svg');
    expect(PetArt.asset('coruja'), 'assets/pets/coruja.svg');
  });
}
