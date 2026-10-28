import 'package:auto_route/auto_route.dart';
import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:cineclubes_ui/detail/cineclube_detail_bloc.dart';
import 'package:cineclubes_ui/detail/cineclube_detail_screen.dart';
import 'package:cineclubes_ui/detail/cineclube_detail_state.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// A CineClube, opened from Programação, the feed or `/c/<slug>` (F8.3).
@RoutePage()
class CineClubeDetailPage extends StatefulWidget {
  final String slug;

  /// For the app bar until the CineClube loads.
  final String title;

  const CineClubeDetailPage({
    super.key,
    @PathParam('slug') required this.slug,
    this.title = '',
  });

  @override
  State<CineClubeDetailPage> createState() => _CineClubeDetailPageState();
}

class _CineClubeDetailPageState extends State<CineClubeDetailPage> {
  late final CineClubeDetailCubit _cubit = CineClubeDetailCubit(
    slug: widget.slug,
    getCineClube: GetIt.I<GetCineClube>(),
    joinCineClube: GetIt.I<JoinCineClube>(),
    leaveCineClube: GetIt.I<LeaveCineClube>(),
    cancelCineClube: GetIt.I<CancelCineClube>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  CineClube? get _cineclube => switch (_cubit.state) {
    final CineClubeDetailSuccess success => success.cineclube,
    _ => null,
  };

  void _snack(String? message) {
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _join() async {
    final cineclube = _cineclube;
    if (cineclube == null || !await AuthGate.check(context) || !mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    String? password;
    if (cineclube.hasPassword) {
      password = await MuuvieTextPromptDialog.show(
        context,
        title: l10n?.maratonaPassword ?? '',
        confirmLabel: l10n?.maratonaJoin ?? '',
        keyboardType: TextInputType.visiblePassword,
        parse: (text) => text.isEmpty ? null : text,
      );
      if (password == null || !mounted) return;
    }
    final error = await _cubit.join(password: password);
    if (error == null) {
      _snack(l10n?.cineclubeJoined);
      return;
    }
    _snack(switch (error) {
      AppError.forbidden => l10n?.maratonaWrongPassword,
      AppError.conflict => l10n?.cineclubeClosed,
      _ => l10n?.maratonaActionError,
    });
  }

  Future<void> _leave() async {
    final l10n = AppLocalizations.of(context);
    var confirmed = false;
    await MuuvieDialog.show(
      context: context,
      title: l10n?.cineclubeLeaveTitle ?? '',
      content: l10n?.cineclubeLeaveMessage,
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
      title: l10n?.cineclubeCancel ?? '',
      content: l10n?.cineclubeCancelMessage,
      confirmText: l10n?.cineclubeCancel ?? '',
      cancelText: l10n?.maratonaKeep ?? '',
      onConfirm: () => confirmed = true,
    );
    if (!confirmed) return;
    final error = await _cubit.cancel();
    if (error != null) _snack(l10n?.maratonaActionError);
  }

  Future<void> _edit() async {
    final saved = await context.router.push<bool>(
      CineClubeEditorRoute(slug: widget.slug),
    );
    if (saved == true && mounted) _cubit.load();
  }

  void _openLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => CineClubeDetailScreen(
    cubit: _cubit,
    onJoin: _join,
    onLeave: _leave,
    onEdit: _edit,
    onCancel: _cancel,
    onOpenUser: (user) => context.router.push(
      PublicProfileRoute(userId: user.id, displayName: user.name),
    ),
    onOpenMovie: (movie) => context.router.push(
      MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
    ),
    onOpenLink: _openLink,
  );
}
