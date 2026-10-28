import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_ui/retrospective/retrospective_state.dart';
import 'package:stats/stats.dart';

/// Loads the stories of a year (F9.3).
class RetrospectiveCubit extends Cubit<RetrospectiveState> {
  final int year;
  final GetRetrospective _getRetrospective;

  RetrospectiveCubit({
    required this.year,
    required GetRetrospective getRetrospective,
  }) : _getRetrospective = getRetrospective,
       super(const RetrospectiveLoading());

  Future<void> load() async {
    emit(const RetrospectiveLoading());
    final result = await _getRetrospective(year);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => RetrospectiveSuccess(data),
      Failure(:final error) => RetrospectiveError(error),
    });
  }
}
