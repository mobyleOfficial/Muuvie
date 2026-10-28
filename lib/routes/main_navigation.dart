import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:muuvie/routes/app_router.dart';
import 'package:muuvie/routes/whispers_button.dart';
import 'package:profile_ui/profile_router.dart';

/// One destination of the bottom navigation.
class MainTab {
  final PageRouteInfo route;
  final String routeName;
  final IconData icon;
  final IconData? activeIcon;
  final String Function(AppLocalizations? l10n) label;

  /// App bar title while the tab's root page is shown.
  final String Function(AppLocalizations? l10n) title;

  /// Gated by [AuthGate] on tap; left automatically when the session ends.
  final bool requiresLogin;
  final bool showAppBar;
  final bool centerTitle;

  /// App bar actions on the tab's root page.
  final List<Widget> Function(BuildContext context)? actions;

  const MainTab({
    required this.route,
    required this.routeName,
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.title,
    this.requiresLogin = false,
    this.showAppBar = true,
    this.centerTitle = false,
    this.actions,
  });
}

/// The tabs of the main screen.
class MainNavigation {
  final List<MainTab> tabs;
  final int _loggedInInitialIndex;
  final int _loggedOutInitialIndex;

  /// Where to go when the session ends while on a tab that needs an account.
  final int publicFallbackIndex;

  const MainNavigation._({
    required this.tabs,
    required this.publicFallbackIndex,
    required int loggedInInitialIndex,
    required int loggedOutInitialIndex,
  }) : _loggedInInitialIndex = loggedInInitialIndex,
       _loggedOutInitialIndex = loggedOutInitialIndex;

  /// Perfil · Atts · Programação · Catálogo · Notícias.
  /// Programação and Notícias work logged out; the rest asks for an account.
  factory MainNavigation() => MainNavigation._(
    loggedInInitialIndex: 0,
    loggedOutInitialIndex: 2,
    publicFallbackIndex: 2,
    tabs: [
      MainTab(
        route: const ProfileTab(),
        routeName: ProfileTab.name,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: (l10n) => l10n?.profile ?? '',
        title: (l10n) => l10n?.profile ?? '',
        requiresLogin: true,
      ),
      MainTab(
        route: const SocialTab(),
        routeName: SocialTab.name,
        icon: Icons.dynamic_feed_outlined,
        activeIcon: Icons.dynamic_feed,
        label: (l10n) => l10n?.navAtts ?? '',
        title: (l10n) => l10n?.navAtts ?? '',
        requiresLogin: true,
        actions: (context) => [const _FollowsButton(), const WhispersButton()],
      ),
      MainTab(
        route: const ProgramacaoTab(),
        routeName: ProgramacaoTab.name,
        icon: Icons.event_outlined,
        activeIcon: Icons.event,
        label: (l10n) => l10n?.navProgramacao ?? '',
        title: (l10n) => l10n?.navProgramacao ?? '',
      ),
      MainTab(
        route: const SearchTab(),
        routeName: SearchTab.name,
        icon: Icons.local_movies_outlined,
        activeIcon: Icons.local_movies,
        label: (l10n) => l10n?.navCatalogo ?? '',
        title: (l10n) => l10n?.navCatalogo ?? '',
        requiresLogin: true,
        showAppBar: false,
      ),
      MainTab(
        route: const NoticiasTab(),
        routeName: NoticiasTab.name,
        icon: Icons.newspaper_outlined,
        activeIcon: Icons.newspaper,
        label: (l10n) => l10n?.navNoticias ?? '',
        title: (l10n) => l10n?.navNoticias ?? '',
      ),
    ],
  );

  /// Tab to open at launch.
  int initialIndex({required bool isLoggedIn}) =>
      isLoggedIn ? _loggedInInitialIndex : _loggedOutInitialIndex;
}

/// "Seguindo e seguidores" of the current user (F6.3), in the Atts app bar.
class _FollowsButton extends StatelessWidget {
  const _FollowsButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      tooltip: l10n?.attsFollowsAction,
      icon: const Icon(Icons.people_outline),
      onPressed: () => context.router.push(
        FollowsRoute(profileName: l10n?.attsFollowsAction ?? ''),
      ),
    );
  }
}
