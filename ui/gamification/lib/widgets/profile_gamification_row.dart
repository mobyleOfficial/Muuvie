import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/widgets/gamification_labels.dart';
import 'package:get_it/get_it.dart';

/// Where the profile meets phase 10: the pinned bichinho of anyone, and on
/// my profile the shortcuts to the shelter, the missions, the Caderninho,
/// the watch party and the poster game.
class ProfileGamificationRow extends StatefulWidget {
  /// `me` on my profile.
  final String userId;
  final VoidCallback onOpenShelter;
  final VoidCallback onOpenMissions;
  final VoidCallback onOpenDiary;
  final VoidCallback onOpenParty;
  final VoidCallback onOpenPosterGame;

  const ProfileGamificationRow({
    super.key,
    required this.userId,
    required this.onOpenShelter,
    required this.onOpenMissions,
    required this.onOpenDiary,
    required this.onOpenParty,
    required this.onOpenPosterGame,
  });

  @override
  State<ProfileGamificationRow> createState() => _ProfileGamificationRowState();
}

class _ProfileGamificationRowState extends State<ProfileGamificationRow> {
  Pet? _pinned;

  bool get _isSelf => widget.userId == 'me';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await GetIt.I<GetProfilePets>()(widget.userId);
    if (!mounted) return;
    if (result case Success(:final data)) setState(() => _pinned = data.pinned);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pinned = _pinned;
    if (!_isSelf && pinned == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          if (pinned != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: PetAvatar(pet: pinned, size: 24),
                label: Text(
                  '${petName(l10n, pinned.slug)} · ${l10n?.petLevel(pinned.level) ?? ''}',
                ),
                onPressed: _isSelf ? () => widget.onOpenShelter() : null,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Text('🍿'),
                label: Text(l10n?.petAdopt ?? ''),
                onPressed: () => widget.onOpenShelter(),
              ),
            ),
          if (_isSelf) ...[
            _Shortcut(
              icon: Icons.flag_outlined,
              label: l10n?.missionsTitle ?? '',
              onTap: widget.onOpenMissions,
            ),
            _Shortcut(
              icon: Icons.edit_note,
              label: l10n?.diaryTitle ?? '',
              onTap: widget.onOpenDiary,
            ),
            _Shortcut(
              icon: Icons.groups_outlined,
              label: l10n?.partyTitle ?? '',
              onTap: widget.onOpenParty,
            ),
            _Shortcut(
              icon: Icons.image_search,
              label: l10n?.posterGameTitle ?? '',
              onTap: widget.onOpenPosterGame,
            ),
          ],
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    ),
  );
}
