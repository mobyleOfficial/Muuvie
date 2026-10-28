import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/widgets/cineclube_labels.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// "Participantes" (F8.3): who takes part, with where each one is in the
/// movie, filtered by that progress ("apenas concluídos" included).
class CineClubeParticipantsTab extends StatefulWidget {
  final CineClube cineclube;
  final CineClubeSession? session;
  final ValueChanged<CineClubeUser> onOpenUser;

  const CineClubeParticipantsTab({
    super.key,
    required this.cineclube,
    required this.session,
    required this.onOpenUser,
  });

  @override
  State<CineClubeParticipantsTab> createState() =>
      _CineClubeParticipantsTabState();
}

class _CineClubeParticipantsTabState extends State<CineClubeParticipantsTab>
    with AutomaticKeepAliveClientMixin {
  final _getParticipants = GetIt.I<GetCineClubeParticipants>();

  SessionProgress? _filter;
  bool _loading = true;
  bool _failed = false;
  List<CineClubeParticipant> _participants = const [];
  int _page = 1;
  bool _hasNext = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loading || !_hasNext)) return;
    setState(() {
      _loading = true;
      if (!more) _failed = false;
    });
    final page = more ? _page + 1 : 1;
    final result = await _getParticipants(
      GetCineClubeParticipantsParams(
        slug: widget.cineclube.slug,
        sessionId: widget.session?.id,
        progress: _filter,
        page: page,
      ),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _participants = more
              ? [..._participants, ...data.participants]
              : data.participants;
          _page = page;
          _hasNext = data.hasNext;
        case Failure():
          _failed = !more;
      }
    });
  }

  void _setFilter(SessionProgress? filter) {
    if (_filter == filter) return;
    _filter = filter;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(l10n?.cineclubeFilterAll ?? ''),
                  selected: _filter == null,
                  onSelected: (_) => _setFilter(null),
                ),
              ),
              for (final progress in [
                SessionProgress.completed,
                SessionProgress.watching,
                SessionProgress.pending,
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(progress.label(l10n)),
                    selected: _filter == progress,
                    onSelected: (_) => _setFilter(progress),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _body(context, l10n)),
      ],
    );
  }

  Widget _body(BuildContext context, AppLocalizations? l10n) {
    if (_loading && _participants.isEmpty) {
      return const Center(child: MuuvieActivityIndicator());
    }
    if (_failed) {
      return MuuvieEmptyState(
        title: l10n?.emptyStateErrorTitle ?? '',
        message: l10n?.emptyStateErrorMessage ?? '',
        action: _load,
        actionLabel: l10n?.emptyStateRetry ?? '',
      );
    }
    if (_participants.isEmpty) {
      return MuuvieEmptyState(
        title: l10n?.cineclubeParticipantsEmpty ?? '',
        message: '',
      );
    }
    final color = cineclubeColor(context, widget.cineclube.accentColor);
    final total = widget.cineclube.sessions.length;

    return ListView.builder(
      itemCount: _participants.length + (_hasNext ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _participants.length) {
          return Center(
            child: TextButton(
              onPressed: _loading ? null : () => _load(more: true),
              child: Text(l10n?.maratonaLoadMore ?? ''),
            ),
          );
        }
        final participant = _participants[index];
        final last = participant.lastWatchedOn;
        return ListTile(
          leading: MuuvieUserAvatar(
            url: participant.user.avatarUrl,
            name: participant.user.name,
            accentColor: participant.user.accentColor,
          ),
          title: Text(participant.user.name),
          subtitle: Text(
            [
              participant.progress.label(l10n),
              if (last != null) cineclubeDay(last),
              if (widget.cineclube.isCycle)
                l10n?.cineclubeCompletedSessions(
                      participant.completedSessions,
                      total,
                    ) ??
                    '',
            ].join(' · '),
          ),
          trailing: Icon(
            participant.progress.icon,
            color: participant.progress == SessionProgress.completed
                ? color
                : null,
          ),
          onTap: () => widget.onOpenUser(participant.user),
        );
      },
    );
  }
}
