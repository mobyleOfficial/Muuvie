import 'package:cineclubes/cineclubes.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas/maratonas.dart';
import 'package:onboarding/onboarding.dart';
import 'package:onboarding_ui/onboarding_state.dart';

/// The introduction of the new concept (F11.1): suggests open maratonas and
/// CineClubes and remembers it was seen.
class OnboardingCubit extends Cubit<OnboardingState> {
  static const _suggestions = 3;

  final GetMaratonas _getMaratonas;
  final GetCineClubes _getCineClubes;
  final MarkOnboardingSeen _markSeen;

  OnboardingCubit({
    required GetMaratonas getMaratonas,
    required GetCineClubes getCineClubes,
    required MarkOnboardingSeen markSeen,
  }) : _getMaratonas = getMaratonas,
       _getCineClubes = getCineClubes,
       _markSeen = markSeen,
       super(const OnboardingLoading());

  Future<void> load() async {
    final results = await Future.wait([
      _getMaratonas(
        const GetMaratonasParams(filter: MaratonaFilter(open: true)),
      ),
      _getCineClubes(
        const GetCineClubesParams(filter: CineClubeFilter(open: true)),
      ),
    ]);
    if (isClosed) return;
    emit(
      OnboardingSuccess(
        maratonas: switch (results[0] as Result<MaratonaPage>) {
          Success(:final data) => data.maratonas.take(_suggestions).toList(),
          Failure() => const [],
        },
        cineclubes: switch (results[1] as Result<CineClubePage>) {
          Success(:final data) => data.cineclubes.take(_suggestions).toList(),
          Failure() => const [],
        },
      ),
    );
  }

  Future<void> finish() => _markSeen();
}
