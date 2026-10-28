import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/shelter/shelter_bloc.dart';
import 'package:gamification_ui/shelter/shelter_state.dart';
import 'package:gamification_ui/widgets/gamification_labels.dart';

/// The starter pack ("baldes de pipoca") until one is chosen; then the
/// pinned bichinho with its level and every other one, locked or not.
class ShelterScreen extends StatelessWidget {
  final ShelterCubit cubit;
  final ValueChanged<Pet> onChooseStarter;
  final ValueChanged<Pet> onPin;

  const ShelterScreen({
    super.key,
    required this.cubit,
    required this.onChooseStarter,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ShelterCubit, ShelterState>(
      bloc: cubit,
      builder: (context, state) => switch (state) {
        ShelterLoading() => const Center(child: MuuvieActivityIndicator()),
        ShelterError() => MuuvieEmptyState(
          title: l10n?.emptyStateErrorTitle ?? '',
          message: l10n?.emptyStateErrorMessage ?? '',
          action: cubit.load,
          actionLabel: l10n?.emptyStateRetry ?? '',
        ),
        ShelterSuccess(:final shelter, :final busy) =>
          shelter.starterChosen
              ? _Shelter(shelter: shelter, busy: busy, onPin: onPin)
              : _StarterPack(
                  pets: shelter.pets,
                  busy: busy,
                  onChoose: onChooseStarter,
                ),
      },
    );
  }
}

class _StarterPack extends StatelessWidget {
  final List<Pet> pets;
  final bool busy;
  final ValueChanged<Pet> onChoose;

  const _StarterPack({
    required this.pets,
    required this.busy,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n?.petStarterTitle ?? '',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.petStarterMessage ?? '',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        for (final pet in pets)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: PetAvatar(pet: pet, size: 56),
              title: Text(petName(l10n, pet.slug)),
              subtitle: Text(petDescription(l10n, pet.slug)),
              trailing: const Icon(Icons.chevron_right),
              onTap: busy ? null : () => onChoose(pet),
            ),
          ),
      ],
    );
  }
}

class _Shelter extends StatelessWidget {
  final PetShelter shelter;
  final bool busy;
  final ValueChanged<Pet> onPin;

  const _Shelter({
    required this.shelter,
    required this.busy,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final pinned = shelter.pinned;
    final unlocked = shelter.pets.where((p) => p.unlocked).toList();
    final locked = shelter.pets.where((p) => !p.unlocked).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pinned != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PetAvatar(pet: pinned, size: 112),
                  const SizedBox(height: 12),
                  Text(petName(l10n, pinned.slug), style: textTheme.titleLarge),
                  Text(
                    l10n?.petLevel(pinned.level) ?? '',
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: pinned.levelProgress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    semanticsLabel: l10n?.petXp(pinned.xp, pinned.nextLevelXp),
                  ),
                  const SizedBox(height: 4),
                  ExcludeSemantics(
                    child: Text(
                      l10n?.petXp(pinned.xp, pinned.nextLevelXp) ?? '',
                      style: textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.petXpHelp ?? '',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        _Section(title: l10n?.petUnlocked(unlocked.length) ?? ''),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final pet in unlocked)
              _PetTile(
                pet: pet,
                subtitle: l10n?.petLevel(pet.level) ?? '',
                onTap: busy || pet.pinned ? null : () => onPin(pet),
                tooltip: pet.pinned ? null : l10n?.petPin,
              ),
          ],
        ),
        if (locked.isNotEmpty) ...[
          _Section(title: l10n?.petLocked ?? ''),
          for (final pet in locked)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: PetAvatar(pet: pet, size: 44),
              title: Text(
                '${petName(l10n, pet.slug)} · ${petRarity(l10n, pet.rarity)}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(petRule(l10n, pet.rule)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: pet.unlockProgress,
                    borderRadius: BorderRadius.circular(4),
                    semanticsLabel: '${pet.progress} / ${pet.rule.target}',
                  ),
                ],
              ),
              trailing: Text('${pet.progress}/${pet.rule.target}'),
            ),
        ],
      ],
    );
  }
}

class _PetTile extends StatelessWidget {
  final Pet pet;
  final String subtitle;
  final VoidCallback? onTap;
  final String? tooltip;

  const _PetTile({
    required this.pet,
    required this.subtitle,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tile = InkWell(
      borderRadius: BorderRadius.circular(MuuvieRadius.medium),
      onTap: onTap,
      child: SizedBox(
        width: 96,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              PetAvatar(pet: pet, size: 56),
              const SizedBox(height: 4),
              Text(
                petName(l10n, pet.slug),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
    final hint = tooltip;
    return hint == null ? tile : Tooltip(message: hint, child: tile);
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
    child: Semantics(
      header: true,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
