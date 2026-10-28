import 'package:auto_route/auto_route.dart';
import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imports_ui/imports_router.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:onboarding/onboarding.dart';
import 'package:onboarding_ui/onboarding_bloc.dart';
import 'package:onboarding_ui/onboarding_screen.dart';

/// The introduction of the new concept (F11.1), over the whole screen, once
/// per install: the panels, the Filmow import as the highlighted step and
/// the open maratonas and CineClubes.
@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final OnboardingCubit _cubit = OnboardingCubit(
    getMaratonas: GetIt.I<GetMaratonas>(),
    getCineClubes: GetIt.I<GetCineClubes>(),
    markSeen: GetIt.I<MarkOnboardingSeen>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _finish() async {
    await _cubit.finish();
    if (mounted) context.router.maybePop();
  }

  /// Leaves the introduction for something else: it counts as seen.
  Future<void> _leaveFor(PageRouteInfo route, {bool needsLogin = false}) async {
    if (needsLogin && !await AuthGate.check(context)) return;
    await _cubit.finish();
    if (!mounted) return;
    final router = context.router.root;
    await context.router.maybePop();
    await router.push(route);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) _cubit.finish();
    },
    child: OnboardingScreen(
      cubit: _cubit,
      onFinish: _finish,
      onImport: () => _leaveFor(const ImportStartRoute(), needsLogin: true),
      onOpenMaratona: (MaratonaSummary maratona) => _leaveFor(
        MaratonaDetailRoute(slug: maratona.slug, title: maratona.title),
      ),
      onOpenCineClube: (CineClubeSummary cineclube) => _leaveFor(
        CineClubeDetailRoute(slug: cineclube.slug, title: cineclube.title),
      ),
    ),
  );
}
