import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/detail/maratona_detail_state.dart';

/// The maratona detail (F7.3): the maratona, its challenges with what the
/// user completed, joining and leaving (F7.4), marking challenges (F7.5) and
/// cancelling (F7.8). Actions answer the error, or null when they worked.
class MaratonaDetailCubit extends Cubit<MaratonaDetailState> {
  final String slug;
  final GetMaratona _getMaratona;
  final GetMaratonaChallenges _getChallenges;
  final JoinMaratona _joinMaratona;
  final LeaveMaratona _leaveMaratona;
  final CancelMaratona _cancelMaratona;
  final SetChallengeLink _setChallengeLink;

  MaratonaDetailCubit({
    required this.slug,
    required GetMaratona getMaratona,
    required GetMaratonaChallenges getChallenges,
    required JoinMaratona joinMaratona,
    required LeaveMaratona leaveMaratona,
    required CancelMaratona cancelMaratona,
    required SetChallengeLink setChallengeLink,
  }) : _getMaratona = getMaratona,
       _getChallenges = getChallenges,
       _joinMaratona = joinMaratona,
       _leaveMaratona = leaveMaratona,
       _cancelMaratona = cancelMaratona,
       _setChallengeLink = setChallengeLink,
       super(const MaratonaDetailLoading());

  Future<void> load() async {
    final results = await Future.wait([
      _getMaratona(slug),
      _getChallenges(slug),
    ]);
    if (isClosed) return;
    final maratona = results[0] as Result<Maratona>;
    final challenges = results[1] as Result<List<MaratonaCategory>>;
    emit(switch ((maratona, challenges)) {
      (Success(data: final m), Success(data: final c)) => MaratonaDetailSuccess(
        maratona: m,
        categories: c,
      ),
      (Failure(:final error), _) ||
      (_, Failure(:final error)) => MaratonaDetailError(error),
    });
  }

  Future<AppError?> join({int? levelId, int? teamId, String? password}) async {
    final error = await _act(
      () => _joinMaratona(
        JoinMaratonaParams(
          slug: slug,
          levelId: levelId,
          teamId: teamId,
          password: password,
        ),
      ),
    );
    if (error == null) Telemetry.analytics.logEvent('maratona_joined');
    return error;
  }

  Future<AppError?> leave() async {
    final current = state;
    if (current is! MaratonaDetailSuccess) return null;
    emit(current.copyWith(busy: true));
    final result = await _leaveMaratona(slug);
    if (isClosed) return null;
    if (result case Failure(:final error)) {
      emit(current.copyWith(busy: false));
      return error;
    }
    await load();
    return null;
  }

  Future<AppError?> cancel() => _act(() => _cancelMaratona(slug));

  /// Ties or unties a movie; the challenge comes back with its new links.
  Future<AppError?> setLink(int challengeId, int movieId, bool linked) async {
    final result = await _setChallengeLink(
      SetChallengeLinkParams(
        slug: slug,
        challengeId: challengeId,
        movieId: movieId,
        linked: linked,
      ),
    );
    final current = state;
    if (isClosed || current is! MaratonaDetailSuccess) return null;
    switch (result) {
      case Failure(:final error):
        return error;
      case Success(:final data):
        final categories = [
          for (final category in current.categories)
            MaratonaCategory(
              id: category.id,
              name: category.name,
              teamOnly: category.teamOnly,
              challenges: [
                for (final challenge in category.challenges)
                  challenge.id == data.id ? data : challenge,
              ],
            ),
        ];
        emit(current.copyWith(categories: categories));
        return null;
    }
  }

  /// Runs an action that answers the updated maratona, then reloads the
  /// challenges (joining or cancelling changes what the user can do).
  Future<AppError?> _act(Future<Result<Maratona>> Function() action) async {
    final current = state;
    if (current is! MaratonaDetailSuccess) return null;
    emit(current.copyWith(busy: true));
    final result = await action();
    if (isClosed) return null;
    switch (result) {
      case Failure(:final error):
        emit(current.copyWith(busy: false));
        return error;
      case Success(:final data):
        final challenges = await _getChallenges(slug);
        if (isClosed) return null;
        emit(
          MaratonaDetailSuccess(
            maratona: data,
            categories: switch (challenges) {
              Success(data: final categories) => categories,
              Failure() => current.categories,
            },
          ),
        );
        return null;
    }
  }
}
