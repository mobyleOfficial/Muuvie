import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/party/watch_party_bloc.dart';
import 'package:gamification_ui/party/watch_party_screen.dart';
import 'package:get_it/get_it.dart';

/// The watch party (F10.4) over the whole screen. With [code] it joins that
/// room; with [movieId] it offers to create one for the movie.
@RoutePage()
class WatchPartyPage extends StatefulWidget {
  final String? code;
  final int? movieId;
  final String? movieTitle;

  const WatchPartyPage({super.key, this.code, this.movieId, this.movieTitle});

  @override
  State<WatchPartyPage> createState() => _WatchPartyPageState();
}

class _WatchPartyPageState extends State<WatchPartyPage> {
  late final WatchPartyCubit _cubit = WatchPartyCubit(
    actions: GetIt.I<WatchPartyActions>(),
  );

  @override
  void initState() {
    super.initState();
    final code = widget.code;
    if (code != null) _cubit.join(code);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context);
    final seconds = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final value in const [10, 30, 60, 300])
              ListTile(
                title: Text(l10n?.partyStartIn(value) ?? ''),
                onTap: () => Navigator.of(context).pop(value),
              ),
          ],
        ),
      ),
    );
    if (seconds == null) return;
    final error = await _cubit.start(seconds);
    if (error != null) _snack(l10n?.maratonaActionError);
  }

  Future<void> _send(String body) async {
    final error = await _cubit.send(body);
    if (error != null && mounted) {
      _snack(AppLocalizations.of(context)?.maratonaActionError);
    }
  }

  void _snack(String? message) {
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _close() async {
    await _cubit.leave();
    if (mounted) context.router.maybePop();
  }

  void _copy(String code) {
    Clipboard.setData(ClipboardData(text: code));
    _snack(AppLocalizations.of(context)?.partyCodeCopied);
  }

  @override
  Widget build(BuildContext context) => MuuvieModalScreen(
    title: AppLocalizations.of(context)?.partyTitle,
    backgroundColor: Theme.of(context).colorScheme.surface,
    foregroundColor: Theme.of(context).colorScheme.onSurface,
    onClose: _close,
    body: WatchPartyScreen(
      cubit: _cubit,
      movieTitle: widget.movieTitle,
      onCreate: (title) => _cubit.create(title: title, movieId: widget.movieId),
      onJoin: _cubit.join,
      onStart: _start,
      onSend: _send,
      onCopyCode: _copy,
      errorText: (error) => switch (error) {
        AppError.notFound => AppLocalizations.of(context)?.partyNotFound,
        AppError.conflict => AppLocalizations.of(context)?.partyFull,
        _ => AppLocalizations.of(context)?.maratonaActionError,
      },
    ),
  );
}
