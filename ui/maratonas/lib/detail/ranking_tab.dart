import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';

/// "Ranking" (F7.6): participants by challenges done, and the teams when the
/// maratona has them. A tie shares the position.
class MaratonaRankingTab extends StatefulWidget {
  final Maratona maratona;
  final ValueChanged<MaratonaUser> onOpenUser;

  const MaratonaRankingTab({
    super.key,
    required this.maratona,
    required this.onOpenUser,
  });

  @override
  State<MaratonaRankingTab> createState() => _MaratonaRankingTabState();
}

class _MaratonaRankingTabState extends State<MaratonaRankingTab> {
  final _getRanking = GetIt.I<GetMaratonaRanking>();
  final _getTeamRanking = GetIt.I<GetTeamRanking>();

  bool _teams = false;
  bool _loading = true;
  bool _failed = false;
  List<RankingEntry> _entries = const [];
  List<TeamRankingEntry> _teamEntries = const [];
  int _page = 1;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final slug = widget.maratona.slug;
    if (_teams) {
      final result = await _getTeamRanking(slug);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = result is Failure;
        if (result case Success(:final data)) _teamEntries = data;
      });
      return;
    }
    final page = more ? _page + 1 : 1;
    final result = await _getRanking(
      GetMaratonaRankingParams(slug: slug, page: page),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _entries = more ? [..._entries, ...data.entries] : data.entries;
          _page = page;
          _hasNext = data.hasNext;
        case Failure():
          _failed = !more;
      }
    });
  }

  void _show(bool teams) {
    if (_teams == teams) return;
    _teams = teams;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasTeams = widget.maratona.teams.isNotEmpty;

    return Column(
      children: [
        if (hasTeams)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(l10n?.maratonaRankingUsers ?? ''),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(l10n?.maratonaTeams ?? ''),
                ),
              ],
              selected: {_teams},
              onSelectionChanged: (selection) => _show(selection.first),
            ),
          ),
        Expanded(child: _body(l10n)),
      ],
    );
  }

  Widget _body(AppLocalizations? l10n) {
    final isEmpty = _teams ? _teamEntries.isEmpty : _entries.isEmpty;
    if (_loading && isEmpty) {
      return const Center(child: MuuvieActivityIndicator());
    }
    if (_failed) {
      return MuuvieEmptyState(
        illustration: MuuvieIllustration.error,
        title: l10n?.emptyStateErrorTitle ?? '',
        message: l10n?.emptyStateErrorMessage ?? '',
        action: _load,
        actionLabel: l10n?.emptyStateRetry ?? '',
      );
    }
    final nobody = _teams
        ? _teamEntries.every((entry) => entry.completed == 0)
        : _entries.every((entry) => entry.completed == 0);
    if (nobody) {
      return MuuvieEmptyState(
        illustration: MuuvieIllustration.ranking,
        title: l10n?.maratonaTabRanking ?? '',
        message: l10n?.maratonaRankingEmpty ?? '',
      );
    }

    if (_teams) {
      return ListView(
        children: [
          for (final entry in _teamEntries)
            ListTile(
              leading: _Position(position: entry.position),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: maratonaColor(context, entry.team.color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.team.name)),
                ],
              ),
              subtitle: Text(l10n?.maratonaTeamMembers(entry.members) ?? ''),
              trailing: Text(
                l10n?.maratonaChallengesCount(entry.completed) ?? '',
              ),
            ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _entries.length + (_hasNext ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _entries.length) {
          return Center(
            child: _loading
                ? const MuuvieActivityIndicator()
                : TextButton(
                    onPressed: () => _load(more: true),
                    child: Text(l10n?.maratonaLoadMore ?? ''),
                  ),
          );
        }
        final entry = _entries[index];
        final team = widget.maratona.team(entry.teamId);
        return ListTile(
          onTap: () => widget.onOpenUser(entry.user),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Position(position: entry.position),
              const SizedBox(width: 8),
              MuuvieUserAvatar(
                url: entry.user.avatarUrl,
                name: entry.user.name,
                accentColor: entry.user.accentColor,
              ),
            ],
          ),
          title: Text(entry.user.name),
          subtitle: team == null ? null : Text(team.name),
          trailing: Text(l10n?.maratonaChallengesCount(entry.completed) ?? ''),
        );
      },
    );
  }
}

class _Position extends StatelessWidget {
  final int position;

  const _Position({required this.position});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final podium = position <= 3;

    return SizedBox(
      width: 36,
      child: Text(
        l10n?.maratonaRankingPosition(position) ?? '$position',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: podium ? FontWeight.bold : null,
          color: podium ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
