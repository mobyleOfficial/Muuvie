import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/imports_router.dart';
import 'package:muuvie/routes/main_bloc.dart';
import 'package:onboarding/onboarding.dart';
import 'package:onboarding_ui/onboarding_router.dart';
import 'package:muuvie/routes/main_navigation.dart';
import 'package:muuvie/routes/main_state.dart';
import 'package:muuvie/routes/route_title_resolver.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _appBarController = AppBarController();
  late final MainCubit _mainCubit = MainCubit(GetIt.I());
  TabsRouter? _tabsRouter;
  RoutingController? _activeTabRouter;
  bool _resolveScheduled = false;
  bool _initialTabApplied = false;
  StreamSubscription<void>? _sessionEndedSubscription;
  StreamSubscription<ImportProgress>? _importFinishedSubscription;

  final MainNavigation _navigation = MainNavigation();

  List<String> get _tabRouteNames =>
      _navigation.tabs.map((tab) => tab.routeName).toList();

  @override
  void initState() {
    super.initState();
    // Logout or a rejected refresh token: leave the tabs that need an account.
    _sessionEndedSubscription = GetIt.I<ObserveSessionEnded>()().listen((_) {
      final tabsRouter = _tabsRouter;
      if (tabsRouter != null &&
          _navigation.tabs[tabsRouter.activeIndex].requiresLogin) {
        tabsRouter.setActiveIndex(_navigation.publicFallbackIndex);
      }
    });
    // An import ends in the background (F3.5): tell the user wherever they are.
    _importFinishedSubscription = GetIt.I<WatchImportProgress>()()
        .where((progress) => progress.status == ImportStatus.done)
        .listen(_showImportFinished);
    // The introduction of the new concept (F11.1), once per install.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOnboarding());
  }

  Future<void> _showOnboarding() async {
    if (!GetIt.I.isRegistered<ShouldShowOnboarding>()) return;
    final result = await GetIt.I<ShouldShowOnboarding>()();
    if (!mounted) return;
    if (result case Success(data: true)) {
      context.router.root.push(const OnboardingRoute());
    }
  }

  void _showImportFinished(ImportProgress progress) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.importFinishedSnack ?? ''),
        action: SnackBarAction(
          label: l10n?.importSeeReport ?? '',
          onPressed: () =>
              context.router.root.push(ImportJobRoute(jobId: progress.jobId)),
        ),
      ),
    );
  }

  void _attachToTabsRouter(TabsRouter tabsRouter) {
    if (_tabsRouter == tabsRouter) return;
    _detachListeners();
    _tabsRouter = tabsRouter;
    tabsRouter.addListener(_scheduleResolve);
    tabsRouter.root.navigationHistory.addListener(_scheduleResolve);
    _syncActiveTabRouter();
    _applyInitialTab(tabsRouter);
  }

  /// Logged in opens Perfil; logged out opens a public tab.
  Future<void> _applyInitialTab(TabsRouter tabsRouter) async {
    if (_initialTabApplied) return;
    _initialTabApplied = true;

    final result = await GetIt.I<IsUserAuthenticated>()();
    final isLoggedIn = result is Success<bool> && result.data;
    final index = _navigation.initialIndex(isLoggedIn: isLoggedIn);
    if (mounted && index != tabsRouter.activeIndex) {
      tabsRouter.setActiveIndex(index);
    }
  }

  void _detachListeners() {
    _activeTabRouter?.removeListener(_scheduleResolve);
    _tabsRouter?.root.navigationHistory.removeListener(_scheduleResolve);
    _tabsRouter?.removeListener(_scheduleResolve);
    _activeTabRouter = null;
  }

  void _scheduleResolve() {
    if (_resolveScheduled) return;
    _resolveScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveScheduled = false;
      if (!mounted) return;
      _syncActiveTabRouter();
    });
  }

  void _syncActiveTabRouter() {
    final tabsRouter = _tabsRouter;
    if (tabsRouter == null) return;

    final activeTabName = _tabRouteNames[tabsRouter.activeIndex];
    final newRouter = tabsRouter.innerRouterOf<StackRouter>(activeTabName);

    if (_activeTabRouter != newRouter) {
      _activeTabRouter?.removeListener(_scheduleResolve);
      _activeTabRouter = newRouter;
      _activeTabRouter?.addListener(_scheduleResolve);
    }
    _resolveTitle();
  }

  void _resolveTitle() {
    final tabsRouter = _tabsRouter;
    if (tabsRouter == null) {
      _appBarController.update(title: null);
      return;
    }
    final activeTabName = _tabRouteNames[tabsRouter.activeIndex];
    final innerRouter = tabsRouter.innerRouterOf<StackRouter>(activeTabName);
    if (innerRouter == null) {
      _appBarController.update(title: null);
      return;
    }
    final topRoute = innerRouter.topRoute;
    final title = resolveRouteTitle(topRoute, AppLocalizations.of(context));
    _appBarController.update(title: title);
  }

  @override
  void dispose() {
    _sessionEndedSubscription?.cancel();
    _importFinishedSubscription?.cancel();
    _detachListeners();
    _appBarController.dispose();
    _mainCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AutoTabsRouter(
      routes: _navigation.tabs.map((tab) => tab.route).toList(),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _attachToTabsRouter(tabsRouter);
        });

        final activeIndex = tabsRouter.activeIndex;
        final activeTab = _navigation.tabs[activeIndex];
        final brightness = Theme.of(context).brightness;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: brightness == Brightness.dark
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                ),
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  ListenableBuilder(
                    listenable: _appBarController,
                    builder: (context, _) {
                      final titleOverride = _appBarController.currentTitle;
                      final hasOverride = titleOverride != null;
                      final hideAppBar = !activeTab.showAppBar && !hasOverride;

                      return MuuvieAnimatedAppBar(
                        title: titleOverride ?? activeTab.title(l10n),
                        visible: !hideAppBar,
                        centerTitle: !hasOverride && activeTab.centerTitle,
                        actions: hasOverride
                            ? _appBarController.currentActions
                            : activeTab.actions?.call(context) ??
                                  _appBarController.currentActions,
                        leading: hasOverride
                            ? IconButton(
                                icon: const Icon(Icons.arrow_back),
                                tooltip: MaterialLocalizations.of(
                                  context,
                                ).backButtonTooltip,
                                onPressed: () {
                                  final tabsRouter = _tabsRouter;
                                  if (tabsRouter == null) return;
                                  final activeTabName =
                                      _tabRouteNames[tabsRouter.activeIndex];
                                  tabsRouter
                                      .innerRouterOf<StackRouter>(activeTabName)
                                      ?.maybePop();
                                },
                              )
                            : null,
                      );
                    },
                  ),
                  BlocBuilder<MainCubit, MainState>(
                    bloc: _mainCubit,
                    buildWhen: (prev, curr) =>
                        prev is! MainSuccess ||
                        curr is! MainSuccess ||
                        prev.isScraping != curr.isScraping,
                    builder: (context, state) {
                      final show = state is MainSuccess && state.isScraping;
                      return AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: show
                              ? const _ScrapingBanner(key: ValueKey('scraping'))
                              : const SizedBox.shrink(key: ValueKey('empty')),
                        ),
                      );
                    },
                  ),
                  TabIndexScope(
                    tabIndex: activeIndex,
                    child: Expanded(
                      child: AppBarControllerScope(
                        controller: _appBarController,
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: MuuvieBottomNavigationBar(
              currentIndex: activeIndex,
              onTap: (index) async {
                if (_navigation.tabs[index].requiresLogin) {
                  final allowed = await AuthGate.check(context);
                  if (!allowed) return;
                }
                tabsRouter.setActiveIndex(index);
              },
              items: _navigation.tabs
                  .map(
                    (tab) => MuuvieBottomNavigationBarItem(
                      icon: tab.icon,
                      activeIcon: tab.activeIcon,
                      label: tab.label(l10n),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ScrapingBanner extends StatelessWidget {
  const _ScrapingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Importing data...',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Filmow',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
