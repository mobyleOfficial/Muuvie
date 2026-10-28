import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/shelter/shelter_bloc.dart';
import 'package:gamification_ui/shelter/shelter_screen.dart';
import 'package:gamification_ui/widgets/gamification_labels.dart';
import 'package:get_it/get_it.dart';

/// The Bichinho da Bombonière (F10.1), over the whole screen.
@RoutePage()
class ShelterPage extends StatefulWidget {
  const ShelterPage({super.key});

  @override
  State<ShelterPage> createState() => _ShelterPageState();
}

class _ShelterPageState extends State<ShelterPage> {
  late final ShelterCubit _cubit = ShelterCubit(
    getShelter: GetIt.I<GetPetShelter>(),
    chooseStarter: GetIt.I<ChooseStarterPet>(),
    pinPet: GetIt.I<PinPet>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// The starter is for good: ask before.
  Future<void> _choose(Pet pet) async {
    final l10n = AppLocalizations.of(context);
    var confirmed = false;
    await MuuvieDialog.show(
      context: context,
      title: l10n?.petStarterConfirmTitle(petName(l10n, pet.slug)) ?? '',
      content: l10n?.petStarterConfirmMessage,
      confirmText: l10n?.petStarterConfirm ?? '',
      cancelText: l10n?.maratonaKeep ?? '',
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;
    final error = await _cubit.chooseStarter(pet.slug);
    if (error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n?.maratonaActionError ?? '')));
    }
  }

  @override
  Widget build(BuildContext context) => MuuvieModalScreen(
    title: AppLocalizations.of(context)?.petShelterTitle,
    backgroundColor: Theme.of(context).colorScheme.surface,
    foregroundColor: Theme.of(context).colorScheme.onSurface,
    onClose: () => context.router.maybePop(),
    body: ShelterScreen(
      cubit: _cubit,
      onChooseStarter: _choose,
      onPin: (pet) => _cubit.pin(pet.slug),
    ),
  );
}
