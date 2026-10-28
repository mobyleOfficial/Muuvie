import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:locadoras_ui/locadoras_router.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:social/social_bloc.dart';
import 'package:social/social_screen.dart';
import 'package:social_network/social_network.dart';

/// The Atts tab (F6.2).
@RoutePage()
class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  late final SocialCubit _cubit = SocialCubit(
    getFeed: GetIt.I<GetFeed>(),
    toggleLove: GetIt.I<ToggleActivityLove>(),
    hideActivity: GetIt.I<HideActivity>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _toggleHidden(Activity activity) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final ok = await _cubit.toggleHidden(activity);
    if (!mounted || (ok && activity.hidden)) return;
    final message = ok
        ? l10n?.activityHiddenSnack
        : l10n?.emptyStateErrorMessage;
    messenger.showSnackBar(SnackBar(content: Text(message ?? '')));
  }

  @override
  Widget build(BuildContext context) => SocialScreen(
    cubit: _cubit,
    onOpenProfile: (user) => context.router.push(
      PublicProfileRoute(userId: user.id, displayName: user.name),
    ),
    onOpenMovie: (movie) => context.router.push(
      MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
    ),
    onOpenShelf: (shelf) => context.router.push(
      ShelfDetailRoute(
        shelfId: shelf.id,
        shelfName: shelf.name,
        shelfColor: shelf.color,
      ),
    ),
    onOpenMaratona: (maratona) => context.router.push(
      MaratonaDetailRoute(slug: maratona.slug, title: maratona.title),
    ),
    onOpenCineClube: (cineclube) => context.router.push(
      CineClubeDetailRoute(slug: cineclube.slug, title: cineclube.title),
    ),
    onOpenLocadora: (locadora) => context.router.push(
      LocadoraDetailRoute(
        locadoraId: locadora.id,
        locadoraName: locadora.name,
        onOpenShelf: (context, shelf) => context.router.push(
          ShelfDetailRoute(
            shelfId: shelf.id,
            shelfName: shelf.name,
            shelfColor: shelf.color,
          ),
        ),
        onOpenOwner: (context, locadora) => context.router.push(
          PublicProfileRoute(
            userId: locadora.ownerId,
            displayName: locadora.ownerUsername,
          ),
        ),
      ),
    ),
    onToggleHidden: _toggleHidden,
  );
}
