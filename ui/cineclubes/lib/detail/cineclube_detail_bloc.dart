import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/detail/cineclube_detail_state.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The CineClube detail (F8.3): joining and leaving (F8.4), cancelling
/// (F8.5) and the session of a cycle the tabs show (F8.6). Actions answer
/// the error, or null when they worked.
class CineClubeDetailCubit extends Cubit<CineClubeDetailState> {
  final String slug;
  final GetCineClube _getCineClube;
  final JoinCineClube _joinCineClube;
  final LeaveCineClube _leaveCineClube;
  final CancelCineClube _cancelCineClube;

  CineClubeDetailCubit({
    required this.slug,
    required GetCineClube getCineClube,
    required JoinCineClube joinCineClube,
    required LeaveCineClube leaveCineClube,
    required CancelCineClube cancelCineClube,
  }) : _getCineClube = getCineClube,
       _joinCineClube = joinCineClube,
       _leaveCineClube = leaveCineClube,
       _cancelCineClube = cancelCineClube,
       super(const CineClubeDetailLoading());

  Future<void> load() async {
    final previous = state;
    final result = await _getCineClube(slug);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => CineClubeDetailSuccess(
        cineclube: data,
        sessionId: previous is CineClubeDetailSuccess
            ? previous.sessionId
            : null,
      ),
      Failure(:final error) => CineClubeDetailError(error),
    });
  }

  void selectSession(int sessionId) {
    final current = state;
    if (current is CineClubeDetailSuccess) {
      emit(current.copyWith(sessionId: sessionId));
    }
  }

  Future<AppError?> join({String? password}) async {
    final error = await _act(
      () => _joinCineClube(JoinCineClubeParams(slug: slug, password: password)),
    );
    if (error == null) Telemetry.analytics.logEvent('cineclube_joined');
    return error;
  }

  Future<AppError?> cancel() => _act(() => _cancelCineClube(slug));

  Future<AppError?> leave() async {
    final current = state;
    if (current is! CineClubeDetailSuccess) return null;
    emit(current.copyWith(busy: true));
    final result = await _leaveCineClube(slug);
    if (isClosed) return null;
    if (result case Failure(:final error)) {
      emit(current.copyWith(busy: false));
      return error;
    }
    await load();
    return null;
  }

  Future<AppError?> _act(Future<Result<CineClube>> Function() action) async {
    final current = state;
    if (current is! CineClubeDetailSuccess) return null;
    emit(current.copyWith(busy: true));
    final result = await action();
    if (isClosed) return null;
    switch (result) {
      case Failure(:final error):
        emit(current.copyWith(busy: false));
        return error;
      case Success(:final data):
        emit(
          CineClubeDetailSuccess(cineclube: data, sessionId: current.sessionId),
        );
        return null;
    }
  }
}
