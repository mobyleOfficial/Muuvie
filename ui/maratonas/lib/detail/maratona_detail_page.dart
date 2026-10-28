import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/detail/challenge_sheet.dart';
import 'package:maratonas_ui/detail/join_sheet.dart';
import 'package:maratonas_ui/detail/maratona_detail_bloc.dart';
import 'package:maratonas_ui/detail/maratona_detail_screen.dart';
import 'package:maratonas_ui/detail/maratona_detail_state.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// A maratona, opened from Programação, the feed or `/m/<slug>` (F7.3).
@RoutePage()
class MaratonaDetailPage extends StatefulWidget {
  final String slug;

  /// For the app bar until the maratona loads.
  final String title;

  const MaratonaDetailPage({
    super.key,
    @PathParam('slug') required this.slug,
    this.title = '',
  });

  @override
  State<MaratonaDetailPage> createState() => _MaratonaDetailPageState();
}

class _MaratonaDetailPageState extends State<MaratonaDetailPage> {
  late final MaratonaDetailCubit _cubit = MaratonaDetailCubit(
    slug: widget.slug,
    getMaratona: GetIt.I<GetMaratona>(),
    getChallenges: GetIt.I<GetMaratonaChallenges>(),
    joinMaratona: GetIt.I<JoinMaratona>(),
    leaveMaratona: GetIt.I<LeaveMaratona>(),
    cancelMaratona: GetIt.I<CancelMaratona>(),
    setChallengeLink: GetIt.I<SetChallengeLink>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Maratona? get _maratona => switch (_cubit.state) {
    final MaratonaDetailSuccess success => success.maratona,
    _ => null,
  };

  void _snack(String? message) {
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _join() async {
    final maratona = _maratona;
    if (maratona == null || !await AuthGate.check(context) || !mounted) return;
    final choice = await JoinSheet.show(context, maratona);
    if (choice == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final error = await _cubit.join(
      levelId: choice.levelId,
      teamId: choice.teamId,
      password: choice.password,
    );
    if (error == null) return;
    _snack(switch (error) {
      AppError.forbidden => l10n?.maratonaWrongPassword,
      AppError.conflict => l10n?.maratonaClosed,
      _ => l10n?.maratonaActionError,
    });
  }

  Future<void> _leave() async {
    final l10n = AppLocalizations.of(context);
    var confirmed = false;
    await MuuvieDialog.show(
      context: context,
      title: l10n?.maratonaLeaveTitle ?? '',
      content: l10n?.maratonaLeaveMessage,
      confirmText: l10n?.maratonaLeave ?? '',
      cancelText: l10n?.maratonaKeep ?? '',
      onConfirm: () => confirmed = true,
    );
    if (!confirmed) return;
    final error = await _cubit.leave();
    if (error != null) _snack(l10n?.maratonaActionError);
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    var confirmed = false;
    await MuuvieDialog.show(
      context: context,
      title: l10n?.maratonaCancel ?? '',
      content: l10n?.maratonaCancelMessage,
      confirmText: l10n?.maratonaCancelConfirm ?? '',
      cancelText: l10n?.maratonaKeep ?? '',
      onConfirm: () => confirmed = true,
    );
    if (!confirmed) return;
    final error = await _cubit.cancel();
    if (error != null) _snack(l10n?.maratonaActionError);
  }

  Future<void> _edit() async {
    final saved = await context.router.push<bool>(
      MaratonaEditorRoute(slug: widget.slug),
    );
    if (saved == true && mounted) _cubit.load();
  }

  void _openMovie(int movieId, String title) => context.router.push(
    MovieDetailRoute(movieId: movieId, movieTitle: title),
  );

  @override
  Widget build(BuildContext context) => MaratonaDetailScreen(
    cubit: _cubit,
    onJoin: _join,
    onLeave: _leave,
    onEdit: _edit,
    onCancel: _cancel,
    onOpenUser: (user) => context.router.push(
      PublicProfileRoute(userId: user.id, displayName: user.name),
    ),
    onOpenMovie: _openMovie,
    onOpenQueue: (maratona) {
      final shelfId = maratona.me?.queueShelfId;
      if (shelfId == null) return;
      context.router.push(
        ShelfDetailRoute(
          shelfId: shelfId,
          shelfName: AppLocalizations.of(context)?.maratonaTabQueue ?? '',
          shelfColor: maratona.accentColor,
        ),
      );
    },
    onOpenChallenge: (challenge) => ChallengeSheet.show(
      context,
      cubit: _cubit,
      challengeId: challenge.id,
      onOpenMovie: (link) => _openMovie(link.movieId, link.title),
    ),
    onOpenLink: (link) {
      final uri = Uri.tryParse(link);
      if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
    },
  );
}
