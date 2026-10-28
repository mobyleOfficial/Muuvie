import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/widgets/cineclube_labels.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// "Progresso" (F8.3): the participants' sessions of the movie, newest
/// first. The server hides comments and GIFs that could spoil it until the
/// user finishes the movie or the debate day comes.
class CineClubeProgressTab extends StatefulWidget {
  final CineClube cineclube;
  final CineClubeSession? session;
  final ValueChanged<CineClubeUser> onOpenUser;

  const CineClubeProgressTab({
    super.key,
    required this.cineclube,
    required this.session,
    required this.onOpenUser,
  });

  @override
  State<CineClubeProgressTab> createState() => _CineClubeProgressTabState();
}

class _CineClubeProgressTabState extends State<CineClubeProgressTab>
    with AutomaticKeepAliveClientMixin {
  final _getProgress = GetIt.I<GetCineClubeProgress>();

  bool _loading = true;
  bool _failed = false;
  List<CineClubeLog> _logs = const [];
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
    final result = await _getProgress(
      GetCineClubeProgressParams(
        slug: widget.cineclube.slug,
        sessionId: widget.session?.id,
        page: page,
      ),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _logs = more ? [..._logs, ...data.logs] : data.logs;
          _page = page;
          _hasNext = data.hasNext;
        case Failure():
          _failed = !more;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    if (_loading && _logs.isEmpty) {
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
    if (_logs.isEmpty) {
      return MuuvieEmptyState(
        illustration: MuuvieIllustration.cineclube,
        title: l10n?.cineclubeProgressEmptyTitle ?? '',
        message: l10n?.cineclubeProgressEmptyMessage ?? '',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _logs.length + (_hasNext ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == _logs.length) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: TextButton(
                  onPressed: _loading ? null : () => _load(more: true),
                  child: Text(l10n?.maratonaLoadMore ?? ''),
                ),
              ),
            );
          }
          final log = _logs[index];
          return _LogTile(
            log: log,
            onOpenUser: () => widget.onOpenUser(log.user),
          );
        },
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final CineClubeLog log;
  final VoidCallback onOpenUser;

  const _LogTile({required this.log, required this.onOpenUser});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final comment = log.comment;
    final gif = log.gifUrl;
    final status = log.completed
        ? l10n?.cineclubeProgressCompleted
        : log.percent != null
        ? l10n?.cineclubeWatchedPercent(log.percent!)
        : log.minutesWatched != null
        ? l10n?.cineclubeWatchedMinutes(log.minutesWatched!)
        : l10n?.cineclubeProgressWatching;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onOpenUser,
            child: MuuvieUserAvatar(
              url: log.user.avatarUrl,
              name: log.user.name,
              accentColor: log.user.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: log.user.name,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' · ${status ?? ''} · ${cineclubeDay(log.watchedOn)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (log.emotions.isNotEmpty && l10n != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final emotion in log.emotions)
                          MuuvieTag(label: l10n.emotion(emotion)),
                      ],
                    ),
                  ),
                if (log.hidden)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(MuuvieRadius.small),
                      ),
                      child: Row(
                        children: [
                          const ExcludeSemantics(
                            child: Icon(
                              Icons.visibility_off_outlined,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n?.cineclubeSpoilerHidden ?? '',
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  if (comment != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(comment, style: textTheme.bodyMedium),
                    ),
                  if (gif != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(MuuvieRadius.small),
                        child: Image.network(
                          gif,
                          height: 120,
                          fit: BoxFit.cover,
                          semanticLabel: l10n?.cineclubeGif,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
