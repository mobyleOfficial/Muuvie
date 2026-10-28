import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:locadoras_ui/locadoras_ui.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:profile/profile.dart';
import 'package:social_network/social_network.dart'
    show FollowList, SetFollowing;
import 'package:share_plus/share_plus.dart';
import 'package:shelves/shelves.dart';
import 'package:watch_logs_ui/watching_now/watching_now_card.dart';
import 'package:whispers/whispers_router.dart';

import 'package:profile_ui/member/diary/diary_tab.dart';
import 'package:profile_ui/member/highlights/highlights_tab.dart';
import 'package:profile_ui/member/member_profile_bloc.dart';
import 'package:profile_ui/member/member_profile_state.dart';
import 'package:profile_ui/follows/follows_screen.dart';
import 'package:profile_ui/member/profile_header.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:gamification_ui/gamification_router.dart';
import 'package:gamification_ui/widgets/profile_gamification_row.dart';
import 'package:profile_ui/tabs/charts/charts_page.dart';
import 'package:profile_ui/tabs/participations/participations_page.dart';
import 'package:profile_ui/tabs/shelves/shelves_page.dart';

/// A profile, mine or someone else's (F5.1, F5.2): the header and the tabs
/// Destaques · Estantes · Registros · Locadoras · Participações · Gráficos.
class MemberProfileView extends StatefulWidget {
  /// `me`, a user id, or a handle with the @.
  final String userId;

  /// Reloads the header, e.g. when an import of the own profile ends.
  final Stream<Object?>? changes;

  const MemberProfileView({super.key, required this.userId, this.changes});

  @override
  State<MemberProfileView> createState() => _MemberProfileViewState();
}

class _MemberProfileViewState extends State<MemberProfileView> {
  late final MemberProfileCubit _cubit = MemberProfileCubit(
    userId: widget.userId,
    getProfile: GetIt.I<GetProfileDetails>(),
    setFollowing: GetIt.I<SetFollowing>(),
    changes: widget.changes,
  );

