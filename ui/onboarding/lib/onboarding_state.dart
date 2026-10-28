import 'package:cineclubes/cineclubes.dart';
import 'package:maratonas/maratonas.dart';

sealed class OnboardingState {
  const OnboardingState();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// The panels, with the open maratonas and CineClubes for the last one. An
/// empty list just hides its part: the introduction works offline.
class OnboardingSuccess extends OnboardingState {
  final List<MaratonaSummary> maratonas;
  final List<CineClubeSummary> cineclubes;

  const OnboardingSuccess({
    this.maratonas = const [],
    this.cineclubes = const [],
  });
}

class OnboardingError extends OnboardingState {
  const OnboardingError();
}