  // The header reloads when the profile is back in view: on top of its stack
  // again, or its bottom tab selected again (a session was logged, a movie
  // went to a shelf elsewhere).
  StackRouter? _router;
  TabsRouter? _tabsRouter;
  String? _routeName;
  String? _tabName;
  bool _wasInView = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = context.router;
    if (router != _router) {
      _router?.removeListener(_onNavigation);
      _tabsRouter?.removeListener(_onNavigation);
      _router = router..addListener(_onNavigation);
      _routeName = context.routeData.name;
      _tabsRouter = router.parent<TabsRouter>()?..addListener(_onNavigation);
      _tabName = _tabsRouter?.current.name;
    }
  }

  void _onNavigation() {
    final inView =
        _router?.current.name == _routeName &&
        (_tabsRouter == null || _tabsRouter?.current.name == _tabName);
    if (inView && !_wasInView) _cubit.load();
    _wasInView = inView;
  }

  @override
  void dispose() {
    _router?.removeListener(_onNavigation);
    _tabsRouter?.removeListener(_onNavigation);
    _cubit.close();
    super.dispose();
  }

  Future<void> _openSettings(ProfileDetails profile) async {
    final changed = await context.router.root.push<bool>(
      SettingsRoute(profile: profile),
    );
    if (changed ?? false) _cubit.load();
  }

  Future<void> _editProfile(ProfileDetails profile) async {
    final saved = await context.router.root.push<bool>(
      EditProfileRoute(profile: profile),
    );
    if (saved ?? false) _cubit.load();
  }

  Future<void> _toggleFollow() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final error = await _cubit.toggleFollow();
    if (error != null && mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(followErrorMessage(l10n, error))),
      );
    }
  }

  void _openFollows(ProfileDetails profile, FollowList list) =>
      context.router.push(
        FollowsRoute(
          userId: profile.isSelf ? 'me' : profile.id,
          profileName: profile.name,
          initialList: list,
        ),
      );

  void _whisper(ProfileDetails profile) => context.router.push(
    ConversationRoute(userId: profile.id, name: profile.name),
  );

  void _share(ProfileDetails profile) {
    final link = ProfileHeader.linkOf(profile);
    if (link == null) return;
    final text =
        AppLocalizations.of(context)?.profileShareText(profile.name, link) ??
        link;
    SharePlus.instance.share(ShareParams(text: text));
  }

  /// The pinned bichinho can change in any of the phase 10 screens.
  var _petsVersion = 0;

  Future<void> _openGame(PageRouteInfo route) async {
    await context.router.root.push(route);
    if (mounted) setState(() => _petsVersion++);
  }

  void _openShelf(BuildContext context, Shelf shelf) => context.router.push(
    ShelfDetailRoute(
      shelfId: shelf.id,
      shelfName: shelf.name,
      shelfColor: shelf.color,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<MemberProfileCubit, MemberProfileState>(
      bloc: _cubit,
      builder: (context, state) => switch (state) {
        MemberProfileLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        MemberProfileError(:final message, :final notFound) => MuuvieEmptyState(
          title: notFound
              ? l10n?.profileNotFound ?? ''
              : l10n?.emptyStateErrorTitle ?? '',
          message: notFound ? '' : message,
          action: notFound ? null : _cubit.load,
          actionLabel: notFound ? null : l10n?.emptyStateRetry,
        ),
        MemberProfileSuccess(:final profile, :final isFollowBusy) =>
          DefaultTabController(
            length: 6,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    profile: profile,
                    isPrimaryActionBusy: isFollowBusy,
                    onPrimaryAction: profile.isSelf
                        ? () => _editProfile(profile)
                        : _toggleFollow,
                    onShare: profile.handle == null
                        ? null
                        : () => _share(profile),
                    onPickHandle: profile.isSelf
                        ? () => _editProfile(profile)
                        : null,
                    onOpenSettings: profile.isSelf
                        ? () => _openSettings(profile)
                        : null,
                    onWhisper: () => _whisper(profile),
                    onOpenFollows: (list) => _openFollows(profile, list),
                  ),
                ),
                SliverToBoxAdapter(
                  child: WatchingNowCard(
                    userId: profile.isSelf ? 'me' : profile.id,
                    onOpenMovie: (movie) => context.router.push(
                      MovieDetailRoute(
                        movieId: movie.movieId,
                        movieTitle: movie.title,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ProfileGamificationRow(
                    key: ValueKey('pets-$_petsVersion'),
                    userId: profile.isSelf ? 'me' : profile.id,
                    onOpenShelter: () => _openGame(const ShelterRoute()),
                    onOpenMissions: () => _openGame(const MissionsRoute()),
                    onOpenDiary: () => _openGame(const DiaryRoute()),
                    onOpenParty: () => _openGame(WatchPartyRoute()),
                    onOpenPosterGame: () => _openGame(const PosterGameRoute()),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    color: Theme.of(context).colorScheme.surface,
                    tabs: [
                      l10n?.profileTabHighlights ?? '',
                      l10n?.profileTabShelves ?? '',
                      l10n?.profileTabLogs ?? '',
                      l10n?.profileTabLocadoras ?? '',
                      l10n?.profileTabParticipations ?? '',
                      l10n?.profileTabCharts ?? '',
                    ],
                  ),
                ),
              ],
              body: TabBarView(children: _tabs(profile)),
            ),
          ),
      },
    );
  }

  List<Widget> _tabs(ProfileDetails profile) {
    final userId = profile.isSelf ? 'me' : profile.id;
    return [
      MuuvieKeepAliveTab(
        child: HighlightsTab(
          userId: userId,
          onRefresh: _cubit.load,
          onEdit: profile.isSelf
              ? () => context.router.root.push<bool>(
                  const HighlightsEditorRoute(),
                )
              : null,
        ),
      ),
      MuuvieKeepAliveTab(child: ShelvesPage(userId: userId)),
      MuuvieKeepAliveTab(
        child: DiaryTab(userId: userId, onRefresh: _cubit.load),
      ),
      MuuvieKeepAliveTab(
        child: LocadorasListPage(userId: userId, onOpenShelf: _openShelf),
      ),
      MuuvieKeepAliveTab(child: ParticipationsPage(userId: userId)),
      MuuvieKeepAliveTab(child: ChartsPage(userId: userId)),
    ];
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  static const _height = 48.0;

  final Color color;
  final List<String> tabs;

  _TabBarDelegate({required this.color, required this.tabs});

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: color,
    child: MuuvieTabBar(isScrollable: true, tabs: tabs),
  );

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      oldDelegate.color != color || oldDelegate.tabs != tabs;
}
